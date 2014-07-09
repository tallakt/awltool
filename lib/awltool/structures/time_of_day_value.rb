module AwlTool
  module Structures
    # This class represents the TIME_OF_DAY basic data type in step7
    class TimeOfDayValue
      include Comparable

      attr_reader :hours, :minutes, :seconds

      def initialize(hours, minutes, seconds)
        @hours, @minutes, @seconds = hours, minutes, seconds
      end

      def to_s
        "TOD##{@hours}:#{@minutes}:#{@seconds}"
      end

      # This one is used by rspec to check the results
      def <=>(other)
        [self, other].map {|x| [x.hours, x.minutes, x.seconds] }.reduce(&:<=>)
      end
    end
  end
end



