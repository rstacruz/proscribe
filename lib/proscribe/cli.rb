# Class: CLI (ProScribe)
# The CLI runner.
#
class ProScribe::CLI < Shake
  include Shake::Defaults
  extend ProScribe::Helpers

  task(:build) do

    project.make
    pass project.dir  if ARGV.delete('-d') || ARGV.delete('--debug')

    require 'proton'
    pro = Proton::Project.new project.dir
    pro.build { |file|
      puts "* %-35s %-35s" % [ file, "(#{file.path})" ]
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
    dir = Dir.pwd
    project
    copy_files ProScribe.root('data/rack'), dir
  end
  task.description = "Makes a project Rack-compatible"

  invalid do
    if task(command)
      usage = task(command).usage || command

      err "Invalid usage."
      err "Usage: #{executable} #{usage}"
      err "See `#{executable} help` for more info."
    else
      err "Unknown command: #{command}"
      err "See `#{executable} help` for a list of commands."
    end
  end
end
