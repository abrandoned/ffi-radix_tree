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
    attach_function :erase, [:string], :void
    attach_function :fetch, [:pointer, :string, :pointer], :pointer
    attach_function :insert, [:pointer, :string, :pointer, :size_t], :void
    attach_function :longest_prefix, [:pointer, :string], :string
    attach_function :longest_prefix_value, [:pointer, :string, :pointer], :pointer
    attach_function :match_free, [:pointer], :void
    attach_function :has_key, [:pointer, :string], :bool

    class Tree
      DESTROY_METHOD = ::FFI::RadixTree.method(:destroy)
      FREE_METHOD = ::FFI::RadixTree.method(:match_free)

      def initialize
        @ptr = ::FFI::AutoPointer.new(::FFI::RadixTree.create, DESTROY_METHOD)
      end

      def has_key?(key)
        ::FFI::RadixTree.has_key(@ptr, key)
      end

      def push(key, value)
        storage_data = ::MessagePack.pack(value)
        bytesize = storage_data.bytesize
        memory_buffer = ::FFI::MemoryPointer.new(:char, bytesize, true)
        memory_buffer.put_bytes(0, storage_data)
        ::FFI::RadixTree.insert(@ptr, key, memory_buffer, bytesize)
      end

      def get(key)
        byte_length = ::FFI::MemoryPointer.new(:int)
        byte_pointer = ::FFI::AutoPointer.new(::FFI::RadixTree.fetch(@ptr, key, byte_length), FREE_METHOD)
        bytesize = byte_length.read_int
        return nil if bytesize <= 0
        ::MessagePack.unpack(byte_pointer.get_bytes(0, bytesize))
      end

      def longest_prefix(string)
        value, p_out = ::FFI::RadixTree.longest_prefix(@ptr, string)
        p_out = ::FFI::AutoPointer.new(p_out, FREE_METHOD) unless p_out.nil?
        value.force_encoding("UTF-8") unless value.nil?
        value
      end

      def longest_prefix_value(string)
        byte_length = ::FFI::MemoryPointer.new(:int)
        byte_pointer = ::FFI::AutoPointer.new(::FFI::RadixTree.longest_prefix_value(@ptr, string, byte_length), FREE_METHOD)
        bytesize = byte_length.read_int
        return nil if bytesize <= 0
        ::MessagePack.unpack(byte_pointer.get_bytes(0, bytesize))
      end
    end
  end
end
