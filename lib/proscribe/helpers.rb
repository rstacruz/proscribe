# Module: Helpers (ProScribe)
# Useful functions for the CLI runner.
# 
module ProScribe
  module Helpers
    def project
      @project ||= begin
        config = find_config_file
        Dir.chdir(File.dirname(config))  if config
        Project.new(config)  if config
      end

      @project || pass(no_project)
    end

    def no_project
      "Error: no Scribefile file found."
    end

    def find_config_file
      %w(Scribefile).inject(nil) { |a, fname| a ||= find_in_project(fname) }
    end

    def status(msg)
      puts " * #{msg}"
    end

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
