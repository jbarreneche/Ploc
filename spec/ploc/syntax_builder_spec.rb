require 'spec_helper'
require 'ploc/syntax'
require 'ploc/source_code'

describe Ploc::SyntaxBuilder do
  context 'Foo bar syntax' do
    before :each do
      @syntax = Ploc::Syntax.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        define :main do
          foo
          bar
        end
      end
    end
    it 'should parse valid construction' do
      enum = program(1, 's')
      errors = @syntax.validate(:main, enum)
      errors.should be_empty
    end
    it 'should register invalid construction' do
      enum = program(1, 2)
      errors = @syntax.validate(:main, enum)
      errors.should_not be_empty
    end
    it 'should register garbage' do
      enum = program(1, '2', 'nil')
      errors = @syntax.validate(:main, enum)
      errors.should_not be_empty
    end
  end
  context 'Foo bar sequence syntax' do
    before :each do
      @syntax = Ploc::Syntax.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        define :main do
          sequence(separator: :bar) {foo}
        end
      end
    end
    it 'shouldn\'t parse a sequence without the item' do
      enum = program()
      errors = @syntax.validate(:main, enum)
      errors.should_not be_empty
    end
    it 'should parse a sequence with only one item' do
      enum = program(1)
      errors = @syntax.validate(:main, enum)
      errors.should be_empty
    end
    it 'should parse a sequence with multiple items with the separator' do
      enum = program(1, '1', 2)
      errors = @syntax.validate(:main, enum)
      errors.should be_empty
    end
    it 'shouldn\'t parse a sequence wich ends with the separator' do
      enum = program(1, '1')
      errors = @syntax.validate(:main, enum)
      errors.should_not be_empty
    end
    it 'shouldn\'t parse a sequence without the expected separator' do
      enum = program(1, 1)
      errors = @syntax.validate(:main, enum)
      errors.should_not be_empty
    end
  end
  context 'Foo starter with bar' do
    before :each do
      @syntax = Ploc::Syntax.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        terminal :baz, ::Float
        define :main do
          foo
          sequence(separator: :baz) { bar }
        end
      end
    end
    it 'should parse a sequence nested in a constant' do
      enum = program(1, '1', 1.2, '3')
      errors = @syntax.validate(:main, enum)
      errors.should be_empty
    end
    it 'shouldn\'t parse a sequence which doesn\'t start with the constant' do
      enum = program()
      errors = @syntax.validate(:main, enum)
      errors.should_not be_empty
    end
  end
  context 'Foo starter with baz terminator and bar' do
    before :each do
      @syntax = Ploc::Syntax.build do
        terminal :foo, ::String
        terminal :bar, ::Fixnum
        terminal :baz, ::Symbol
        define :main do
          optional { foo; main_sequence}
          bar
        end
        define(:main_sequence, terminator: :baz)  { main }
      end
    end
    it 'should support recursive definitions' do
      enum = program('foo', 'foo', 1, :end, 1, :end, 1)
      errors = @syntax.validate(:main, enum)
      errors.should be_empty
    end
  end
  context 'Branching tokens' do
    before :each do
      @syntax = Ploc::Syntax.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        terminal :baz, ::Symbol
        define :main do
          sequence(repeat: true) do
            foo
            branch do
              baz
              bar
            end
          end
        end
      end
    end
    it 'should support repeating sequence without separators' do
      enum = program(1, 'string', 2, :symbol)
      errors = @syntax.validate(:main, enum)
      errors.should be_empty
    end
  end
  def program(*data)
    Ploc::SourceCode.new((data << nil).enum_for)
  end
end