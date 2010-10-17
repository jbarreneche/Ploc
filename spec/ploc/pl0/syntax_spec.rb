require 'spec_helper'
require 'ploc/source_code'
require 'ploc/pl0/syntax'
require 'ploc/pl0/scanner'

module Ploc::PL0
  describe Syntax do
    def program(string)
      Ploc::SourceCode.new(Scanner.new(StringIO.new(string)))
    end
    it 'should validate minimum syntax' do
      errors = Syntax.parse_program program('.')
      errors.should be_empty
    end
    it 'should validate complex syntax too!!' do
      src = <<-SRC
        var X, Y;
        procedure INICIAR;
          const Y = 2;
          procedure ASIGNAR;
            X := Y;
          call ASIGNAR;
        begin
          write('NUM='); readln(Y);
          call INICIAR;
          writeln('NUM*2=',Y*X)
        end.
      SRC
      errors = Syntax.parse_program program(src)
      errors.should be_empty
    end
    context 'detecting simple errors' do
      it 'should not allow some random token in constants declarations' do
        src = <<-SRC
          var X 3, Y;
          .
        SRC
        errors = Syntax.parse_program program(src)
        errors.should_not be_empty
      end
    end
  end
end