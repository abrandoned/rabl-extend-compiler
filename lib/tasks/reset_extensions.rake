require "rabl"
require "digest"
require "stringio"

namespace :rabl do
  namespace :extend do
    namespace :compiler do
      desc "reset extensions to be compiled"
      task :reset do
        view_paths = ::Rabl.configuration.view_paths

        view_paths.each do |view_path|
          ::Dir.glob("#{view_path}/**/*.rabl").each do |rabl_file|
            file_contents = ::File.read(rabl_file)
            new_file_contents = ::StringIO.new

            ##
            # Run through each line and verify the Sha256 digest of the extension file contents
            # against the digest that is already stored in the file that extends
            #
            waiting = false
            waiting_hash = ""
            file_contents.each_line do |file_line|
              if waiting
                waiting = !file_line.include?(waiting_hash) # if we are in a waiting state then we throw the line away
                next
              end

              if file_line.start_with?("# rabl-extend-compiler extends")
                extension_file = file_line.scan(/\A[[:space:]]*#[[:space:]]+rabl-extend-compiler[[:space:]]*extends[([:space:]]*['"]+([^"]*)['"]+/).flatten.first
                  extension_filename = "#{view_path}/#{extension_file}.rabl"
                extension_file_digest = file_line.split("=>").last.gsub(/[[:space:]]/, "")

                if extension_file_digest == ::Digest::SHA256.file(extension_filename).hexdigest
                  new_file_contents.puts file_line
                else
                  new_file_contents.puts file_line.split("=>").first.gsub("# rabl-extend-compiler ", "")
                  waiting = true
                  waiting_hash = extension_file_digest
                end
              else
                new_file_contents.puts file_line
              end
            end

            # Replace the file if the contents changed and the following will rewrite it again
            if file_contents != new_file_contents.string
              ::File.write(rabl_file, new_file_contents.string)
            end
          end
        end
      end
    end
  end
end
