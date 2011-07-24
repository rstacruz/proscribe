# Class: Watcher (ProScribe)
# Monitors files for changes.
#
# ## Common usage
#
#     w = Watcher.new(project) { puts 'update' }
#     w.join
#
module ProScribe
  class Watcher
    def initialize(project, &blk)
      require 'fssm'

      @threads = Array.new

      # Monitor the project's manual
      @threads << Thread.new {
        monitor(project.config.manual) { |*a| project.make; yield *a }
      }

      # Monitor ProScribe's default theme
      @threads << Thread.new {
        monitor(ProScribe.root('data')) { |*a| project.make; yield *a }
      }

      # Monitor the project's files
      project.config.files.each do |group|
        threads << Thread.new {
          path = project.root(group.source)
          path = path.gsub(/\*.*$/, '')
          path = File.realpath(path)

          monitor(path) { |*a| project.make; yield *a }
        }
      end
    end

    # Attribute: threads (ProScribe::Watcher)
    # The threads.
    # 
    attr_reader :threads

    # Method: join (ProScribe::Watcher)
    # Asks all threads to join.
    #
    def join
      threads.each { |t| t.join }
    end

  private
    def monitor(path, &blk)
      updated = lambda { |path, file|
        yield path, file
      }

      FSSM.monitor(path) do
        update(&updated)
        create(&updated)
        delete(&updated)
      end
    end
  end
end
