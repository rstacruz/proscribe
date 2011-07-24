module ProScribe
  class Project
    attr_reader :config

    def initialize(config_file)
      @root   = File.dirname(config_file)
      @config = Hashie::Mash.new(YAML::load_file(config_file))

      # Defaults
      @config.manual  ||= '.'
      @config.output  ||= 'doc'
      @config.files   ||= Array.new
    end

    def root(*a)
      File.join(@root, *a)
    end

    def manual_path
      root(@config.manual)
    end

    def make
      dir

      # Copy the files over
      copy_files ProScribe.root('data/default/'), dir
      copy_files manual_path, dir

      # Extract block comments
      config.files.each do |group|
        ex = ProScribe::Extractor.new Dir[root(group.source)]
        ex.write! File.join(dir, group.target)
      end
    end

    def dir(*a)
      @dir ||= begin
        dir = File.join(Dir.tmpdir, File.basename(root))
        FileUtils.rm_rf dir
        FileUtils.mkdir_p dir
        dir
      end

      File.join(@dir, *a)
    end

  private

    def copy_files(from, to)
      Dir["#{from}/**/*"].each do |f|
        next  unless File.file?(f)
        target = File.join(to, f.gsub(from, ''))

        FileUtils.mkdir_p File.dirname(target)
        FileUtils.cp f, target
      end
    end
  end
end
