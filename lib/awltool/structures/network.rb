module AwlTool
  module Structures
    # This class represents a single network in an FC, FB or OB
    class Network
      attr_reader :title
      attr_reader :comment
      attr_reader :code

      def initialize(title, comment, code)
        @title, @comment, @code = title, comment, code
      end
    end
  end
end
