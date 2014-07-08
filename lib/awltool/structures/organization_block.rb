module AwlTool
  module Structures
    class OrganizationBlock
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

      # the variables in the TEMP section in an array
      # see AwlTool::Structures::Variable
      attr_reader :temp

      # an array of code networks
      attr_reader :networks

      # this one is generally called by the parser code
      def initialize(name, comment, properties, attributes, temp, networks)
        @name = name
        @comment = comment
        @properties = properties
        @attributes = attributes
        @temp = temp
        @networks = networks
      end
    end
  end
end
