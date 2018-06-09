require "fileutils"
require "spec_helper"
require 'pry'

describe ::Rabl::Extend::Compiler do
  describe "good" do
    before do
      good_path = ::File.join(::File.dirname(__FILE__), "..", "..", "good")
      ::FileUtils.cp(::File.join(good_path, "app.rabl.good"), ::File.join(good_path, "app.rabl"))
      ::FileUtils.cp(::File.join(good_path, "extend.rabl.good"), ::File.join(good_path, "extend.rabl"))

      ::Rabl.configure do |config|
        config.view_paths = [good_path]
      end
    end

    it "verifies the files in the path" do
      assert proc { ::Rake::Task["rabl:extend:compiler:verify"].invoke }
    end

    it "does not edit the files at all" do
      good_path = ::File.join(::File.dirname(__FILE__), "..", "..", "good")
      proc { ::Rake::Task["rabl:extend:compiler:all"].invoke }

      good_contents = ::File.read(::File.join(good_path, "app.rabl.good"))
      current_contents = ::File.read(::File.join(good_path, "app.rabl"))

      good_contents.must_equal current_contents
    end
  end

  describe "bad" do
    before do
      bad_path = ::File.join(::File.dirname(__FILE__), "..", "..", "bad")
      ::FileUtils.cp(::File.join(bad_path, "app.rabl.good"), ::File.join(bad_path, "app.rabl"))
      ::FileUtils.cp(::File.join(bad_path, "app2.rabl.good"), ::File.join(bad_path, "app2.rabl"))
      ::FileUtils.cp(::File.join(bad_path, "extend.rabl.good"), ::File.join(bad_path, "extend.rabl"))

      ::Rabl.configure do |config|
        config.view_paths = [bad_path]
      end
    end

    it "verifies the files in the path" do
      proc { ::Rake::Task["rabl:extend:compiler:verify"].invoke }.must_raise SystemExit
    end
  end
end
