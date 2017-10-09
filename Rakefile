require "bundler/gem_tasks"
require "rake/testtask"
import "ext/ffi/radixtree/Rakefile"

namespace :radixtree do
  desc "build radixtree"
  task :compile do
    Rake::Task[:compile_radixtree].invoke
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end
Rake::Task[:test].prerequisites << "radixtree:compile"

task :default => :test
