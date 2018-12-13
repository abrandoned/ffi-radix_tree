# Ffi::RadixTree

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ffi/radix_tree`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ffi-radix_tree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffi-radix_tree

## Usage

```ruby
# create a new tree
rtree = ::FFI::RadixTree::Tree.new

# add key/value pairs to the tree
rtree.push("key1", "value1")
rtree.push("key2", ["value2", "value3"])
rtree.push("key3", { :attr1 => "value4", :attr2 => "value5" })

# work with the collection
if rtree.has_key?("key1")
  val = rtree.get("key2")
  rtree.set("key3", "value6")
end

# search the tree using the keys

# keys based off the root word: "manage"
rtree.push("manage", "base verb")
rtree.push("managed", "past tense")
rtree.push("manager", "noun")
rtree.push("managers", "plural noun")
rtree.push("managing", "present tense")

# Find the key that matches the _most_ of the beggining of the search term
rtree.longest_prefix("managerial")                # returns "manager"
rtree.longest_prefix_and_value("managerial")      # returns ["manager", "noun"]
rtree.longest_prefix_value("managerial")          # returns "noun"

# Find all values whose keys match the _most_ of the beginning of the search term
rtree.greedy_match("managerial")                  # returns ["noun", "plural noun"]

# Find all values whose keys are included _anywhere_ in the search term
rtree.greedy_substring_match("I managed to jump") # returns ["base verb", "past tense"]

# cleanup
rtree.destroy!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ffi-radix_tree.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
