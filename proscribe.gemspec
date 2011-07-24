require './lib/proscribe/version'

Gem::Specification.new do |s|
  s.name = "proscribe"
  s.version = ProScribe.version
  s.summary = %{Documentation generator.}
  s.description = %Q{Build some documentation for your projects of any language.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/proscribe"
  s.files = Dir["{bin,lib,test}/**/*", "*.md", "Rakefile"].reject { |f| File.directory?(f) }
  s.executables = Dir["bin/*"].map { |f| File.basename(f) }

  s.add_dependency "hashie", "~> 1.0.0"
  s.add_dependency "shake", "~> 0.1.2"
  s.add_dependency "tilt", "~> 1.3.2"
  s.add_dependency "proton", "~> 0.3.3"
end
