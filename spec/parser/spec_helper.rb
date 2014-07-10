# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

def parse_and_transform(data, parser, opts = {})
  require 'awesome_print'
  puts if opts[:debug]
  puts "[INPUT]" if opts[:debug]
  data.lines.each_with_index {|l,i| puts "%02d %s" % [i+1,l] } if opts[:debug]

  tree = parser.parse data.strip, trace: true
  puts "[PARSE TREE]" if opts[:debug]
  ap tree if opts[:debug]

  transformed = AwlTool::Parser::Transform.new.apply tree
  puts "[TRANSFORMED DATA]" if opts[:debug]
  ap transformed if opts[:debug]

  puts "[END]" if opts[:debug]

  transformed
end
