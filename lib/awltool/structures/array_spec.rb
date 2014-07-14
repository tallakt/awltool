require 'awltool/text/helpers'

module AwlTool
  module Structures
    class ArraySpec
      # the ranges for the array. for a 2-dimensional range specification in the
      # source file, eg. `ARRAY[ 1..10, 20..29 ] of ...`, ranges would return
      # [1..10, 20..29]
      attr_reader :ranges

      # the type of each array element. Should be either a basic type, UDT 
      # or a struct
      # see AwlTool::Structures::BasicType, AwlTool::Structure::Struct, and 
      # AwlTool::Structures::StringType
      attr_reader :of_type

      # this is generally called by the parser code
      def initialize(ranges, of_type)
        @ranges, @of_type = ranges, of_type
      end

      def to_s
        "ARRAY[ #{ranges.map(&:to_s).join(", ")} ] OF #{type_to_s of_type}" 
      end
    end
  end
end
