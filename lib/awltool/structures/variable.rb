require 'awltool/structures/time_of_day_value'

module AwlTool
  module Structures
    # a single variable definition
    class Variable
      attr_reader :name

      # The type of the variable. Should be one of AwlTool::Structures::BasicType, 
      # AwlTool::Structures::Struct, AwlTool::Strucutres::Array or
      # AwlTool::Structures::String
      attr_reader :of_type

      attr_reader :comment

      # These are special attributes that S7 adds to some variables
      # and are normally not present
      attr_reader :attributes

      def initialize(name, of_type, comment, initial_value, attributes)
        @name, @of_type, @comment = name, of_type, comment
        @initial_value, @attributes = initial_value, attributes
      end

      # the initial value of the variable declaration. The default initial
      # value is returned instead of nil if the <tt>:use_defaults</tt> is used
      #
      #   >> require 'awltool/structures'
      #
      #   >> a = AwlTool::Structures::Variable.new 'a', :bool, "comment", nil, nil
      #   >> a.initial_value
      #   => nil
      #   >> a.initial_value use_defaults: true
      #   => false
      #
      #   >> b = AwlTool::Structures::Variable.new 'b', :time_of_day, "comment", nil, nil
      #   >> b.initial_value use_defaults: true
      #   => TOD#0:0:0.0
      #
      def initial_value(opts = {})
        if opts[:use_defaults]
          type = case of_type
                 when Symbol
                   of_type
                 when StringType
                   :string
                 else
                   raise "Can't provide initial value for type: #{of_type}"
                 end

          @initial_value || Variable::default_initial_for(type)
        else
          @initial_value
        end
      end

      def to_s
        attrib = (attributes && " { #{attributes.map {|k,v| "#{k} : #{v}"}.join(", ") }") || ""
        case of_type
        when Struct
          comment_string = (comment && " // #{comment}") || ""
          struct = of_type.to_s.lines.map {|l| "  " + l }.join("\n")
          "#{name}#{attrib} : #{struct.sub /STRUCT/, "STRUCT#{comment_string}" }"
        else
          init = case initial_value
                 when nil
                   ""
                 when String
                   " := #{initial_value.inspect}"
                 else
                   " := #{initial_value}"
                 end
          comment = (comment && " // #{comment}") || ""
          "#{name}#{attrib} : #{of_type}#{init}#{comment}"
        end
      end

      DEFAULT_INITIAL_VALUES = {
        bool: false,
        byte: 0,
        char: " ",
        word: 0,
        dword: 0,
        int: 0,
        dint: 0,
        real: 0.0,
        s5time: 0,
        time: 0,
        date: Time.utc(1900, 1, 1),
        time_of_day: AwlTool::Structures::TimeOfDayValue.new(0,0,0.0),
        date_and_time: Time.utc(1900, 1, 1),
        string: "",
      }

      class << self
        def default_initial_for(basic_type)
          DEFAULT_INITIAL_VALUES[basic_type]
        end
      end
    end
  end
end

