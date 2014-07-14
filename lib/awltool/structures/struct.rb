require 'awltool/text/helpers'

module AwlTool
  module Structures
    # represents a Step7 Struct type
    class Struct
      include AwlTool::Text::Helpers

      # contains an array containing the variables inside the struct
      # see AwlTool::Structures::Variable
      attr_reader :variables
      attr_reader :comment

      def initialize(variables, comment)
        @variables, @comment = variables, comment
      end

      def to_s
        cc = (comment && " #{as_comment comment}") || ""
        "STRUCT#{cc}\n#{indent(variables.map(&:to_s).join("\n"))}\nEND_STRUCT ;"
      end
    end
  end
end
