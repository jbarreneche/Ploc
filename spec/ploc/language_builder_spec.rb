require 'spec_helper'
require 'ploc/language'

describe Ploc::LanguageBuilder do
  context 'Foo bar language' do
    before :each do
      @language = Ploc::Language.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        define :main do
          foo
          bar
        end
      end
    end
    it 'should parse valid construction' do
      enum = [1, 's', nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should be_empty
    end
    it 'should register invalid construction' do
      enum = [1, 2, nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should_not be_empty
    end
    it 'should register garbage' do
      enum = [1, '2', 'nil'].enum_for
      errors = @language.validate(:main, enum)
      errors.should_not be_empty
    end
  end
  context 'Foo bar sequence language' do
    before :each do
      @language = Ploc::Language.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        define :main do
          sequence(separator: :bar) {foo}
        end
      end
    end
    it 'should parse a sequence with only one item' do
      enum = [1, nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should be_empty
    end
    it 'should parse a sequence with multiple items with the separator' do
      enum = [1, '1', 2, nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should be_empty
    end
    it 'shouldn\'t parse a sequence wich ends with the separator' do
      enum = [1, '1', nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should_not be_empty
    end
    it 'shouldn\'t parse a sequence without the expected separator' do
      enum = [1, 1, nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should_not be_empty
    end
  end
  context 'Foo starter with bar' do
    before :each do
      @language = Ploc::Language.build do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        terminal :baz, ::Float
        define :main do
          foo do
            sequence(separator: :baz) { bar }
          end
        end
      end
    end
    it 'should parse a sequence nested in a constant' do
      enum = [1, '1', 1.2, '3', nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should be_empty
    end
    it 'shouldn\'t parse a sequence which doesn\'t start with the constant' do
      enum = [nil].enum_for
      errors = @language.validate(:main, enum)
      errors.should_not be_empty
    end
  end
end