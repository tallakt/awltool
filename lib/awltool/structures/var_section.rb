require 'awltool/text/helpers'

module AwlTool
  module Structures
    # represents a Step7 Struct type
    class VarSection
      include AwlTool::Text::Helpers

      # contains an array containing the variables inside the var section which
      # be var, var_input, etc
      # see AwlTool::Structures::Variable
      attr_reader :variables

      attr_reader :section_type

      ALL = [:var, :var_input, :var_output, :var_temp, :var_in_out]

      # :nodoc:
      LOOKUP = Hash[ALL.map {|x| [x.to_s, x] }]

      class << self
        # Convert a parsed string to one of the valid symbol types, eg. VAR_INPUT
        #
        #   >> require 'awltool/structures'
        #   >> AwlTool::Structures::VarSection::from_s "VAR_TEMP"
        #   => :var_temp
        #
        def from_s(section_type)
          LOOKUP[section_type.downcase] || raise("Illegal section type: #{section_type}")
        end
      end

      def initialize(section_type, variables)
        raise "Please use a predefined section type" unless ALL.member? section_type
        @section_type, @variables = section_type, variables
      end

      def to_s
        "#{section_type.to_s.upcase}\n#{indent variables.to_s}\nEND_VAR ;"
      end
    end
  end
end
