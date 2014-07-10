require 'date'
require 'parslet'
require 'awltool/structures'

module AwlTool
  module Parser
    class Transform < Parslet::Transform
      include ::AwlTool::Structures

      # converting basic type values to ruby values
      rule(timer: simple(:t)) { Timer.new t.to_i }
      rule(counter: simple(:c)) { Counter.new c.to_i }
      rule(int_value: simple(:i)) { i.to_i }
      rule(hex_value: simple(:h)) { h.to_s.to_i(16) }
      rule(real_value: simple(:r)) { r.to_f }
      rule(true_value: simple(:_)) { true }
      rule(false_value: simple(:_)) { false }
      rule(msec_value: simple(:ms)) { ms.to_i * 0.001 }
      rule(date_value: simple(:d)) { Date::parse d.to_s }
      rule(date_and_time_value: simple(:dt)) { DateTime::strptime dt.to_s, "%y-%m-%d-%H:%M:%S.%L" }
      rule(string_value: simple(:s)) { StringType::unescape s.to_s }

      rule(time_of_day_value: simple(:tod)) do
        h,m,s = tod.to_s.split /:/
        TimeOfDayValue.new h.to_i, m.to_i, s.to_f
      end

      # s5time and time values - represented as miliseconds fixnum
      rule( d: simple(:d), h: simple(:h), m: simple(:m), s: simple(:s), 
           ms: simple(:ms)) do
        86_400_000 * (d || 0) +
        3_600_000 * (h || 0) +
        60_000 * (m || 0) +
        1_000 * (s || 0) +
        (ms || 0)
      end

      # ranges
      rule(range_begin: simple(:b), range_end: simple(:e)) { b.to_i .. e.to_i }

      # This rule matches general cases where you have 
      # x.as(:first) >> (ws >> x).repeat.as(:rest)
      # They are combined to a single array
      rule(first: simple(:f), rest: sequence(:r)) { [f] + r }

      # Comments are converted to a plain string
      rule(comment: simple(:c)) { c.to_s }

      # matching basic data types like int, word, etc
      rule(basic_data_type: simple(:bdt)) { BasicTypes.from_s(bdt.to_s) }

      # matching string data type
      rule(string_with_length: simple(:len)) { StringType.new len.to_i }

      # matching udt data type
      #rule(string_with_length: simple(:len)) { StringType.new len.to_i }

      # matching a struct type
      # TODO
      # rule(struct_decl: sequence(:d), comment: simple(:c)) { Struct.new d, c }

      # matching a variable declaration  with comment but without ararys
      rule(
        name: simple(:n), 
        type: simple(:t), 
        line_comment: simple(:c), 
        initial: simple(:i),
        attributes: simple(:a)
      ) { Variable.new n.to_s, t, c.to_s, i, a }

      rule(
        name: simple(:n), 
        type: simple(:t), 
        line_comment: simple(:c), 
        initial: simple(:i),
        attributes: simple(:a),
        array: sequence(:arr)
      ) { Variable.new n.to_s, ArraySpec.new(arr, t), c.to_s, i, a }


      # Struct variable without array
      rule(
        name: simple(:n), 
        struct: simple(:struct), 
        attributes: simple(:a)
      ) { Variable.new n.to_s, struct, struct.comment, nil, a }

      # Struct variable with array
      rule(
        name: simple(:n), 
        struct: simple(:struct), 
        attributes: simple(:a),
        array: sequence(:arr)
      ) { Variable.new n.to_s, ArraySpec.new(arr, struct), struct.comment, nil, a }


      # matching a struct
      rule(struct_declarations: sequence(:d), line_comment: simple(:c)) { Struct.new d, c }

      # var section, ie. a complete VAR, VAR_TEMP etc
      rule(var_section: simple(:v), declarations: sequence(:d)) do
        VarSection.new VarSection.from_s(v.to_s), d
      end
    end
  end
end
