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
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      equal_error, separator_error = compiling_context.source_code.errors
      equal_error.should match /:=.+=/
    end
    it 'allows weak separator for multiple sentences' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, separator_error = compiling_context.source_code.errors
      separator_error.should match /;/
    end
    it 'has only 2 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(2).errors
    end
  end
  context 'MAL-01.PL0' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        VAR BASE, EXPO, RESU;

        PROCEDUR POT;
        IF EXPO > 0 THEN
           BEGIN
                RESU = RESU * BASE;
                EXPO := EXPO - 1;
                CALL POT
           END;

        BEGIN
             WRITE ('BASE: '); READLN(BASE);
             WRITE ('EXPONENTE: '); READLN(EXPO)
             RESU := 1;
             CALL POT;
             IF EXPO < 0  RESU := 0;
             WRITELN ('RESULTADO: ', RESU);
             WRITELN
        END.
      MAL
    end
    it 'extends assignation syntax as = instead of :=' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      equal_error, _ = compiling_context.source_code.errors
      equal_error.should match /:=.+=/
    end
    it 'allows weak separator for multiple sentences' do
      pending "Cascades procedur en lugar de procedure??"
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, *separator_error = compiling_context.source_code.errors
      puts compiling_context.source_code.errors
      # separator_error.should match /;/
    end
  end
  context 'MAL-02.PL0' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        var X, Y, Z;

        procedure MULTIPLICAR;
        var A, B, A;
        begin
             A := X;
             B := Y;
             Z := 0;
             if X < 0 then A := -A;
             if Y ( 0 then B := -B;
             while B > 0 then
                 begin
                   if odd B then Z:= Z + A;
                   A := A * 2;
                   B := B / 2
                 end;
             if X < 0 then Z:= -Z;
             if Y < 0 then Z:= -Z
        end;

        Begin
             write ('X: '); readLn X;
             write ('Y: '); readLn (Y);
             MULTIPLICAR;
             writeLn ('X*Y=', Z);
        end.
      MAL
    end
    it 'has only 4 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      # puts compiling_context.source_code.errors
      pending "Pending to tackle extra errors!"
      compiling_context.source_code.should have(4).errors
    end
    it 'detects already declared variable A' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      duplicated_error, *_ = compiling_context.source_code.errors
      duplicated_error.should match /already.+A/i
    end
  end
end