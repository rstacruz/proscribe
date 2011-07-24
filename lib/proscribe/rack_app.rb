require 'proton'
require 'proton/server'
require 'shake'

# Module: RackApp (ProScribe)
# Provides a Rack app.
#
# ## Usage
#
# Use {ProScribe.rack_app}.
#
module ProScribe
  module RackApp
    def self.run!
      config  = Shake.find_in_project("Scribefile") or return
      project = ProScribe::Project.new(config)
      project.make

      watcher = ProScribe::Watcher.new(project) { |_, file| puts "Updated #{file}" }

      proton = Proton::Project.new(project.dir)

      Proton::Server
    end
  end
end
