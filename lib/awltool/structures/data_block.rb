module AwlTool
  module Structures
    class DataBlock
      # the identifier of the data block. The name is stored in the same manner
      # as in the source AWL file. You might have to look up the name in the
      # symlist of the project in order to get the symbolic name, depending on
      # whether the AWL was exported with or without symbolic representation.
      attr_reader :name

      # the block comment at the start of the source file section
      attr_reader :comment

      # the properties from the data block header section
      attr_reader :properties

      # the attributes from the data block header section
      attr_reader :attributes

      # contains an array of variables, much like a struct definition
      # see AwlTool::Structures::Variable
      attr_reader :variables

      # this one is generally called by the parser code
      def initialize(name, comment, properties, attributes, fields)
        @name, @comment, @properties, @attributes, @fields = 
          name, comment, properties, attributes, fields
      end
    end
  end
end
