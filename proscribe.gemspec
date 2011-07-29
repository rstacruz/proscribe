require './lib/proscribe/version'

Gem::Specification.new do |s|
  s.name = "proscribe"
  s.version = ProScribe.version
  s.summary = %{Documentation generator.}
  s.description = %Q{Build some documentation for your projects of any language.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/proscribe"
  s.files = `git ls-files`.strip.split("\n")
  s.executables = Dir["bin/*"].map { |f| File.basename(f) }

  s.add_dependency "hashie", "~> 1.0.0"
  s.add_dependency "shake", "~> 0.1.2"
  s.add_dependency "tilt", "~> 1.2.2"
  s.add_dependency "proton", "~> 0.3.3"
  s.add_dependency "fssm", "~> 0.2.7"
  s.add_dependency "rdiscount", "~> 1.6.8"
end
