# encoding: utf-8
require 'ostruct'
require 'parser/spec_helper'
require 'parser/fixtures'
require 'awltool/parser/parser'
require 'awltool/parser/transform'


module AwlTool
  module Parser
    describe Transform do
      let(:parser) { Parser.new }
      let(:transform) { Transform.new }

      it 'should transform a variable declaration with an initial value' do
        tree = parser.var_decl.parse("in2 : INT  := 10;     // COMMENT")
        decl = transform.apply(tree)

        expect(decl).to be_a Structures::Variable
        expect(decl.initial_value).to eq 10
      end

      it 'should transform all possible initial values to ruby objects' do
        tree = parser.var_section.parse ALL_BASIC_TYPES_INPUTS.strip, trace: true
        vars = transform.apply(tree)

        expect(vars).to be_a Structures::VarSection
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
        expect(initials.m).to eq Structures::TimeOfDayValue.new 8, 30, 11.222
        expect(initials.n).to eq DateTime.new 1990, 1, 1, 8, 33, 22.111
        expect(initials.p).to be_nil # no initial value for timers
        expect(initials.q).to be_nil # no initial value for counters
        expect(initials.r).to be_nil # no initial value for pointers
        expect(initials.o).to eq "awltool rocks $ ' \n \n \f \f \r \r \t \t"
      end

      it 'should transform some simple var sections' do
        tree = parser.var_sections.parse ELEMENTARY_DATA_TYPES.strip
        var_decl = transform.apply tree

        expect(var_decl).to be_an Array
        expect(var_decl.size).to be 3
        var_decl.each {|v| expect(v).to be_a Structures::VarSection }
        expect(var_decl.map(&:section_type)).to eq [:var_input, :var_output, :var_temp]

        var_decl.map(&:variables).tap do |vars|
          vars.each do |v| 
            expect(v).to be_a Array
            v.each {|vv| expect(vv).to be_a Structures::Variable }
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
        tree = parser.var_sections.parse(DATA_TYPE_ARRAY.strip)
        var_decl = transform.apply tree

        # require 'awesome_print'
        # puts DATA_TYPE_ARRAY.lines.each_with_index {|l,i| puts "%02d %s" % [i+1,l] }
        # puts "---"
        # ap tree
        # puts "---"
        # ap var_decl
        # puts "---"
# 
        expect(var_decl).to be_an Array
        expect(var_decl.size).to be 1
        expect(var_decl.first).to be_a Structures::VarSection
        expect(var_decl.first.section_type).to be :var_input
        i = var_decl.first.variables

        expect(i.first).to be_a Structures::Variable
        expect(i.first.name).to eq "array1"
        expect(i.first.of_type).to be_a Structures::ArraySpec
        expect(i.first.of_type.of_type).to eq :int
        expect(i.first.of_type.ranges).to eq [1..20]
        expect(i.first.comment).to eq "array1 is a one-dimensional array"

        expect(i.last).to be_a Structures::Variable
        expect(i.last.name).to eq "array2"
        expect(i.last.of_type).to be_a Structures::ArraySpec
        expect(i.last.of_type.of_type).to eq :dword
        expect(i.last.of_type.ranges).to eq [1..20, 1..40]
        expect(i.last.comment).to eq "array2 is a two-dimensional array"
      end
    end
  end
end
