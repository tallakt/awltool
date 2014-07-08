# encoding: utf-8
require 'parser/spec_helper'
require 'parser/fixtures'
require 'awltool/parser/parser'
require 'awltool/parser/transform'

S = AwlTool::Structures

describe AwlTool::Parser::Transform do
  let(:parser) { AwlTool::Parser::Parser.new }
  let(:transform) { AwlTool::Parser::Transform.new }

  it 'should transform a two dimensional array variable section' do
    parsed = parser.var_sections.parse(DATA_TYPE_ARRAY.strip)
    var_decl = transform.apply parsed

    expect(var_decl).to be_an Array
    expect(var_decl.size).to be 1
    expect(var_decl.first).to be_a S::VarSection
    expect(var_decl.first.section_type).to be :var_input
    i = var_decl.first.variables

    expect(i.first).to be_a S::Variable
    expect(i.first.name).to eq "array1"
    expect(i.first.of_type).to be_a S::ArraySpec
    expect(i.first.of_type.of_type).to eq :int
    expect(i.first.of_type.ranges).to eq [1..20]
    expect(i.first.comment).to eq "array1 is a one-dimensional array"

    expect(i.last).to be_a S::Variable
    expect(i.last.name).to eq "array2"
    expect(i.last.of_type).to be_a S::ArraySpec
    expect(i.last.of_type.of_type).to eq :dword
    expect(i.last.of_type.ranges).to eq [1..20, 1..40]
    expect(i.last.comment).to eq "array2 is a two-dimensional array"
  end
end
