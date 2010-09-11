require 'spec_helper'
require 'ploc/language_builder'

describe Ploc::LanguageBuilder do
  context 'Foo bar language' do
    before :each do
      @language = Ploc::LanguageBuilder.new do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        define :main do
          foo
          bar
        end
      end.build
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
      @language = Ploc::LanguageBuilder.new do
        terminal :foo, ::Fixnum
        terminal :bar, ::String
        define :main do
          sequence(separator: :bar) {foo}
        end
      end.build
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
end