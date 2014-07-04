# encoding: utf-8
require 'parser/spec_helper'
require 'parser/parser'

describe AwlTool::Parser::Parser do
  let(:parser) { AwlTool::Parser::Parser.new }

  it 'recognizes whitespace' do
    parser.ws.parse " "
    parser.ws.parse "\t"
    parser.ws.parse "\t "
    expect(lambda { parser.ws.parse "\n" }).to raise_error
    expect(lambda { parser.ws.parse "\r" }).to raise_error
  end

  it 'recognizes comments to end of line' do
    parser.comment.parse "//"
    parser.comment.parse "// testing 123"
    expect(lambda { parser.ws.parse "// test\n" }).to raise_error
    expect(lambda { parser.ws.parse "// test\r\n" }).to raise_error
    expect(lambda { parser.ws.parse " // test" }).to raise_error
  end

  it 'parses the different properties' do
    parser.property.parse "KNOW_HOW_PROTECT"
    parser.property.parse "AUTHOR : Tallak Tveide"
    parser.property.parse "FAMILY : Famfam"
    parser.property.parse "NAME : Nmeofblk"
    parser.property.parse "VERSION : 9.9"
    parser.property.parse "CODEVERSION1"
    parser.property.parse "UNLINKED"
    parser.property.parse "READ_ONLY"

    # Allow these illegal lines too
    parser.property.parse "AUTHOR: Tallak Tveide"
    parser.property.parse "AUTHOR :Tallak Tveide"
    parser.property.parse "AUTHOR:Tallak Tveide"
    parser.property.parse "AUTHOR :"

    # Dont allow these
    expect(lambda { parser.property.parse "AUTHOR : \n" }).to raise_error
    expect(lambda { parser.property.parse " AUTHOR : \n" }).to raise_error
    expect(lambda { parser.property.parse "author : \n" }).to raise_error
  end

  it 'parses attribute definitions' do
    parser.attributes.parse "{S7_identifier := 'string'}"
    parser.attributes.parse "{S7_server := 'alarm_archiv'; S7_a_type := 'alarm_8'}"
    parser.attributes.parse "{ S7_m_c := 'true' }"
  end

  it 'parses a title definition' do
    parser.title.parse "TITLE = DB Example 10"

    # These should be allowed
    parser.title.parse "TITLE = "
    parser.title.parse "TITLE ="
    parser.title.parse "TITLE="
    parser.title.parse "TITLE= "
  end

  it 'parses basic variable declarations' do
    parser.var_decl.parse "aa : BOOL;"
    parser.var_decl.parse "aa:BOOL ;"
    parser.var_decl.parse "bb : INT;"
    parser.var_decl.parse "cc : WORD;"
  end

  it 'parses words' do
    parser.word_value.parse "W#16#1ABF"
    parser.value.parse "W#16#1ABF"
    parser.value.parse "W_16_1ABF"
  end

  it 'parses dwords' do
    parser.dword_value.parse "DW#16#1ABFCDE2"
    parser.value.parse "DW#16#1ABFCDE2"
    parser.value.parse "DW_16_1ABFCDE2"
  end

  it 'parses bytes' do
    parser.byte_value.parse "B#16#1A"
    parser.value.parse "B#16#1A"
    parser.value.parse "B_16_1A"
  end

  it 'parses ints' do
    parser.value.parse "W#16#1ABF" # WORD
    parser.value.parse "W_16_1ABF" # WORD
  end

  it 'parses double ints' do
    parser.value.parse "L_100000" # DINT
  end

  it 'parses reals' do
    parser.value.parse "1.0" # REAL
    parser.value.parse "1.0e-4"
    parser.value.parse "-1.0e-4"
    parser.value.parse "-1.0e+4"
  end

  it 'parses date and time' do
    parser.date_and_time_value.parse "DT#90-1-1-0:0:0.000" # DATE_AND_TIME
    parser.value.parse "S5T#100MS" # S5TIME
    parser.value.parse "T#100MS" # TIME
    parser.value.parse "D#1990-1-1" # DATE
  end

  it 'parses boolean values' do
    parser.value.parse "true"
    parser.value.parse "FALSE"
  end

  it 'parses chars' do
    parser.value.parse "'_'" 
    parser.value.parse "'Test'"
  end

  it 'parses strings' do
    parser.value.parse "'_'" 
    parser.value.parse "'Test'" 
  end

  it 'parses comments' do
    # using ws_nl as thay should consume any comments, and comments should
    # to the end of line, and that is diffucult to specify as the comment
    # itself does not contain a newline. Would ideally like to parse
    # repeat comment >> nl
    parser.comment_nl.parse "// This is a comment\n"
    parser.comment_nl.parse "(* This is another comment ( * ) \n   *)\n"
    expect(lambda { parser.comment_nl.parse "//comment\nno comment\n" }).to raise_error
    expect(lambda { parser.comment_nl.parse "(* CC\n*)\nno comment\n" }).to raise_error
  end

  it 'should be able to parse arrays of basic data types' do
    parser.var_decl.parse "array1 : ARRAY [1..20] of INT;"
    parser.var_decl.parse "array2 : ARRAY [1..20, 1..40] of DWORD;"
  end

  it 'parses initial value assignments for variables' do
    parser.assign_inital_values.parse "start := TRUE; // Assignment of initial values\n setp := 10;"
  end

  it 'parses a struct with basic data types in it' do
    parser.struct.parse "STRUCT\n aa : BOOL; // Variable aa of type BOOL\n bb : INT; // Variable bb of type INT\n cc : WORD;\n END_STRUCT"
  end

  it 'parses a single variable section' do
    parser.var_section.parse "VAR_OUTPUT // Keyword for output variable\nout1 : WORD;\nEND_VAR"
  end

  it 'should parse the example db' do
    parser.db.parse EXAMPLE_DATA_BLOCK.strip
  end

  it 'should parse the example UDT' do
    #EXAMPLE_DB_WITH_UDT.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    parser.db.parse EXAMPLE_DB_WITH_UDT.strip
  end

  it 'should parse the example FB' do
    #EXAMPLE_DB_WITH_UDT.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    parser.db.parse EXAMPLE_DB_WITH_FB.strip
  end

  it 'parses the example elementary data types' do
    #ELEMENTARY_DATA_TYPES.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    parser.var_sections.parse ELEMENTARY_DATA_TYPES.strip
  end

  it 'parses the example data type with arrays' do
    parser.var_sections.parse DATA_TYPE_ARRAY.strip
  end

  it 'parses the data section with a struct variable' do
    #puts; DATA_TYPE_STRUCTURE.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    parser.var_sections.parse DATA_TYPE_STRUCTURE.strip
  end

  it 'parses block names' do
    parser.db_name.parse "DB100"
    parser.db_name.parse "DB 100"
    parser.fc_name.parse "FC100"
    parser.fc_name.parse "FC 100"
    parser.fc_name.parse "fc100"
    parser.udt_name.parse "UDT100"
    parser.udt_name.parse "UDT 100"
    parser.fb_name.parse "FB100"
    parser.fb_name.parse "FB 100"
    parser.ob_name.parse "OB100"
    parser.ob_name.parse "OB 100"
    parser.db_name.parse '"My data block"'
  end

  it 'parses the whole document' do
    doc = "\n\n(* ?? *)\n#{EXAMPLE_DATA_BLOCK}\n(* ??? *)\n\n\n#{EXAMPLE_DB_WITH_FB}\n(* ??? *)\n\n"
    parser.root.parse doc
  end
end
