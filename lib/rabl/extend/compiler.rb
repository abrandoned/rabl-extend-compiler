require "rabl/extend/compiler/version"

module Rabl
  module Extend
    module Compiler
      if defined?(Rake)
        ::Dir[::File.join(::File.dirname(__FILE__), "..", "..", "..", "..", "tasks", "**", "*.rake")].each do |rake_file|
          require rake_file
        end
      end
    end
  end
end
