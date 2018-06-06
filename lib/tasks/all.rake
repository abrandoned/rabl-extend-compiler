require "rabl"
require "digest"
require "stringio"
require "rabl/extend/compiler"

namespace :rabl do
  namespace :extend do
    namespace :compiler do
      desc "compile all extensions into rabl files"
      task :all do
        ::Rake::Task["rabl:extend:compiler:reset"].invoke
        ::Rake::Task["rabl:extend:compiler:compile"].invoke
      end
    end
  end
end
