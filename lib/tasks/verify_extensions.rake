require "rabl"
require "digest"
require "stringio"

namespace :rabl do
  namespace :extend do
    namespace :compiler do
      desc "verify that all extensions are created and the signatures match; return exit(1) if not verifiable"
      task :verify do
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

                next if extension_file_digest == ::Digest::SHA256.file(extension_filename).hexdigest
                $stderr << "rabl-extend-compiler: Compiled extension digest mismatch #{extension_filename}"
                $stderr << "rabl-extend-compiler: Run rake rabl:extend:compiler:all to reset"

                exit(1)
              end
            end

            file_contents.each_line do |file_line|
              extension_file = file_line.scan(/\A[[:space:]]*extends[([:space:]]*['"]+([^"]*)['"]+/).flatten
              next if extension_file.empty?
              $stderr << "rabl-extend-compiler: Uncompiled extenion at #{extension_file.first}"

              exit(1)
            end
          end
        end
      end
    end
  end
end
