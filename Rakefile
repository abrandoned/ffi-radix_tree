require "bundler/gem_tasks"
require "rake/testtask"
import "ext/ffi/radixtree/Rakefile"

namespace :radixtree do
  desc "build radixtree"
  task :compile do
    Rake::Task[:compile_radixtree].invoke
  end
end

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end
Rake::Task[:spec].prerequisites << "radixtree:compile"

task :default => :spec
