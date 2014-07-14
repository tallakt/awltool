require 'awltool/text/helpers'

module AwlTool
  module Structures
    # Represents a reference to a block , eg. `FC 10` or `UDT 5`
    # The type should always be a symbol, line `:udt`
    class BlockRef
      include Comparable

      attr_reader :type, :number

      def initialize(type, number)
        raise "Unsupported type: #{type}" unless [:fb, :fc, :udt, :ob, :db].member? type
        @type, @number = type, number
      end

      def to_s
        "#{type.to_s.upcase} #{number}"
      end

      # For Comparable
      def <=>(other)
        [type, number] <=> [other.type, other.number]
      end
    end
  end
end

