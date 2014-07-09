module AwlTool
  module Structures
    # Represents any of the built in timers
    class Timer
      # The index of the timer, eg. for T 100 it will be 100
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def to_s
        "T #{number}"
      end
    end
  end
end



