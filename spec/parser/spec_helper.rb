# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require 'parslet'
require 'parslet/convenience'

def parse_and_transform(data, parser, opts = {})
  require 'awesome_print'
  puts if opts[:debug]
  puts "[INPUT]" if opts[:debug]
  data.lines.each_with_index {|l,i| puts "%02d %s" % [i+1,l] } if opts[:debug]

  tree = parser.parse_with_debug data.strip
  raise "Parsing failed" unless tree
  puts "[PARSE TREE]" if opts[:debug]
  ap tree if opts[:debug]

  transformed = AwlTool::Parser::Transform.new.apply tree
  puts "[TRANSFORMED DATA]" if opts[:debug]
  ap transformed if opts[:debug]

  puts "[END]" if opts[:debug]

  transformed
end
