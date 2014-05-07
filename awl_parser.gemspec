Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'awl_parser'
  s.version = '0.0.1'
  s.summary = "Parser for Step7 AWL files"
  s.description = "Parslet based parser for AWL files generated by Step7"

  s.required_ruby_version = '>= 1.9.3'
  s.required_rubygems_version = '>= 1.8.11'

  s.license = 'MIT'

  s.author = 'Tallak Tveide'
  s.email = 'tallak@tveide.net'
  s.homepage = 'http://github.com/tallakt/awl_parser'

  s.files = ['README.md'] + Dir['spec/**/*'] + Dir['lib/**/*']

  s.add_dependency "parslet"
end