require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "Build the gem file"
task :gem do
  sh "gem build awltool.gemspec"
end

task :default => :spec

