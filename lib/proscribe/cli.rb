# Class: CLI (ProScribe)
# The CLI runner.
#
class ProScribe::CLI < Shake
  include Shake::Defaults
  extend ProScribe::Helpers

  task(:build) do
    project.make
    pass project.dir  if ARGV.delete('-d') || ARGV.delete('--debug')

    Dir.chdir(project.dir) {
      system "proton build"
    }

    copy_files project.dir('_output'), project.root(project.config.output)
  end
  
  task.description = "Builds the project files"

  task(:start) do
    project.make

    w = ProScribe::Watcher.new(project) { |path, file| status "Updated #{file}" }

    server = Thread.new {
      Dir.chdir(project.dir) {
        status "Starting Proton server"
        system "proton start", *ARGV[1..-1]
      }
    }

    w.join
    server.join
  end
  task.description = "Starts a preview server on localhost"

  task(:rack) do
    project
    copy_files ProScribe.root('data/rack'), project.root
  end
  task.description = "Makes a project Rack-compatible"
end
  
