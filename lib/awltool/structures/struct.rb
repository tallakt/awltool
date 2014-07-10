module AwlTool
  module Structures
    # represents a Step7 Struct type
    class Struct
      # contains an array containing the variables inside the struct
      # see AwlTool::Structures::Variable
      attr_reader :variables

      attr_reader :comment

      def initialize(variables, comment)
        @variables, @comment = variables, comment
      end

      def to_s
        cc = (comment && " comment: #{comment.inspect}") || ""
        "#<Struct#{cc} ...>\n" + variables.map {|x| x.to_s.lines.map {|x| "  #{x}"} }.join("\n")
      end
    end
  end
end
