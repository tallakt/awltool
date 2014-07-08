module AwlTool
  module Structures
    # a single variable definition
    class Variable
      attr_reader :name

      # The type of the variable. Should be one of AwlTool::Structures::BasicType, 
      # AwlTool::Structures::Struct, AwlTool::Strucutres::Array or
      # AwlTool::Structures::String
      attr_reader :of_type

      attr_reader :comment

      def initialize(name, of_type, comment)
        @name, @of_type, @comment = name, of_type, comment
      end
    end
  end
end

