module Gem
  class << self

    # Versioned Ruby directory name for demodularized packages
    RUBY_VERSION_DIR_NAME = 'ruby4.0'

    def default_locations
      @default_locations ||= {
        :system => '/usr',
        :local => '/usr/local'
      }
    end

    ##
    # For each location provides set of directories for binaries (:bin_dir)
    # platform independent (:gem_dir) and dependent (:ext_dir) files.

    def default_dirs
      @default_dirs ||= default_locations.inject(Hash.new) do |hash, location|
        destination, path = location

        hash[destination] = if path
          {
            :bin_dir => File.join(path, RbConfig::CONFIG['bindir'].split(File::SEPARATOR).last),
            :gem_dir => File.join(path, RbConfig::CONFIG['datadir'].split(File::SEPARATOR).last, RUBY_VERSION_DIR_NAME, 'gems', RUBY_VERSION_DIR_NAME),
            :ext_dir => File.join(path, RbConfig::CONFIG['libdir'].split(File::SEPARATOR).last, 'gems')
          }
        else
          {
            :bin_dir => '',
            :gem_dir => '',
            :ext_dir => ''
          }
        end

        hash
      end
    end

    ##
    # Remove methods we are going to override. This avoids "method redefined;"
    # warnings otherwise issued by Ruby.

    remove_method :default_dir if method_defined? :default_dir
    remove_method :default_specifications_dir if method_defined? :default_specifications_dir
    remove_method :default_path if method_defined? :default_path
    remove_method :default_bindir if method_defined? :default_bindir
    remove_method :default_ext_dir_for if method_defined? :default_ext_dir_for

    ##
    # RubyGems default overrides.

    def default_dir
      if Process.uid == 0
        Gem.default_dirs[:local][:gem_dir]
      else
        Gem.user_dir
      end
    end

    ##
    # Path to specification files of default gems.

    def default_specifications_dir
      @default_specifications_dir ||= File.join(Gem.default_dirs[:system][:gem_dir], "specifications", "default")
    end

    ##
    # Default gem load path

    def default_path
      path = default_dirs.collect {|location, paths| paths[:gem_dir]}
      path.unshift Gem.user_dir if File.exist? Gem.user_home
      path
    end

    def default_bindir
      if Process.uid == 0
        Gem.default_dirs[:local][:bin_dir]
      else
        File.join [Dir.home, 'bin']
      end
    end

    def default_ext_dir_for base_dir
      dirs = Gem.default_dirs.detect {|location, paths| paths[:gem_dir] == base_dir}
      dir = dirs && dirs.last[:ext_dir]
      dir && File.join(dir, RbConfig::CONFIG['RUBY_INSTALL_NAME'])
    end


    # This method should be available since RubyGems 2.2 until RubyGems 3.0.
    # https://github.com/rubygems/rubygems/issues/749
    if method_defined? :install_extension_in_lib
      remove_method :install_extension_in_lib

      def install_extension_in_lib
        false
      end
    end
  end
end
