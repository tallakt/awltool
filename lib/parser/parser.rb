# encoding: utf-8
require 'parslet'

# reference: http://support.automation.siemens.com/WW/llisapi.dll?func=cslib.csinfo&lang=en&objid=18652056&caller=view
# SIMATIC Programming with STEP 7 Manual
# Chapter 13.4 ff
#
# Note. The exmaple AWL files in the referenced documents won't compile at all,
# so these have been regenerated to best effort.

module AwlTool
  module Parser
    class Parser < Parslet::Parser

      def nocase(string) 
        string.upcase.chars.map do |c| 
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
        space.repeat
      end

      rule :wsn do # whitespace, and at least one newline, comment already processed
        (space.repeat >> newline) >> (space | newline | comment).repeat
      end

      rule :cwsn do # comments and witespace, and at least one newline
        (ws >> comment.maybe >> newline) >> (space | newline | comment).repeat
      end

      rule :comment do
        block_comment | line_comment
      end

      rule :comment_nl do # for testing purposes
        comment >> newline
      end

      rule :block_comment do
        str("(*") >> (str("*)").absent? >> any).repeat >> str("*)")
      end

      rule :line_comment do
        str("//") >> (newline.absent? >> any).repeat
      end

      rule :newline do
        str("\r\n") | str("\n")
      end

      rule :symbol do
        match("[A-Za-z]") >> match("[A-Za-z0-9_]").repeat
      end

      rule :caps_symbol do
        match("[A-Z]") >> match("[A-Z0-9_]").repeat
      end

      rule :caps_symbol_except_data_def do
        (nocase("STRUCT") | udt_name | fb_name).absent? >>
        caps_symbol
      end

      rule :property do
        # rather broad
        caps_symbol_except_data_def.as(:key) >> ws >> 
          (str(":") >> ws >> ((newline.absent? >> any).repeat).maybe.as(:value))
      end

      rule :attributes do
        str("{") >> ws >> attrib_entry.as(:first) >> ws >> 
          (str(";") >> ws >> attrib_entry).repeat.as(:rest) >> ws >> str("}")
      end

      rule :attrib_entry do
        symbol.as(:name) >> ws.maybe >> str(":=") >> ws.maybe >>
          str("'") >> (str("'").absent? >> any).repeat.as(:value) >> str("'")
      end

      rule :title do
        nocase("TITLE") >> ws >> str("=") >> ws >> (newline.absent? >> any).repeat
      end

      rule :var_decl do
        symbol >> ws >> str(":") >> (ws >> array_specification).maybe >> ws >> 
          (
            (basic_data_type >> ws >> (str(":=") >> ws >> value >> ws).maybe) | 
            struct
          ) >> ws >> str(";") >> 
          ws >> comment.maybe
      end

      rule :array_specification do
        nocase("ARRAY") >> ws >> 
          str("[") >> ws >> array_ranges >> str("]") >> 
          ws >> nocase("OF")
      end

      rule :array_ranges do
        array_range >> (ws >> str(",") >> ws >> array_range).repeat
      end

      rule :array_range do
        int_value >> ws >> str("..") >> ws >> int_value
      end

      # declare a rule for each keyword data type named eg. :kw_real matching
      # the name case insensitive. Also make a rule matching any of these called
      # :most_basic_data_type
      %w(INT DINT BOOL BYTE WORD DWORD TIME_OF_DAY REAL TIME S5TIME DATE CHAR).tap do |keywords|
        keywords.each do |kw|
          rule "kw_#{kw.downcase}".to_sym do
            nocase(kw)
          end
        end

        rule :most_basic_data_type do
          keywords.map {|kw| send "kw_#{kw.downcase}".to_sym }.reduce(&:|)
        end
      end

      rule :string_data_type do
        nocase("STRING[") >> digits >> str("]")
      end

      rule :basic_data_type do
        most_basic_data_type | string_data_type
      end

      rule :struct do
        nocase("STRUCT") >> cwsn >>
          (var_decl >> wsn).repeat >>
          nocase("END_STRUCT")
      end

      rule :value do
        word_value | real_value | bool_value | string_value | byte_value | 
        dint_value | s5time_value | time_value | date_value | 
        date_and_time_value | int_value | dword_value
      end

      rule :timer do
        nocase("T") >> str(" ") >> digits.as(:timer)
      end
      rule :value_or_timer do
        value | timer
      end

      rule :digits do
        match("[0-9]").repeat(1)
      end

      rule :radix16 do
        str("#16#") | str("_16_")
      end

      rule :int_value do
        str("-").maybe >> digits
      end

      rule :hex_value do
        match("[a-fA-F0-9]").repeat(1)
      end

      rule :byte_value do
        nocase("B") >> radix16 >> hex_value.as(:hex)
      end

      rule :word_value do
        nocase("W") >> radix16 >> hex_value.as(:hex)
      end

      rule :dword_value do
        nocase("DW") >> radix16 >> hex_value.as(:hex)
      end

      rule :dint_value do
        nocase("L") >> match("[#_]") >> int_value.as(:decimal)
      end

      rule :real_value do
        int_value >> str(".") >> match("[0-9]").repeat(1) >> 
          (nocase("E") >> match("[+-]") >> match("[0-9]").repeat(1)).maybe
      end

      rule :bool_value do
        nocase("TRUE") | nocase("FALSE")
      end

      rule :s5time_value do
        nocase("S5T") >> match("[#_]") >> digits >> nocase("MS")
      end

      rule :time_value do
        nocase("T") >> match("[#_]") >> digits >> nocase("MS")
      end

      rule :date_value do
        nocase("D") >> match("[#_]") >> digits >> str("-") >> digits >> str("-") >> digits
      end

      rule :date_and_time_value do
        nocase("DT") >> match("[#_]") >> digits >> str("-") >> digits >> str("-") >> digits >>
          str("-") >> digits >> str(":") >> digits >> str(":") >> digits >>
          str(".") >> digits
      end

      rule :string_value do
        str("'") >> ((str("'").absent? >> any) | str("\\'")).repeat >> str("'")
      end

      rule :assign_inital_values do
        assign_initial_value >> (cwsn >> assign_initial_value).repeat
      end

      rule :assign_initial_value do
        symbol.as(:variable) >> ws >> str(":=") >> ws >> value_or_timer.as(:value) >> ws >> str(";")
      end

      rule :quoted do
        str('"') >> (str('"').absent? >> any).repeat >> str('"') # TODO: escaping \" ?
      end

      %w(DB OB FB FC UDT).tap do |blocks|
        blocks.each do |b|
          rule "#{b.downcase}_name".to_sym do
            (nocase(b) >> str(" ").maybe >> int_value) | quoted
          end

          rule "#{b.downcase}_spaced_name".to_sym do
            (nocase(b) >> ws >> int_value) | quoted
          end
        end
      end

      rule :db do
        nocase("DATA_BLOCK") >> ws >> db_name >> cwsn >>
          (title >> cwsn).maybe.as(:title) >>
          (attributes >> cwsn).maybe.as(:attributes) >>
          (property >> cwsn).repeat.as(:properties) >>
          ((struct.as(:struct) >> ws >> str(";")) | udt_name.as(:udt) | fb_spaced_name.as(:fb)) >> cwsn >>
          nocase("BEGIN") >> cwsn >>
          (assign_inital_values.as(:initial_values) >> cwsn).maybe >>
          nocase("END_DATA_BLOCK")
      end

      rule :udt do
        nocase("TYPE") >> ws >> udt_name >> cwsn >>
          struct >> cwsn >>
          nocase("END_TYPE")
      end

      rule :var_sections do
        var_section >> (cwsn >> var_section).repeat
      end

      rule :var_section do
        nocase("VAR") >> 
          (str("_") >> (nocase("INPUT") | nocase("OUTPUT") | nocase("TEMP") | nocase("IN_OUT"))).maybe >> 
          cwsn >>
          (var_decl  >> wsn).repeat >>
          nocase("END_VAR")
      end

      rule :root do
        cwsn.maybe >>
          (db | fb | fc | ob | udt).repeat
      end
    end
  end
end
