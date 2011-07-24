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
    require 'fssm'

    project.make

    threads = Array.new
    monitor = lambda { |path, &blk|
      updated = lambda { |path, file|
        status "Updated #{file}"
        blk.call
      }

      FSSM.monitor(path) do
        update(&updated)
        create(&updated)
        delete(&updated)
      end
    }

    # Monitor the project's files
    project.config.files.each do |group|
      threads << Thread.new {
        path = project.root(group.source)
        path = path.gsub(/\*.*$/, '')
        path = File.realpath(path)

        monitor.call(path) { project.make }
      }
    end

    # Monitor the project's manual
    threads << Thread.new {
      monitor.call(project.manual) { project.make }
    }


    # Monitor ProScribe's default theme
    threads << Thread.new {
      monitor.call(ProScribe.root('data')) { project.make }
    }

    threads << Thread.new {
      Dir.chdir(project.dir) {
        status "Starting Proton server"
        system "proton start", *ARGV[1..-1]
      }
    }

    threads.each { |t| t.join }
  end
  task.description = "Starts a preview server on localhost"
end
  
