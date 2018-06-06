require "rabl"
require "digest"
require "stringio"

namespace :rabl do
  namespace :extend do
    namespace :compiler do
      desc "compile all uncompbiled extensions into rabl files"
      task :compile do
        view_paths = ::Rabl.configuration.view_paths

        loop do
          did_compile_a_file = false
          view_paths.each do |view_path|
            ::Dir.glob("#{view_path}/**/*.rabl").each do |rabl_file|
              # Rewrite all of the file for extensions
              file_contents = ::File.read(rabl_file)
              new_file_contents = ::StringIO.new
              file_contents.each_line do |file_line|
                extension_file = file_line.scan(/\A[[:space:]]*extends[([:space:]]*['"]+([^"]*)['"]+/).flatten

                if extension_file.empty?
                  new_file_contents.puts file_line
                  next
                end

                extension_filename = "#{view_path}/#{extension_file.first}.rabl"
                extension_file_digest = ::Digest::SHA256.file(extension_filename).hexdigest
                extension_contents = ::File.read(extension_filename)

                new_file_contents.puts <<~EXTENDS_MESSAGE
              # rabl-extend-compiler #{file_line.chomp} => #{extension_file_digest}
              #
              # This file segment is generated by rabl-extend-compiler rake task
              # and should not be edited. To edit the generated extension
              # edit the file at: #{extension_file.first}
                EXTENDS_MESSAGE

                new_file_contents.puts extension_contents
                new_file_contents.puts "# #{extension_file_digest}"
              end

              # Replace the file if the contents changed and the following will rewrite it again
              if file_contents != new_file_contents.string
                did_compile_a_file = true
                ::File.write(rabl_file, new_file_contents.string)
              end
            end
          end

          if did_compile_a_file
            did_compile_a_file = false
          else
            break
          end
        end
      end
    end
  end
end
