module ProScribe
  module Helpers
    def project
      @project ||= begin
        config = find_config_file
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
  end
end
