require 'yaml'
require 'fileutils'
require 'tmpdir'
require 'shake'
require 'hashie'
require 'tilt'

# Module: ProScribe
# The main module.
#
module ProScribe
  def self.root(*a)
    File.join(File.expand_path('../../', __FILE__), *a)
  end

  PREFIX = File.expand_path('../', __FILE__)

  autoload :Project,    "#{PREFIX}/proscribe/project"
  autoload :Helpers,    "#{PREFIX}/proscribe/helpers"
  autoload :CLI,        "#{PREFIX}/proscribe/cli"
  autoload :Extractor,  "#{PREFIX}/proscribe/extractor"
  autoload :Watcher,    "#{PREFIX}/proscribe/watcher"
  autoload :RackApp,    "#{PREFIX}/proscribe/rack_app"

  require "#{PREFIX}/proscribe/version"

  # Class method: rack_app (ProScribe)
  # Returns a Rack app for the current dir's ProScribe project.
  #
  # ## Usage
  #
  #     [config.ru (ruby)]
  #     require 'proscribe'
  #     run ProScribe.rack_app
  #
  def self.rack_app
    RackApp.run! && Proton::Server
  end
end

