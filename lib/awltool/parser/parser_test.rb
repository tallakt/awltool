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

      rule :spaces do
        space.repeat
      end

      rule :space_newline do
        match("[ \t\r\n]")
      end

      # It seems the Step7 env treats all whitepace as equal
      rule :ws do # separator between language elemtns
        (space_newline | line_comment | block_comment).repeat
      end

      rule :block_comment do
        str("(*") >> (str("*)").absent? >> any).repeat >> str("*)")
      end

      rule :line_comment do
        str("//") >> spaces >> (newline.absent? >> any).repeat
      end

      rule :maybe_line_comment do
        line_comment.maybe
      end

      rule :block_of_line_comments do
        (spaces >> line_comment >> newline).repeat
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
        (nocase("STRUCT") | udt_name | fb_name | var_section_start).absent? >>
        caps_symbol
      end

      rule :property do
        # rather broad
        caps_symbol_except_data_def >> ws >> 
          (str(":") >> ws >> ((newline.absent? >> any).repeat).maybe).maybe
      end

      rule :attributes do
        str("{") >> ws >> attrib_entry >> ws >> 
          (str(";") >> ws >> attrib_entry).repeat >> ws >> str("}")
      end

      rule :attrib_entry do
        symbol >> ws >> str(":=") >> ws >>
          str("'") >> (str("'").absent? >> any).repeat >> str("'")
      end

      rule :title do
        nocase("TITLE") >> ws >> str("=") >> ws >> (newline.absent? >> any).repeat
      end

      rule :var_decl do
        symbol >> 
        ws >> (attributes >> ws).maybe >> 
        str(":") >> ws >>
        (array_specification >> ws).maybe >> 
        type_spec_with_initial_value >> ws >>
        str(";") >> spaces >> maybe_line_comment
      end

      # Note - we are not checking whether the initial value will match the
      # data type, or if the data type may have an initial value
      rule :type_spec_with_initial_value do
        (basic_data_type | string_data_type | struct) >> ws >> 
        (str(":=") >> ws >> value >> ws).maybe
      end

      rule :array_specification do
        nocase("ARRAY") >> ws >> 
          str("[") >> ws >> array_ranges >> ws >> str("]") >> 
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
      # :some_basic_data_type
      %w(INT DINT BOOL BYTE WORD DWORD TIME_OF_DAY 
         REAL S5TIME CHAR TIMER DATE_AND_TIME COUNTER
         POINTER ANY).sort.tap do |keywords|
        keywords.each do |kw|
          rule "kw_#{kw.downcase}".to_sym do
            nocase(kw)
          end
        end

        rule :some_basic_data_type do
          keywords.map {|kw| send "kw_#{kw.downcase}".to_sym }.reduce(&:|)
        end
      end

      # These are done by hand to prevent collision with longer names
      # starting with the same characters
      rule :kw_date do
        nocase("DATE") >> nocase("_AND_TIME").absent?
      end

      rule :kw_time do
        nocase("TIME") >> nocase("_OF_DAY").absent? >> nocase("R").absent?
      end

      rule :most_basic_data_type do
      end

      rule :string_data_type do
        nocase("STRING") >> ws >> str("[") >> ws >> digits >> ws >> str("]")
      end

      rule :basic_data_type do
        (kw_date | kw_time | some_basic_data_type)
      end

      rule :fc_return_type do
        basic_data_type | string_data_type | nocase("VOID") | udt_name
      end

      rule :struct do
        nocase("STRUCT") >> spaces >> maybe_line_comment >> ws >>
        (var_decl >> ws).repeat >>
        nocase("END_STRUCT")
      end

      rule :value do
        word_value | real_value | bool_value | string_value | byte_value | 
        dint_value | s5time_value | time_value | date_value | 
        date_and_time_value | int_value | dword_value | time_of_day_value
      end

      rule :counter do
        nocase("C") >> ws >> digits
      end

      rule :timer do
        nocase("T") >> ws >> digits
      end

      rule :value_or_timer do
        value | timer | counter
      end

      rule :digits do
        match("[0-9]").repeat(1)
      end

      rule :radix16 do
        str("#16#") | str("_16_")
      end

      rule :int_value do
        (str("-").maybe >> digits)
      end

      rule :hex_value do
        match("[a-fA-F0-9]").repeat(1)
      end

      rule :byte_value do
        nocase("B") >> radix16 >> hex_value
      end

      rule :word_value do
        nocase("W") >> radix16 >> hex_value
      end

      rule :dword_value do
        nocase("DW") >> radix16 >> hex_value
      end

      rule :dint_value do
        nocase("L") >> match("[#_]") >> int_value
      end

      rule :real_value do
        (
          (str("-").maybe >> digits) >> 
          str(".") >> 
          match("[0-9]").repeat(1) >> 
          (nocase("E") >> match("[+-]") >> match("[0-9]").repeat(1)).maybe
        )
      end

      rule :bool_value do
        nocase("TRUE") | nocase("FALSE")
      end

      rule :s5time_value do
        nocase("S5T") >> match("[#_]") >> generic_time_value
      end

      rule :time_value do
        nocase("T") >> match("[#_]") >> generic_time_value
      end

      rule :time_of_day_value do
        nocase("TOD") >> match("[#_]") >> 
        (
          digits >> 
          str(":") >> 
          digits >> 
          str(":") >> 
          digits >>
          str(".") >> 
          digits
        )
      end

      rule :generic_time_value do
        (digits >> nocase("D")).maybe >>
        (digits >> nocase("H")).maybe >>
        (digits >> (nocase("M") >> nocase("S").absent?)).maybe >>
        (digits >> nocase("S")).maybe >>
        (digits >> nocase("MS")).maybe
      end

      rule :date_value do
        nocase("D") >> match("[#_]") >> 
        (digits >> str("-") >> digits >> str("-") >> digits) 
      end

      rule :date_and_time_value do
        nocase("DT") >> match("[#_]") >> 
        (
          digits >> 
          str("-") >>
          digits >> 
          str("-") >>
          digits >>
          str("-") >>
          digits >> 
          str(":") >> 
          digits >> 
          str(":") >> 
          digits >>
          str(".") >> 
          digits
        )
      end

      rule :string_value do
        str("'") >> codepoint.repeat >> str("'")
      end

      rule :codepoint do
      (str("$") >> any) | (str("'").absent? >> any)
      end

      rule :assign_inital_values do
        assign_initial_value >> (ws >> assign_initial_value).repeat
      end

      rule :assign_initial_value do
        symbol >> ws >> str(":=") >> ws >> value_or_timer >> ws >> str(";")
      end

      rule :quoted do
        str('"') >> (str('"').absent? >> any).repeat >> str('"') # TODO: escaping \" ?
      end

      %w(DB OB FB FC UDT).tap do |blocks|
        blocks.each do |b|
          rule "#{b.downcase}_name".to_sym do
            (nocase(b) >> ws >> int_value) | quoted
          end
        end
      end

      rule :standard_block_header do
        (title >> ws).maybe >>
        (attributes >> ws).maybe >>
        (property >> ws).repeat
      end

      rule :db do
        nocase("DATA_BLOCK") >> ws >> db_name >> ws >>
        standard_block_header >> ws >>
        ((struct >> ws >> str(";")) | udt_name | fb_name) >> ws >>
        nocase("BEGIN") >> ws >>
        (assign_inital_values >> ws).maybe >>
        nocase("END_DATA_BLOCK")
      end


      rule :end_of_network do
        nocase("NETWORK") | nocase("END_FUNCTION") | nocase("END_FUNCTION_BLOCK") | nocase("END_ORGANIZATION_BLOCK")
      end

      rule :networks do
        network >> (ws >> network).repeat
      end

      rule :network do
        nocase("NETWORK") >> ws >>
        title >> newline >>
        block_of_line_comments >> ws >>
        (end_of_network.absent? >> any).repeat
      end

      rule :fc do
        nocase("FUNCTION") >> ws >> fc_name >> ws >> str(":") >> ws >> 
        fc_return_type >> ws >>
        standard_block_header >> ws >>
        var_sections >> ws >>
        nocase("BEGIN") >> ws >>
        networks.maybe >>
        nocase("END_FUNCTION")
      end

      rule :fb do
        nocase("FUNCTION_BLOCK") >> ws >> fb_name >> ws >>
        standard_block_header >> ws >>
        var_sections >> ws >>
        nocase("BEGIN") >> ws >>
        networks.maybe >>
        nocase("END_FUNCTION_BLOCK")
      end

      rule :ob do
        nocase("ORGANIZATION_BLOCK") >> ws >> ob_name >> ws >>
        standard_block_header >> ws >>
        var_sections >> ws >>
        nocase("BEGIN") >> ws >>
        networks.maybe >>
        nocase("END_ORGANIZATION_BLOCK")
      end

      rule :udt do
        nocase("TYPE") >> ws >> udt_name >> ws >>
          struct >> ws >>
          nocase("END_TYPE")
      end

      rule :var_sections do
        var_section >> (ws >> var_section).repeat
      end

      rule :var_section_start do
        variations = %w(INPUT OUTPUT TEMP IN_OUT).map {|x| nocase x }.reduce(&:|)
        nocase("VAR") >> (str("_") >> variations).maybe
      end

      rule :var_section do
        var_section_start >> ws >>
        (var_decl >> ws).repeat >>
        nocase("END_VAR")
      end

      rule :root do
        ws >>
        (
           (db | fb | fc | ob | udt) >>
           ws 
        ).repeat
      end
    end
  end
end
