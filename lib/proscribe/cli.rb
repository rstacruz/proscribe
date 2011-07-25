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
    path   = project.root(project.config.output)
    where  = params[0] or wrong_usage
    prefix = params[1] || ''
    repo   = "git@github.com:#{where}.git"

    puts "Fetching #{repo} (gh-pages)"

    gitdeploy(repo, "gh-pages", prefix)
  end
  task.usage = "gh-pages username/repo [dirprefix]"
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

  def self.gitdeploy(dest, branch, prefix='')
    project
    path = project.root(project.config.output)

    temppath = File.join(Dir.tmpdir, "proton-#{Time.now.to_i}")
    FileUtils.rm_rf temppath

    # Clone the gh-pages branch.
    system "git clone #{dest} -b #{branch} #{temppath}"

    current_branch = Dir.chdir(temppath) { `git symbolic-ref HEAD`.strip.split('/') }

    if current_branch.last == branch
      puts "Adding files to #{prefix}/..."
      # Did we get the correct branch? Just add on top of it.
      copy_files path, File.join(temppath, prefix)

      #system "(git add .; git add -u; git commit -m .) > /dev/null"
      puts "git push origin #{branch}"
      system "(git add .; git add -u; git commit -m .)"
      system "git push origin #{branch}"

    else
      puts "Warning: No #{branch} branch found, starting over."

      # Else, clean it and start over.
      FileUtils.rm_rf temppath
      FileUtils.mkdir temppath

      copy_files path, File.join(temppath, prefix)

      Dir.chdir(temppath) {
        system "(git init . && git add . && git commit -m .) > /dev/null"
        system "git push #{dest} master:#{branch} --force"
      }
    end

    # FileUtils.rm_rf temppath
  end

end
