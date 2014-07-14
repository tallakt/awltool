# encoding: utf-8
require 'ostruct'
require 'parser/spec_helper'
require 'parser/fixtures'
require 'awltool/parser/parser'
require 'awltool/parser/transform'

module AwlTool
  module Parser
    include AwlTool::Structures

    RSpec.describe Transform do
      let(:parser) { Parser.new }
      let(:transform) { Transform.new }

      it 'should transform a variable declaration with an initial value' do
        tree = parser.var_decl.parse("in2 : INT  := 10;     // COMMENT")
        decl = transform.apply(tree)

        expect(decl).to be_a Variable
        expect(decl.initial_value).to eq 10
      end

      it 'should transform all possible initial values to ruby objects' do
        vars = parse_and_transform ALL_BASIC_TYPES_INPUTS, parser.var_section#, debug: true

        expect(vars).to be_a VarSection
        initials = OpenStruct.new(Hash[
          vars.variables.map {|v| [v.name, v.initial_value] }
        ])

        expect(initials.a).to be_nil # false is default
        expect(initials.b).to be true
        expect(initials.c).to eq 0xaa
        expect(initials.d).to eq "$"
        expect(initials.e).to eq 0xaaaa
        expect(initials.f).to eq 0xaaaaaaaa
        expect(initials.g).to eq 9999
        expect(initials.h).to eq 99999999
        expect(initials.i).to be_within(1.0).of(-9.999000e+011)
        expect(initials.j).to eq 9_990
        expect(initials.k).to eq 9_999
        expect(initials.l).to eq Date.new 1999, 12, 31
        expect(initials.m).to eq TimeOfDayValue.new 8, 30, 11.222
        expect(initials.n).to eq DateTime.new 1990, 1, 1, 8, 33, 22.111
        expect(initials.p).to be_nil # no initial value for timers
        expect(initials.q).to be_nil # no initial value for counters
        expect(initials.r).to be_nil # no initial value for pointers
        expect(initials.o).to eq "awltool rocks $ ' \n \n \f \f \r \r \t \t"
      end

      it 'should transform some simple var sections' do
        var_decl = parse_and_transform ELEMENTARY_DATA_TYPES, parser.var_sections#, debug: true

        expect(var_decl).to be_an Array
        expect(var_decl.size).to be 3
        var_decl.each {|v| expect(v).to be_a VarSection }
        expect(var_decl.map(&:section_type)).to eq [:var_input, :var_output, :var_temp]

        var_decl.map(&:variables).tap do |vars|
          vars.each do |v| 
            expect(v).to be_a Array
            v.each {|vv| expect(vv).to be_a Variable }
          end

          # the number of variable definitions in each section
          expect(vars.map(&:size)).to match_array [3, 1, 1]

          input, output, temp = vars

          expect(input.size).to be 3
          expect(input.last.name).to eq "in2"
          expect(input.last.initial_value).to eq 10
          expect(input.last.comment).to eq "Optional setting for an initial value in the declaration"
          expect(input.last.of_type).to eq :int
        end
      end

      it 'should transform a two dimensional array variable section' do
        var_sections = parse_and_transform DATA_TYPE_ARRAY, parser.var_sections#, debug: true

        i = var_sections.first.variables

        expect(i.first).to be_a Variable
        expect(i.first.name).to eq "array1"
        expect(i.first.of_type).to be_a ArraySpec
        expect(i.first.of_type.of_type).to eq :int
        expect(i.first.of_type.ranges).to eq [1..20]
        expect(i.first.comment).to eq "array1 is a one-dimensional array"

        expect(i.last).to be_a Variable
        expect(i.last.name).to eq "array2"
        expect(i.last.of_type).to be_a ArraySpec
        expect(i.last.of_type.of_type).to eq :dword
        expect(i.last.of_type.ranges).to eq [1..20, 1..40]
        expect(i.last.comment).to eq "array2 is a two-dimensional array"
      end

      it 'should transform a simple struct data type', a: 3 do
        var_section = parse_and_transform DATA_TYPE_STRUCTURE, parser.var_section#, debug: true
        s = var_section.variables.first

        expect(s.name).to eq "OUTPUT1"
        expect(s.comment).to eq "OUTPUT1 has the data type STRUCT"
        expect(s.of_type).to be_a Struct

        s.of_type.variables.first.tap do |v0|
          expect(v0.name).to eq "var1"
          expect(v0.comment).to eq "Element 1 of the structure"
          expect(v0.of_type).to eq :bool
        end

        s.of_type.variables.last.tap do |v1|
          expect(v1.name).to eq "var2"
          expect(v1.comment).to eq "Element 2 of the structure"
          expect(v1.of_type).to eq :dword
        end
      end

      it 'transforms a simple UDT' do
        blocks = parse_and_transform EXAMPLE_UDT, parser#, debug: true
        expect(blocks.size).to eq 1
        udt = blocks.first
        expect(udt).to be_an UDT
        expect(udt.name).to eq BlockRef.new(:udt, 20)
        expect(udt.properties).to be nil
        expect(udt.attributes).to be nil
        expect(udt.struct).to be_a Struct
        expect(udt.struct.variables).to be_an Array
        expect(udt.struct.variables.size).to eq 3
        expect(udt.struct.variables.map(&:name)).to match_array %w(start setp value)
        expect(udt.struct.variables.map(&:of_type)).to match_array [:bool, :int, :word]
      end
    end
  end
end
