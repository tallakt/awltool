require 'parslet'

# reference: http://support.automation.siemens.com/WW/llisapi.dll?func=cslib.csinfo&lang=en&objid=18652056&caller=view
# SIMATIC Programming with STEP 7 Manual
# Chapter 13.4 ff

module AwlParser
  class Parser < Parslet::Parser

    def nocase(string) 
      string.chars.map do |c| 
        chars = [c, c.downcase].uniq
        if chars.size >= 2
          match("[#{chars.join}]") 
        else
          str(c)
        end
      end.reduce(&:>>)
    end

    rule :space do
      match("[ \t]")
    end

    rule :ws do
      space.repeat(0)
    end

    rule :ws_nl do
      (ws >> newline) >> (space | newline).repeat(0)
    end

    rule :comment do
      str("//") >> (newline.absent? >> any).repeat
    end

    rule :newline do
      str("\r\n") | str("\n")
    end

    rule :symbol do
      match("[A-Za-z]") >> match("[A-Za-z0-9_]").repeat(0)
    end

    rule :caps_symbol do
      match("[A-Z]") >> match("[A-Z0-9_]").repeat(0)
    end

    rule :property do
      # rather broad
      caps_symbol >> ws >> 
        (str(":") >> ws >> (newline.absent? >> any).repeat(0)).maybe
    end

    rule :attributes do
      str("{") >> attrib_entry >> (str(";") >> ws >> attrib_entry).repeat(0) >> str("}")
    end

    rule :attrib_entry do
      symbol >> ws >> str(":=") >> ws >>
        str("'") >> (str("'").absent? >> any).repeat(0) >> str("'")
    end

    rule :title do
      nocase("TITLE") >> ws >> str("=") >> ws >> (newline.absent? >> any).repeat(0)
    end

    rule :var_decl do
      symbol >> ws >> str(":") >> ws >> basic_data_type >> str(";") >> ws >> comment.maybe
    end


    # declare a rule for each keyword data type named eg. :kw_real matching
    # the name case insensitive. Also make a rule matching any of these called
    # :basic_data_type
    %w(INT DINT BOOL BYTE WORD DWORD TIME_OF_DAY REAL TIME S5TIME DATE CHAR).tap do |keywords|
      keywords.each do |kw|
        rule "kw_#{kw.downcase}".to_sym do
          nocase(kw)
        end
      end

      rule :basic_data_type do
        keywords.map {|kw| send "kw_#{kw.downcase}".to_sym }.reduce(&:|)
      end
    end


    rule :struct do
      nocase("STRUCT") >> ws_nl >>
        (ws >> var_decl >> ws_nl).repeat(0) >>
        ws >> nocase("END_STRUCT;")
    end

    rule :value do
      int_value | true_false | float_value | quoted # more?
    end

    rule :positive_int do
      match("[1-9]") >> match("[0-9]").repeat(0)
    end

    rule :int_value do
      str("-").maybe >> positive_int
    end

    rule :float_value do
      int_value >> str(".") >> match("[0-9]").repeat
    end

    rule :true_false do
      nocase("TRUE") | nocase("FALSE")
    end

    rule :assign_inital_values do
      assign_initial_value >> (ws_nl >> assign_initial_value).repeat(0)
    end

    rule :assign_initial_value do
      symbol >> ws >> str(":=") >> ws >> value >> ws >> str(";") >> ws >> comment.maybe
    end

    rule :quoted do
      str('"') >> (str('"').absent? >> any).repeat >> str('"')
    end

    %w(DB OB FB FC UDT).tap do |blocks|
      blocks.each do |b|
        rule "#{b.downcase}_name".to_sym do
          (nocase(b) >> int_value) | quoted
        end
      end
    end

    rule :db do
      nocase("DATA_BLOCK") >> ws >> db_name >> ws_nl >>
        title >> ws_nl >>
        (struct | udt_name | fb_name) >> ws_nl >>
        nocase("BEGIN") >> ws >> comment.maybe >> ws_nl >>
        (assign_inital_values >> ws_nl).maybe >>
        nocase("END_DATA_BLOCK")
    end

    rule :udt do
      nocase("TYPE") >> ws >> udt_name >> ws_nl >>
        struct >> ws_nl >>
        nocase("END_TYPE")
    end
  end
end
