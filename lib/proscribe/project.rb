# Class: Project (ProScribe)
# A project.
#
# ## Internal usage
#
#     p = Project.new(config_file)
#
module ProScribe
  class Project
    # Attribute: config (ProScribe::Project)
    # Returns a hash of the project's configuration, pulled from Scribefile.
    #
    attr_reader :config

    def initialize(config_file)
      @root   = File.dirname(config_file)
      @config = Hashie::Mash.new(YAML::load_file(config_file))

      # Defaults
      @config.manual  ||= '.'
      @config.output  ||= 'doc'
      @config.files   ||= Array.new
    end

    # Attribute: root (ProScribe::Project)
    # Returns the root path.
    #
    # ##  Usage
    #     project.root
    #     project.root(*args)
    #
    def root(*a)
      File.join(@root, *a)
    end

    # Attribute: manual_path (ProScribe::Project)
    # Returns the absolute path to the projects's manual.
    #
    def manual_path
      root(@config.manual)
    end

    # Method: make (ProScribe::Project)
    # Creates the temp dir from the project's manual and inline comments.
    #
    def make
      dir

      # Copy the files over
      copy_files ProScribe.root('data/default/'), dir

      # Copy manual files over
      copy_files manual_path, dir, :except => ['Gemfile', 'Gemfile.lock', 'config.ru']

      # Extract block comments
      config.files.each do |group|
        ex = ProScribe::Extractor.new Dir[root(group.source)]
        ex.write! File.join(dir, group.prefix || '')
      end
    end

    # Attribute: dir (ProScribe::Project)
    # Returns the path to the temporary Proton project.
    #
    def dir(*a)
      @dir ||= begin
        dir = File.join(Dir.tmpdir, File.basename(root) + Time.now.to_i.to_s)
        FileUtils.rm_rf dir
        FileUtils.mkdir_p dir
        dir
      end

      File.join(@dir, *a)
    end

  private

    def copy_files(from, to, options={})
      exceptions = options[:except] || []

      Dir["#{from}/**/*"].each do |f|
        next  unless File.file?(f)
        next  if exceptions.include?(File.basename(f))

        target = File.join(to, f.gsub(from, ''))

        FileUtils.mkdir_p File.dirname(target)
        FileUtils.cp f, target
      end
    end
  end
end
