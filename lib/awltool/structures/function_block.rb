module AwlTool
  module Structures
    class FunctionBlock
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

      # the variables in the VAR_INPUT section
      # see AwlTool::Structures::Variable
      attr_reader :input

      # the variables in the VAR_OUTPUT section
      # see AwlTool::Structures::Variable
      attr_reader :output

      # the variables in the VAR_IN_OUT section
      # see AwlTool::Structures::Variable
      attr_reader :in_out

      # the variables in the VAR (STAT) section
      # see AwlTool::Structures::Variable
      attr_reader :stat

      # the variables in the TEMP section
      # see AwlTool::Structures::Variable
      attr_reader :temp

      # an array of code networks
      attr_reader :networks

      # this one is generally called by the parser code
      def initialize(name, comment, properties, attributes, input, output, in_out,
                     stat, temp, networks)
        @name = name
        @comment = comment
        @properties = properties
        @attributes = attributes
        @input = input
        @output = output
        @in_out = in_out
        @stat = stat
        @temp = temp
        @networks = networks
      end
    end
  end
end
