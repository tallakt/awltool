require File.dirname(__FILE__) + '/lib/awltool'

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'awltool'
  s.version = AwlTool::VERSION
  s.summary = "Manage Step7 AWL files"
  s.description = "Tool for handling Step7 based AWL source code files"

  s.required_ruby_version = '>= 1.9.3'
  s.required_rubygems_version = '>= 1.8.11'

  s.license = 'MIT'

  s.author = 'Tallak Tveide'
  s.email = 'tallak@tveide.net'
  s.homepage = 'http://github.com/tallakt/awltool'

  s.files = ['README.md'] + Dir['spec/**/*'] + Dir['lib/**/*']

  s.add_dependency "parslet"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoctest"
end
