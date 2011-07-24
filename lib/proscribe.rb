require 'yaml'
require 'fileutils'
require 'tmpdir'
require 'shake'
require 'hashie'
require 'tilt'

module ProScribe
  def self.root(*a)
    File.join(File.expand_path('../../', __FILE__), *a)
  end

  PREFIX = File.expand_path('../', __FILE__)

  autoload :Project,    "#{PREFIX}/proscribe/project"
  autoload :Helpers,    "#{PREFIX}/proscribe/helpers"
  autoload :CLI,        "#{PREFIX}/proscribe/cli"
  autoload :Extractor,  "#{PREFIX}/proscribe/extractor"

  require "#{PREFIX}/version"
end

