require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

#require 'rdoctest/task'
#Rdoctest::Task.new

desc "Build the gem file"
task :gem do
  sh "gem build awltool.gemspec"
end

desc "Run doctests"
task :doctest do
  # RDocTest task doesnt seem to work
  sh "rdoctest lib/**/*.rb"
end

task :default => [:spec, :doctest]

