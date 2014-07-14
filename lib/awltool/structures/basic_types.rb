module AwlTool
  module Structures
    # Basic types are representes as ruby symbols. This
    # module just lists them
    module BasicTypes
      ALL = [ :int, :dint, :bool, :byte, :word, :dword, :time_of_day, :real,
        :s5time, :char, :date_and_time, :time, :date, :timer, :counter, :pointer, :any ]

      LOOKUP = Hash[ALL.map {|t| [t.to_s, t] }]

      # returns any of the accepted basic type symbols based on the input
      # string which may be in any case. Used by the parser
      #
      #   >> require 'awltool/structures'
      #
      #   >> AwlTool::Structures::BasicTypes.from_s 'Bool'
      #   => :bool
      #
      #   >> AwlTool::Structures::BasicTypes.from_s 'Time_Of_Day'
      #   => :time_of_day
      #
      class << self
        def from_s(basic_type_string)
          LOOKUP[basic_type_string.downcase] || raise("Illegal basic type: #{basic_type_string}")
        end


        def to_s(type, value)
          case type
          when :byte
            "B#16##{value.to_s(16)}"
          when :word
            "B#16##{value.to_s(16)}"
          when :dword
            "DW#16##{value.to_s(16)}"
          when :dint
            "L##{value}"
          when :real
            value.to_s
          when :bool
            if value then "TRUE" else "FALSE" end
          when :s5time
            # TODO
          when :time
            # TODO
          when :time_of_day
            # TODO
          when :date
            # TODO
          end

#
      #rule :time_of_day_value do
        #nocase("TOD") >> match("[#_]") >> 
        #(
          #digits >> 
          #str(":") >> 
          #digits >> 
          #str(":") >> 
          #digits >>
          #str(".") >> 
          #digits
        #).as(:time_of_day_value)
      #end
#
      #rule :generic_time_value do
        #(digits.as(:int_value) >> nocase("D")).maybe.as(:d) >>
        #(digits.as(:int_value) >> nocase("H")).maybe.as(:h) >>
        #(digits.as(:int_value) >> (nocase("M") >> nocase("S").absent?)).maybe.as(:m) >>
        #(digits.as(:int_value) >> nocase("S")).maybe.as(:s) >>
        #(digits.as(:int_value) >> nocase("MS")).maybe.as(:ms)
      #end
#
      #rule :date_value do
        #nocase("D") >> match("[#_]") >> 
        #(digits >> str("-") >> digits >> str("-") >> digits).as(:date_value) 
      #end
#
      #rule :date_and_time_value do
        #nocase("DT") >> match("[#_]") >> 
        #(
          #digits >> 
          #str("-") >>
          #digits >> 
          #str("-") >>
          #digits >>
          #str("-") >>
          #digits >> 
          #str(":") >> 
          #digits >> 
          #str(":") >> 
          #digits >>
          #str(".") >> 
          #digits
        #).as(:date_and_time_value)

        end
      end
    end
  end
end

