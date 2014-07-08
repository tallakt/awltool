# encoding: utf-8
require 'parser/spec_helper'
require 'parser/parser'
require 'parslet/rig/rspec'

describe AwlTool::Parser::Parser do
  let(:parser) { AwlTool::Parser::Parser.new }

  it 'recognizes whitespace' do
    expect(parser.ws).to parse " ", trace: true
    expect(parser.ws).to parse "\t"
    expect(parser.ws).to parse "\t "
    expect(parser.ws).to parse "\r"
    expect(parser.ws).to parse "\n"
    expect(parser.ws).to parse " \t\n" * 5
  end

  it 'recognizes comments to end of line' do
    expect(parser.comment).to parse "//"
    expect(parser.comment).to parse "// testing 123"
    expect(parser.ws).to parse "// test\n" 
    expect(parser.ws).to parse "// test\r\n"
    expect(parser.ws).to parse " // test"
  end

  it 'parses whitespace with comments' do
    expect(parser.ws).to parse "   // comments\n// comments2   \t\t\n\n"
  end

  it 'parses a block comment' do
    expect(parser.comment).to parse "(* testing\r\n123*\r\nJuhu*)"
  end

  it 'parses the different properties' do
    expect(parser.property).to parse "KNOW_HOW_PROTECT"
    expect(parser.property).to parse "AUTHOR : Tallak Tveide"
    expect(parser.property).to parse "FAMILY : Famfam"
    expect(parser.property).to parse "NAME : Nmeofblk"
    expect(parser.property).to parse "VERSION : 9.9"
    expect(parser.property).to parse "CODEVERSION1"
    expect(parser.property).to parse "UNLINKED"
    expect(parser.property).to parse "READ_ONLY"

    # Allow these nonstandard lines too
    expect(parser.property).to parse "AUTHOR: Tallak Tveide"
    expect(parser.property).to parse "AUTHOR :Tallak Tveide"
    expect(parser.property).to parse "AUTHOR:Tallak Tveide"
    expect(parser.property).to parse "AUTHOR :"
  end

  it 'parses attribute definitions' do
    expect(parser.attributes).to parse "{S7_identifier := 'string'}"
    expect(parser.attributes).to parse "{S7_server := 'alarm_archiv'; S7_a_type := 'alarm_8'}"
    expect(parser.attributes).to parse "{ S7_m_c := 'true' }"
  end

  it 'parses a title definition' do
    expect(parser.title).to parse "TITLE = DB Example 10"

    # These should be allowed
    expect(parser.title).to parse "TITLE = "
    expect(parser.title).to parse "TITLE ="
    expect(parser.title).to parse "TITLE="
    expect(parser.title).to parse "TITLE= "
  end

  it 'parses basic variable declarations' do
    expect(parser.var_decl).to parse "aa : BOOL;"
    expect(parser.var_decl).to parse "aa:BOOL ;"
    expect(parser.var_decl).to parse "bb : INT;"
    expect(parser.var_decl).to parse "cc : WORD;"
  end

  it 'parses words' do
    expect(parser.word_value).to parse "W#16#1ABF"
    expect(parser.value).to parse "W#16#1ABF"
    expect(parser.value).to parse "W_16_1ABF"
  end

  it 'parses dwords' do
    expect(parser.dword_value).to parse "DW#16#1ABFCDE2"
    expect(parser.value).to parse "DW#16#1ABFCDE2"
    expect(parser.value).to parse "DW_16_1ABFCDE2"
  end

  it 'parses bytes' do
    expect(parser.byte_value).to parse "B#16#1A"
    expect(parser.value).to parse "B#16#1A"
    expect(parser.value).to parse "B_16_1A"
  end

  it 'parses ints' do
    expect(parser.value).to parse "W#16#1ABF" # WORD
    expect(parser.value).to parse "W_16_1ABF" # WORD
  end

  it 'parses double ints' do
    expect(parser.value).to parse "L_100000" # DINT
  end

  it 'parses reals' do
    expect(parser.value).to parse "1.0" # REAL
    expect(parser.value).to parse "1.0e-4"
    expect(parser.value).to parse "-1.0e-4"
    expect(parser.value).to parse "-1.0e+4"
  end

  it 'parses date and time' do
    expect(parser.date_and_time_value).to parse "DT#90-1-1-0:0:0.000" # DATE_AND_TIME
    expect(parser.value).to parse "S5T#100MS" # S5TIME
    expect(parser.value).to parse "T#100MS" # TIME
    expect(parser.value).to parse "D#1990-1-1" # DATE
  end

  it 'parses boolean values' do
    expect(parser.value).to parse "true"
    expect(parser.value).to parse "FALSE"
  end

  it 'parses chars' do
    expect(parser.value).to parse "'_'" 
    expect(parser.value).to parse "'Test'"
  end

  it 'parses strings' do
    expect(parser.value).to parse "'_'" 
    expect(parser.value).to parse "'Test'" 
  end

  it 'parses comments' do
    # using ws_nl as thay should consume any comments, and comments should
    # to the end of line, and that is diffucult to specify as the comment
    # itself does not contain a newline. Would ideally like to parse
    # repeat comment >> nl
    expect(parser.comment_nl).to parse "// This is a comment\n"
    expect(parser.comment_nl).to parse "(* This is another comment ( * ) \n   *)\n"
    expect(lambda { parser.comment_nl.parse "//comment\nno comment\n" }).to raise_error
    expect(lambda { parser.comment_nl.parse "(* CC\n*)\nno comment\n" }).to raise_error
  end

  it 'should be able to parse arrays of basic data types' do
    expect(parser.var_decl).to parse "array1 : ARRAY [1..20] of INT;"
    expect(parser.var_decl).to parse "array2 : ARRAY [1..20, 1..40] of DWORD;"
  end

  it 'parses initial value assignments for variables' do
    expect(parser.assign_inital_values).to parse "start := TRUE; // Assignment of initial values\n setp := 10;"
  end

  it 'parses a struct with basic data types in it' do
    expect(parser.struct).to parse "STRUCT\n aa : BOOL; // Variable aa of type BOOL\n bb : INT; // Variable bb of type INT\n cc : WORD;\n END_STRUCT"
  end

  it 'parses a start og a variable section' do
    expect(parser.var_section_start).to parse "VAR"
    expect(parser.var_section_start).to parse "var_in_out"
  end

  it 'parses a single variable section' do
    expect(parser.var_section).to parse "" + 
      "VAR_OUTPUT // Keyword for output variable\nout1 : WORD;\nEND_VAR",
      trace: true
  end

  it 'should parse the example db' do
    expect(parser.db).to parse EXAMPLE_DATA_BLOCK.strip
  end

  it 'should parse the first example fcs' do
    expect(parser.fc).to parse EXAMPLE_FUNCTION.strip
  end

  it 'should parse the second example fc' do
    puts SECOND_EXAMPLE_FUNCTION
    #puts expect(parser.fc_part).to parse SECOND_EXAMPLE_FUNCTION.strip
    expect(parser.fc).to parse SECOND_EXAMPLE_FUNCTION.strip
  end

  it 'should parse the example UDT' do
    #EXAMPLE_DB_WITH_UDT.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    expect(parser.db).to parse EXAMPLE_DB_WITH_UDT.strip
  end

  it 'should parse the example FB' do
    #EXAMPLE_DB_WITH_UDT.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    expect(parser.db).to parse EXAMPLE_DB_WITH_FB.strip
  end

  it 'parses the example elementary data types' do
    #ELEMENTARY_DATA_TYPES.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    expect(parser.var_sections).to parse ELEMENTARY_DATA_TYPES.strip
  end

  it 'parses the example data type with arrays' do
    expect(parser.var_sections).to parse DATA_TYPE_ARRAY.strip
  end

  it 'parses the data section with a struct variable' do
    #puts; DATA_TYPE_STRUCTURE.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    expect(parser.var_sections).to parse DATA_TYPE_STRUCTURE.strip
  end

  it 'parses block names' do
    expect(parser.db_name).to parse "DB100"
    expect(parser.db_name).to parse "DB 100"
    expect(parser.fc_name).to parse "FC100"
    expect(parser.fc_name).to parse "FC 100"
    expect(parser.fc_name).to parse "fc100"
    expect(parser.udt_name).to parse "UDT100"
    expect(parser.udt_name).to parse "UDT 100"
    expect(parser.fb_name).to parse "FB100"
    expect(parser.fb_name).to parse "FB 100"
    expect(parser.ob_name).to parse "OB100"
    expect(parser.ob_name).to parse "OB 100"
    expect(parser.db_name).to parse '"My data block"'
  end

  it 'parses the whole document' do
    doc = "\n\n(* ?? *)\n#{EXAMPLE_DATA_BLOCK}\n(* ??? *)\n\n\n#{EXAMPLE_DB_WITH_FB}\n(* ??? *)\n\n"
    expect(parser.root).to parse doc
  end
end
