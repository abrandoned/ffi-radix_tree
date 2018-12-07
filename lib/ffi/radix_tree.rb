require "ffi"
require "msgpack"
require "ffi/radix_tree/version"

module FFI
  module RadixTree
    extend FFI::Library
    ffi_lib_flags :now, :global

    ##
    # ffi-rzmq-core for reference
    #
    # https://github.com/chuckremes/ffi-rzmq-core/blob/master/lib/ffi-rzmq-core/libzmq.rb
    #
    begin
      # bias the library discovery to a path inside the gem first, then
      # to the usual system paths
      gem_base = ::File.join(::File.dirname(__FILE__), '..', '..')
      inside_gem = ::File.join(gem_base, 'ext')
      local_path = ::FFI::Platform::IS_WINDOWS ? ENV['PATH'].split(';') : ENV['PATH'].split(':')
      env_path = [ ENV['RADIX_TREE_LIB_PATH'] ].compact
      rbconfig_path = ::RbConfig::CONFIG["libdir"]
      homebrew_path = nil

      # RUBYOPT set by RVM breaks 'brew' so we need to unset it.
      rubyopt = ENV.delete('RUBYOPT')

      begin
        stdout, stderr, status = ::Open3.capture3("brew", "--prefix")
        homebrew_path  = if status.success?
                           "#{stdout.chomp}/lib"
                         else
                           '/usr/local/homebrew/lib'
                         end
      rescue
        # Homebrew doesn't exist
      end

      # Restore RUBYOPT after executing 'brew' above.
      ENV['RUBYOPT'] = rubyopt

      # Search for libradixtree in the following order...
      radixtree_lib_paths =
        if ENV.key?("RADIX_TREE_USE_SYSTEM_LIB")
          [inside_gem] + env_path + local_path + [rbconfig_path] + [
           '/usr/local/lib', '/opt/local/lib', homebrew_path, '/usr/lib64'
          ]
        else
          [::File.join(gem_base, "vendor/radixtree")]
        end

      RADIX_TREE_LIB_PATHS = radixtree_lib_paths.
        compact.map{|path| "#{path}/libradixtree.#{::FFI::Platform::LIBSUFFIX}"}

      ffi_lib(RADIX_TREE_LIB_PATHS + %w{libradixtree})
    rescue LoadError => error
      if RADIX_TREE_LIB_PATHS.any? {|path| ::File.file?(::File.join(path)) }
        warn "Unable to load this gem. The libradixtree library exists, but cannot be loaded."
        warn "Set RADIX_TREE_LIB_PATH if custom load path is desired"
        warn "If this is Windows:"
        warn "-  Check that you have MSVC runtime installed or statically linked"
        warn "-  Check that your DLL is compiled for #{FFI::Platform::ADDRESS_SIZE} bit"
      else
        warn "Unable to load this gem. The libradixtree library (or DLL) could not be found."
        warn "Set RADIX_TREE_LIB_PATH if custom load path is desired"
        warn "If this is a Windows platform, make sure libradixtree.dll is on the PATH."
        warn "If the DLL was built with mingw, make sure the other two dependent DLLs,"
        warn "libgcc_s_sjlj-1.dll and libstdc++6.dll, are also on the PATH."
        warn "For non-Windows platforms, make sure libradixtree is located in this search path:"
        warn RADIX_TREE_LIB_PATHS.inspect
      end
      raise error
    end

    attach_function :create, [], :pointer
    attach_function :destroy, [:pointer], :void
    attach_function :erase, [:pointer, :string], :void
    attach_function :fetch, [:pointer, :string, :pointer], :pointer
    attach_function :insert, [:pointer, :string, :pointer, :size_t], :void
    attach_function :longest_prefix, [:pointer, :string], :string
    attach_function :longest_prefix_and_value, [:pointer, :string, :pointer], :pointer
    attach_function :longest_prefix_value, [:pointer, :string, :pointer], :pointer
    attach_function :match_free, [:pointer], :void
    attach_function :has_key, [:pointer, :string], :bool

    class Tree
      RADIX_SPLIT = "[:radix:]".freeze

      def self.destroy!(tree)
        tree.destroy! unless tree.nil?
      end

      def initialize
        @ptr = ::FFI::RadixTree.create
        @first_character_present = {}
      end

      def destroy!
        ::FFI::RadixTree.destroy(@ptr) unless @ptr.nil?
        @ptr = nil
      end

      def has_key?(key)
        ::FFI::RadixTree.has_key(@ptr, key)
      end

      def push(key, value)
        push_response = nil
        @first_character_present[key[0]] = true
        storage_data = ::MessagePack.pack(value)
        bytesize = storage_data.bytesize

        ::FFI::MemoryPointer.new(:char, bytesize, true) do |memory_buffer|
          memory_buffer.put_bytes(0, storage_data)
          push_response = ::FFI::RadixTree.insert(@ptr, key, memory_buffer, bytesize)
        end

        push_response
      end

      def get(key)
        return nil unless @first_character_present[key[0]]
        byte_pointer = get_response = nil

        ::FFI::MemoryPointer.new(:int) do |byte_length|
          byte_pointer = ::FFI::RadixTree.fetch(@ptr, key, byte_length)
          bytesize = byte_length.read_int

          if bytesize && bytesize > 0
            bytes = byte_pointer.get_bytes(0, bytesize)
            get_response = ::MessagePack.unpack(bytes)
          end
        end

        get_response
      ensure
        ::FFI::RadixTree.match_free(byte_pointer) if byte_pointer
      end

      def longest_prefix(string)
        return nil unless @first_character_present[string[0]]
        value, p_out = ::FFI::RadixTree.longest_prefix(@ptr, string)
        value.force_encoding("UTF-8") if value
        value
      ensure
        ::FFI::RadixTree.match_free(p_out) if p_out
      end

      def longest_prefix_and_value(string)
        return [nil, nil] unless @first_character_present[string[0]]
        byte_pointer = prefix_response = get_response = nil

        ::FFI::MemoryPointer.new(:int) do |byte_length|
          byte_pointer = ::FFI::RadixTree.longest_prefix_and_value(@ptr, string, byte_length)
          bytesize = byte_length.read_int

          if bytesize && bytesize > 0
            get_response = byte_pointer.get_bytes(0, bytesize)
            splits = get_response.split(RADIX_SPLIT)
            prefix_response = splits.delete_at(0)
            get_response = ::MessagePack.unpack(splits.join(RADIX_SPLIT))
          end
        end

        [prefix_response, get_response]
      ensure
        ::FFI::RadixTree.match_free(byte_pointer) if byte_pointer
      end

      def longest_prefix_value(string)
        return nil unless @first_character_present[string[0]]
        byte_pointer = get_response = nil

        ::FFI::MemoryPointer.new(:int) do |byte_length|
          byte_pointer = ::FFI::RadixTree.longest_prefix_value(@ptr, string, byte_length)
          bytesize = byte_length.read_int
          get_response = ::MessagePack.unpack(byte_pointer.get_bytes(0, bytesize)) if bytesize && bytesize > 0
        end

        get_response
      ensure
        ::FFI::RadixTree.match_free(byte_pointer) if byte_pointer
      end
    end
  end
end
