module AwlTool
  module Structures
    # The String class represents the String type with a specified length
    class StringType
      attr_reader :length

      def initialize(length)
        @length = length
      end

      def to_s
        "String[#{length}]"
      end

      class << self
        # Step7 strings are escaped in the source code. This function will
        # convert a regular ruby string to the S7 escaped version
        # [`$$`]  Converted to "$"
        # [`$'`]  Converted to "'"
        # [`$L`]  Converted to "\n"
        # [`$R`]  Converted to "\r"
        # [`$P`]  Converted to "\f"
        # [`$T`]  Converted to "\t" 
        #
        #   >> require 'awltool/structures'
        #   >> AwlTool::Structures::StringType::escape "Awltool rock's"
        #   => "Awltool rock$'s"
        #
        def escape(str)
          str.
            gsub(/\$|'|\t|\r|\n|\f/) do |match|
              case match
              when "$"
                "$$"
              when "'"
                "$'"
              when "\n"
                "$L"
              when "\r"
                "$R"
              when "\t"
                "$T"
              when "\f"
                "$P"
              end
            end
        end

        # See #escape
        #
        #   >> require 'awltool/structures'
        #   >> AwlTool::Structures::StringType::unescape "one$ltwo$lthree$l"
        #   => "one\ntwo\nthree\n"
        #
        def unescape(escaped_string)
          escaped_string.
            gsub(/\$\$|\$'|\$L|\$P|\$R|\$P|\$T/i) do |match|
              case match
              when "$$"
                "$"
              when "$'"
                "'"
              when "$L", "$l"
                "\n"
              when "$R", "$r"
                "\r"
              when "$T", "$t"
                "\t"
              when "$P", "$p"
                "\f"
              end
            end
        end
      end
    end
  end
end
