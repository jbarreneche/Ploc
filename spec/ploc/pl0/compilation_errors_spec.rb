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
      _, equal_error = compiling_context.source_code.errors
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
      # if Y ( 0 then B := -B;
      @src = StringIO.new(<<-MAL)
        var X, Y, Z;

        procedure MULTIPLICAR;
        var A, B, A;
        begin
             A := X;
             B := Y;
             Z := 0;
             if X < 0 then A := -A;
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
    it 'has only 6 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      # puts compiling_context.class
      # puts compiling_context.source_code.errors
      # pending "Pending to tackle extra errors!"
      compiling_context.source_code.should have(6).errors
    end
    it 'detects already declared variable A' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      duplicated_error, *_ = compiling_context.source_code.errors
      duplicated_error.should match /already.+A/i
    end
    it 'extends boolean operators to any operand' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, extra_parenthesis = compiling_context.source_code.errors
      extra_parenthesis.should match /\(/
    end
    it 'extends do with then' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, then_error = compiling_context.source_code.errors
      then_error.should match /do.*then/
    end
    it 'expects open parenthesis in readLn X' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, left_par_error = compiling_context.source_code.errors
      left_par_error.should match /\(\(\).*/
    end
    it 'expects closing parenthesis in readLn X' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, right_par_error = compiling_context.source_code.errors
      right_par_error.should match /\(\)\).*/
    end
    it 'notifies that MULTIPLICAR should be a variable' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, _, multiplicar_error = compiling_context.source_code.errors
      multiplicar_error.should match /wrong.*type.*multiplicar.*variable/i
    end
  end
  context 'MAL-03.PL0' do
    before(:each) do
      # if Y ( 0 then B := -B;
      @src = StringIO.new(<<-MAL)
        var DO, X, Y, Q, R;

        procedure DIVIDIR;
        var V W;
        begin
          Q := 0;
          R := X; if R < 0 then R := -R;
          W := Y; if W < 0 then W := -W;
          V := Y; if V < 0 then V:= -V;
          while W <= R do W := W * 2;
          while W > V do
            begin
              Q := Q * 2; W := W / 2;
              if W <= R then
                begin
                  R := R - W; Q := Q + 1
                end
            end;
          if X < 0 then R:= -R;
          if X < 0 then Q:= -Q;
          if Y < 0 then Q:= -Q;
        end;

        procedure OTRO;
          procedure DIVIDIR;
          begin
            Q := X / Y; R := X - Y * Q
          end;
        call DIVIDIR;

        procedure SALIDA;
        begin
          write ('Cociente: ', Q); writeln;
          write ('Resto: ', R); writeln;
        end;

        begin
          write ('Dividendo: '); readln (X);
          write ('Divisor: '); readln (Y);
          writeln;
          if Y <> 0 then
            begin
              write ('Metodo 1'); writeln;
              call DIVIDIR;
              call SALIDA; writeln;
              write ('Metodo 2'); writeln;
              call OTRO;
              call SALIDA;
            end
        end
        end
      MAL
    end
    it 'has only 4 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(4).errors
    end
    it 'notifies that DO should be an identifier' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      do_error, _ = compiling_context.source_code.errors
      do_error.should match /identifier.*reserved.*word.*do/i
    end
    it 'notifies missing separator , in variable declaration' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, missing_separator = compiling_context.source_code.errors
      missing_separator.should match /,.*found.*W/i
    end
    it 'notifies expects . instead of extra end' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, missing_point = compiling_context.source_code.errors
      missing_point.should match /\..*found.*end/i
    end
    it 'notifies garbage' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, missing_point = compiling_context.source_code.errors
      missing_point.should match /garbage.*found.*end/i
    end
  end
end