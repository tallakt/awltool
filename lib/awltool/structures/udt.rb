require 'awltool/text/helpers'

module AwlTool
  module Structures
    # Represents an UDT data type definition from Step7
    class UDT
      include AwlTool::Text::Helpers

      # the identifier of the data block. The name is stored in the same manner
      # as in the source AWL file. You might have to look up the name in the
      # symlist of the project in order to get the symbolic name, depending on
      # whether the AWL was exported with or without symbolic representation.
      #
      # If the udt is not named, it will be represented as an array with :udt 
      # and a number eg. `[:udt, 20]`. Otherwise the name is a string from the
      # symbol table
      attr_reader :name

      # the properties from the data block header section, in a hash
      attr_reader :properties

      # the attributes from the data block header section, in a hash
      attr_reader :attributes

      # the variables in the UDT, represented as a struct
      # see AwlTool::Structures::Variable
      attr_reader :struct

      # this is generally called by the parser code
      def initialize(name, properties, attributes, struct)
        @name = name
        @properties = properties
        @attributes = attributes
        @struct = struct
      end



      def to_s
        "TYPE #{block_name_to_s name}\n#{attr_to_s attributes}#{props_to_s properties}" + 
        indent(struct.to_s) + 
        "\nEND_TYPE ;"
      end
    end
  end
end
