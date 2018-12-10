require "bundler/gem_tasks"
require "rake/testtask"
import "ext/ffi/radixtree/Rakefile"

namespace :radixtree do
  desc "build radixtree"
  task :compile do
    Rake::Task[:compile_radixtree].invoke
  end

  desc "run benchmarks for radixtree lib"
  task :benchmark do
    require "benchmark/ips"
    require "./lib/ffi/radix_tree"

    radix_tree = ::FFI::RadixTree::Tree.new

    (1..1000).each do |number|
      radix_tree.push(number.to_s, "DERP#{number}" * (number % 10))
      radix_tree.push(number.to_s * 100, "DERP#{number}" * (number % 10))
      radix_tree.push(number.to_s * 1000, "DERP#{number}" * (number % 10))
    end

    ::Benchmark.ips do |x|
      x.config(:warmup => 10)

      x.report("get") do
        radix_tree.get(rand(1000).to_s * [1, 100, 100].sample)
      end

      x.report("longest prefix") do
        radix_tree.longest_prefix(rand(1000).to_s * [1, 100, 100].sample)
      end

      x.report("get then value") do
        val = rand(1000).to_s * [1, 100, 100].sample

        radix_tree.longest_prefix(val)
        radix_tree.longest_prefix_value(val)
      end

      x.report("prefix and value (combined)") do
        radix_tree.longest_prefix_and_value(rand(1000).to_s * [1, 100, 100].sample)
      end

      x.report("longest prefix (miss)") do
        radix_tree.longest_prefix("DERP DERPIE")
      end

      x.report("prefix and value (combined/miss)") do
        radix_tree.longest_prefix_and_value("DERP DERPIE")
      end
    end
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
