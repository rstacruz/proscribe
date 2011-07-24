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
    dir = Dir.pwd
    project
    copy_files ProScribe.root('data/rack'), dir
  end
  task.description = "Makes a project Rack-compatible"

  # proscribe ghpages rstacruz/proscribe
  task (:'gh-pages') do
    project
    path  = project.root(project.config.output)
    where = params.first or wrong_usage
    repo  = "git@github.com:#{where}.git"

    status "Deploying to #{repo}..."
    status "(WARNING: This will overwrite history. Press ^C to abort.)"

    gitdeploy(repo, "gh-pages")
  end
  task.usage = "gh-pages username/repo"
  task.description = "Deploy to GitHub pages"

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

  def self.gitdeploy(dest, branch)
    project
    path = project.root(project.config.output)

    temppath = File.join(Dir.tmpdir, "proton-#{Time.now.to_i}")
    copy_files path, temppath

    Dir.chdir(temppath) {
      system "(git init . && git add . && git commit -m .) > /dev/null"
      system "git push #{dest} master:#{branch} --force"
    }

    FileUtils.rm_rf temppath
  end

end
