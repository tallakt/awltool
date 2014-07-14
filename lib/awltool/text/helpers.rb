module AwlTool
  module Text
    # These are used in the to_s methods
    module Helpers
      def indent(string)
        string.lines.map {|l| "  #{l}"}.join
      end

      def attr_to_s(attributes)
        if attributes
          "{ #{attributes.map {|p| p.join " := "}.join ", "} }\n"
        else 
          ""
        end
      end

      def block_name_to_s(name)
        case name
        when AwlTool::Structures::BlockRef
          name.to_s
        else
          %Q["#{name}"]
        end
      end

      def props_to_s(properties)
        if properties
          "#{attributes.map {|p| p.join " : "}.join "\n"} }\n"
        else
          ""
        end
      end

      def as_comment(comment)
        comment.lines.map {|c| "// #{c}" }.join "\n"
      end

      def type_to_s(type)
        case type
        when Symbol
          type.to_s.upcase
        else
          type.to_s
        end
      end
    end
  end
end

