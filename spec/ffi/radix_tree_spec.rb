require 'spec_helper'

describe ::FFI::RadixTree do
  describe "api" do
    it "responds to #create" do
      ::FFI::RadixTree.must_respond_to("create")
    end

    it "responds to #destroy" do
      ::FFI::RadixTree.must_respond_to("destroy")
    end

    it "responds to #erase" do
      ::FFI::RadixTree.must_respond_to("erase")
    end

    it "responds to #fetch" do
      ::FFI::RadixTree.must_respond_to("fetch")
    end

    it "responds to #insert" do
      ::FFI::RadixTree.must_respond_to("insert")
    end

    it "responds to #longest_prefix" do
      ::FFI::RadixTree.must_respond_to("longest_prefix")
    end

    it "responds to #longest_prefix_value" do
      ::FFI::RadixTree.must_respond_to("longest_prefix_value")
    end

    it "responds to #match_free" do
      ::FFI::RadixTree.must_respond_to("match_free")
    end

    it "responds to #has_key" do
      ::FFI::RadixTree.must_respond_to("has_key")
    end
  end
end
