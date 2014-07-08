module AwlTool
  module Structures
    # The String class represents the String type with a specified length
    class StringType
      attr_reader :length

      def initialize(length)
        @length = length
      end
    end
  end
end
