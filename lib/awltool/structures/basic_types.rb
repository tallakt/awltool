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
      end
    end
  end
end

