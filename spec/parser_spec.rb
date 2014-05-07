require 'spec_helper'
require 'awl_parser/parser'

describe AwlParser::Parser do
  let(:parser) { AwlParser::Parser.new }

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
    parser.var_decl.parse "bb : INT;"
    parser.var_decl.parse "cc : WORD;"
  end

  it 'should be able to parse arrays of basic data types' do
    parser.var_decl.parse "array1 : ARRAY [1..20] of INT;"
    parser.var_decl.parse "array2 : ARRAY [1..20, 1..40] of DWORD;"
  end

  it 'parses initial value assignments for variables' do
    parser.assign_inital_values.parse "start := TRUE; // Assignment of initial values\n setp := 10;"
  end

  it 'parses a struct with basic data types in it' do
    parser.struct.parse "STRUCT\n aa : BOOL; // Variable aa of type BOOL\n bb : INT; // Variable bb of type INT\n cc : WORD;\n END_STRUCT;"
  end

  it 'should parse the example db' do
    parser.db.parse EXAMPLE_DATA_BLOCK.strip
  end

  it 'should parse the example UDT and FB' do
    #EXAMPLE_DB_WITH_UDT.lines.each_with_index {|l,i| puts "%02i %s" % [i + 1,l] }
    parser.db.parse EXAMPLE_DB_WITH_UDT.strip
    parser.db.parse EXAMPLE_DB_WITH_FB.strip
  end

  it 'parses block names' do
    parser.db_name.parse "DB100"
    parser.fc_name.parse "FC100"
    parser.udt_name.parse "UDT100"
    parser.udt_spaced_name.parse "UDT 100"
    parser.fb_name.parse "FB100"
    parser.ob_name.parse "OB100"
    parser.db_name.parse '"My data block"'
    parser.fc_name.parse "fc100"
  end
end
