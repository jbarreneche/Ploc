require 'spec_helper'
require 'ploc/pl0'
require 'stringio'

describe 'Pl0 compiler' do
  describe 'Syntax' do
    def program(string)
      StringIO.new(string)
    end
    it 'should validate minimum syntax' do
      errors = Ploc::PL0::Language.parse program('.')
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
      errors = Ploc::PL0::Language.parse program(src)
      errors.should be_empty
    end
  end
end