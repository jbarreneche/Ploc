require 'spec_helper'
require 'stringio'
require 'ploc/pl0'

describe "Compiling error detection" do
  context "MAL-00.PL0" do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        var X, Y;

        procedure INICIAR;
          const Y = 2;
          procedure ASIGNAR;
            X = Y;
          call ASIGNAR;

        begin
          write ('NUM=') readln (Y);
          call INICIAR;
          writeln ("NUM*2=",Y*X)
        end.
      MAL
    end
    it 'extends assignation syntax as = instead of :=' do
      # pending 'Terminal extensions'
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      equal_error, separator_error = compiling_context.source_code.errors
      equal_error.should match /:=.+=/
    end
    it 'allows weak separator for multiple sentences' do
      # pending "missing weak separators on sequence"
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, separator_error = compiling_context.source_code.errors
      separator_error.should match /;/
    end
    it 'has only 2 errors' do
      # pending "missing weak separators on sequence"
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(2).errors
    end
  end
end