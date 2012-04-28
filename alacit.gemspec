# Ensure we require the local version and not one we might have installed already
$:.push File.expand_path('../lib', __FILE__)
require 'version'

spec = Gem::Specification.new do |s| 
  s.name = 'alacit'
  s.version = AlacIt::VERSION
  s.author = 'Russell H. Brooks'
  s.email = 'me@russbrooks.com'
  s.homepage = 'http://russbrooks.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'APE, FLAC, and WAV to Apple Lossless (ALAC) batch conversion utility.'
  s.description = 'Quickly convert entire directories of APE, FLAC, and WAV files to Apple Lossless (ALAC) for importation into iTunes, iPhones, iPads, and iPods.'
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.has_rdoc = false
  s.bindir = 'bin'
  s.add_development_dependency('rake')
end
