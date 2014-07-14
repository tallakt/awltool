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
      rule :ws do
        (space_newline | line_comment | block_comment).repeat
      end

      rule :block_comment do
        str("(*") >> (str("*)").absent? >> any).repeat.as(:comment) >> str("*)")
      end

      rule :saved_line_comment do
        str("//") >> spaces >> (newline.absent? >> any).repeat.as(:comment)
      end

      rule :line_comment do
        str("//") >> spaces >> (newline.absent? >> any).repeat
      end

      rule :maybe_line_comment do
        saved_line_comment.maybe.as(:line_comment)
      end

      rule :block_of_line_comments do
        (spaces >> saved_line_comment >> newline).repeat.as(:comment_block)
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
        caps_symbol_except_data_def.as(:key) >> ws >> 
          (str(":") >> ws >> ((newline.absent? >> any).repeat).maybe.as(:value)).maybe
      end

      rule :attributes do
        str("{") >> ws >> attrib_entry.as(:first) >> ws >> 
          (str(";") >> ws >> attrib_entry).repeat.as(:rest) >> ws >> str("}")
      end

      rule :attrib_entry do
        symbol.as(:name) >> ws >> str(":=") >> ws >>
          str("'") >> (str("'").absent? >> any).repeat.as(:value) >> str("'")
      end

      rule :title do
        nocase("TITLE") >> ws >> str("=") >> ws >> (newline.absent? >> any).repeat.as(:title)
      end

      rule :var_decl_struct do
        symbol.as(:name) >> 
        ws >> (attributes >> ws).maybe.as(:attributes) >> 
        str(":") >> ws >>
        (array_specification >> ws).maybe >> 
        struct.as(:struct) >> ws >>
        str(";")
      end

      rule :var_decl_non_struct do
        symbol.as(:name) >> 
        ws >> (attributes >> ws).maybe.as(:attributes) >> 
        str(":") >> ws >>
        (array_specification >> ws).maybe >> 
        type_spec_with_initial_value >> ws >>
        str(";") >> spaces >> maybe_line_comment
      end

      rule :var_decl do
        var_decl_non_struct | var_decl_struct
      end

      # Note - we are not checking whether the initial value will match the
      # data type, or if the data type may have an initial value
      rule :type_spec_with_initial_value do
        (basic_data_type | string_data_type).as(:type) >> ws >> 
        (str(":=") >> ws >> value >> ws).maybe.as(:initial)
      end

      rule :array_specification do
        nocase("ARRAY") >> ws >> 
          str("[") >> ws >> array_ranges.as(:array) >> ws >> str("]") >> 
          ws >> nocase("OF")
      end

      rule :array_ranges do
        array_range.as(:first) >> (ws >> str(",") >> ws >> array_range).repeat.as(:rest)
      end

      rule :array_range do
        int_value.as(:range_begin) >> ws >> str("..") >> ws >> int_value.as(:range_end)
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
        nocase("STRING") >> ws >> str("[") >> ws >> digits.as(:string_with_length) >> ws >> str("]")
      end

      rule :basic_data_type do
        (kw_date | kw_time | some_basic_data_type).as(:basic_data_type)
      end

      rule :fc_return_type do
        basic_data_type | string_data_type | nocase("VOID") | udt_name
      end

      rule :struct do
        nocase("STRUCT") >> spaces >> maybe_line_comment >> ws >>
        (var_decl >> ws).repeat.as(:struct_declarations) >>
        nocase("END_STRUCT")
      end

      rule :value do
        word_value | real_value | bool_value | string_value | byte_value | 
        dint_value | s5time_value | time_value | date_value | 
        date_and_time_value | int_value | dword_value | time_of_day_value
      end

      rule :counter do
        nocase("C") >> ws >> digits.as(:timer)
      end

      rule :timer do
        nocase("T") >> ws >> digits.as(:timer)
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
        (str("-").maybe >> digits).as(:int_value)
      end

      rule :hex_value do
        match("[a-fA-F0-9]").repeat(1)
      end

      rule :byte_value do
        nocase("B") >> radix16 >> hex_value.as(:hex_value)
      end

      rule :word_value do
        nocase("W") >> radix16 >> hex_value.as(:hex_value)
      end

      rule :dword_value do
        nocase("DW") >> radix16 >> hex_value.as(:hex_value)
      end

      rule :dint_value do
        nocase("L") >> match("[#_]") >> int_value.as(:int_value)
      end

      rule :real_value do
        (
          (str("-").maybe >> digits) >> 
          str(".") >> 
          match("[0-9]").repeat(1) >> 
          (nocase("E") >> match("[+-]") >> match("[0-9]").repeat(1)).maybe
        ).as(:real_value)
      end

      rule :bool_value do
        nocase("TRUE").as(:true_value) | nocase("FALSE").as(:false_value)
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
        ).as(:time_of_day_value)
      end

      rule :generic_time_value do
        (digits.as(:int_value) >> nocase("D")).maybe.as(:d) >>
        (digits.as(:int_value) >> nocase("H")).maybe.as(:h) >>
        (digits.as(:int_value) >> (nocase("M") >> nocase("S").absent?)).maybe.as(:m) >>
        (digits.as(:int_value) >> nocase("S")).maybe.as(:s) >>
        (digits.as(:int_value) >> nocase("MS")).maybe.as(:ms)
      end

      rule :date_value do
        nocase("D") >> match("[#_]") >> 
        (digits >> str("-") >> digits >> str("-") >> digits).as(:date_value) 
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
        ).as(:date_and_time_value)
      end

      rule :string_value do
        str("'") >> codepoint.repeat.as(:string_value) >> str("'")
      end

      rule :codepoint do
      (str("$") >> any) | (str("'").absent? >> any)
      end

      rule :assign_inital_values do
        assign_initial_value.as(:first) >> (ws >> assign_initial_value).repeat.as(:rest)
      end

      rule :assign_initial_value do
        symbol.as(:variable) >> ws >> str(":=") >> ws >> value_or_timer.as(:value) >> ws >> str(";")
      end

      rule :quoted_block_name do
        str('"') >> ((str('"') | newline).absent? >> any).repeat.as(:block_name) >> str('"')
      end

      %w(DB OB FB FC UDT).tap do |blocks|
        blocks.each do |b|
          rule "#{b.downcase}_name".to_sym do
            (nocase(b) >> ws >> digits.as("#{b.downcase}_number".to_sym)) | quoted_block_name
          end
        end
      end

      rule :standard_block_header do
        (title >> ws).maybe >>
        (attributes >> ws).maybe.as(:attributes) >>
        ((property >> ws).repeat(1)).maybe.as(:properties)
      end

      rule :db do
        nocase("DATA_BLOCK") >> ws >> db_name.as(:name) >> ws >>
        standard_block_header.as(:header) >> ws >>
        ((struct.as(:struct) >> ws >> str(";")) | udt_name.as(:udt_ref) | fb_name.as(:fb_ref)) >> ws >>
        nocase("BEGIN") >> ws >>
        (assign_inital_values >> ws).maybe.as(:initial_values) >>
        nocase("END_DATA_BLOCK")
      end


      rule :end_of_network do
        nocase("NETWORK") | nocase("END_FUNCTION") | nocase("END_FUNCTION_BLOCK") | nocase("END_ORGANIZATION_BLOCK")
      end

      rule :networks do
        network.as(:first) >> (ws >> network).repeat.as(:rest)
      end

      rule :network do
        nocase("NETWORK") >> ws >>
        title >> newline >>
        block_of_line_comments >> ws >>
        (end_of_network.absent? >> any).repeat.as(:code)
      end

      rule :fc do
        nocase("FUNCTION") >> ws >> fc_name >> ws >> str(":") >> ws >> 
        fc_return_type.as(:return) >> ws >>
        standard_block_header.as(:header) >> ws >>
        var_sections.as(:var_sections) >> ws >>
        nocase("BEGIN") >> ws >>
        networks.maybe.as(:networks) >>
        nocase("END_FUNCTION")
      end

      rule :fb do
        nocase("FUNCTION_BLOCK") >> ws >> fb_name >> ws >>
        standard_block_header.as(:header) >> ws >>
        var_sections.as(:var_sections) >> ws >>
        nocase("BEGIN") >> ws >>
        networks.maybe.as(:networks) >>
        nocase("END_FUNCTION_BLOCK")
      end

      rule :ob do
        nocase("ORGANIZATION_BLOCK") >> ws >> ob_name >> ws >>
        standard_block_header.as(:header) >> ws >>
        var_sections.as(:var_sections) >> ws >>
        nocase("BEGIN") >> ws >>
        networks.maybe.as(:networks) >>
        nocase("END_ORGANIZATION_BLOCK")
      end

      rule :udt do
        nocase("TYPE") >> ws >> udt_name.as(:name) >> ws >>
        standard_block_header >> ws >>
        struct.as(:udt_struct) >> ws >> 
        str(";") >> ws >>
        nocase("END_TYPE")
      end

      rule :var_sections do
        var_section.as(:first) >> (ws >> var_section).repeat.as(:rest)
      end

      rule :var_section_start do
        variations = %w(INPUT OUTPUT TEMP IN_OUT).map {|x| nocase x }.reduce(&:|)
        nocase("VAR") >> (str("_") >> variations).maybe
      end

      rule :var_section do
        var_section_start.as(:var_section) >> ws >>
        (var_decl >> ws).repeat.as(:declarations) >>
        nocase("END_VAR")
      end

      rule :any_block do
        db | fb | fc | ob | udt
      end

      rule :root do
        ws >> (any_block >> ws).repeat
      end
    end
  end
end
