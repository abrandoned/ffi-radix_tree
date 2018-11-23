require 'spec_helper'

describe ::FFI::RadixTree::Tree do
  describe "default state" do
    subject { ::FFI::RadixTree::Tree.new }

    it "#has_key?" do
      subject.must_respond_to("has_key?")
      subject.has_key?("Derp Derpy").must_equal false
      subject.push("has_key", "test")
      subject.has_key?("has_key").must_equal true
    end

    it "#push" do
      subject.must_respond_to("push")
      subject.method(:push).arity.must_equal 2
      subject.push("hello", "world")
      subject.get("hello").must_equal "world"
    end

    it "#get" do
      subject.must_respond_to("get")
      subject.method(:get).arity.must_equal 1
      subject.get("Derp Derpy").must_be_nil
      subject.push("get", "test")
      subject.get("get").must_equal "test"
    end

    it "#longest_prefix" do
      subject.must_respond_to("longest_prefix")
      subject.method(:longest_prefix).arity.must_equal 1
      subject.longest_prefix("nothing").must_be_nil
      subject.push("longest_prefix", "test")
      subject.push("longest_prefix_", "test2")
      subject.longest_prefix("longest_prefix_").must_equal "longest_prefix_"
    end

    it "#longest_prefix_value" do
      subject.must_respond_to("longest_prefix_value")
      subject.method(:longest_prefix_value).arity.must_equal 1
      subject.longest_prefix_value("nothing").must_be_nil
      subject.push("longest_prefix_value", "test")
      subject.push("longest_prefix_value_", "test2")
      subject.longest_prefix_value("longest_prefix_value_").must_equal "test2"
    end
  end
end
