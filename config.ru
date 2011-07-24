require 'bundler'
Bundler.setup

require './lib/proscribe'
run ProScribe.rack_app
