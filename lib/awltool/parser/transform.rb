require 'parslet'
require 'awltool/structures'

module AwlTool
  module Parser
    class Transform < Parslet::Transform
      include ::AwlTool::Structures

      # ranges
      rule(range_begin: simple(:b), range_end: simple(:e)) { b.to_i .. e.to_i }

      # This rule matches general cases where you have 
      # x.as(:first) >> (ws >> x).repeat.as(:rest)
      # They are combined to a single array
      rule(first: simple(:f), rest: sequence(:r)) { [f] + r }

      # matching a variable with a simple type
      rule(name: simple(:n), array: sequence(:a), basic_type: simple(:b), comment: simple(:c)) do
        basic = BasicTypes.from_s(b.to_s)
        Variable.new n.to_s, ArraySpec.new(a, basic), c.to_s.strip
      end

      rule(var_section: simple(:v), declarations: sequence(:d)) do
        VarSection.new VarSection.from_s(v.to_s), d
      end
    end
  end
end
