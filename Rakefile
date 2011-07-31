# Subject to debate.
task :default do
  exec 'rake -s -T'
end

desc "Runs tests."
task :test do
  $:.unshift File.join(File.dirname(__FILE__), 'test')

  Dir['test/{unit,stories}/*.rb'].each { |file| load file }
end

namespace :doc do
  desc "Update documentation."
  task :update do
    # gem proscribe ~> 0.0.2
    system "proscribe build"
  end

  desc "Updates the Aura homepage with the manual."
  task :deploy => :update do
    # http://github.com/rstacruz/git-update-ghpages
    system "git update-ghpages rstacruz/proscribe --branch gh-pages -i doc/"
  end
end
