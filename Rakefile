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

desc "Start irb with some stuff already required"
task :console do
  puts "To initialize a parser quickly, type:"
  puts "  p = AwlTool::Parser::Parser.new"
  puts 
  sh "irb -I ./lib -r ./lib/awltool/parser/parser.rb -r parslet/convenience -r ./lib/awltool/structures"
end

task :default => [:spec, :doctest]

