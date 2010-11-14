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
    it 'has only 2 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(2).errors
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
  end
  context 'MAL-01.PL0 (1st)' do
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
    it 'has cascading errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      # puts compiling_context.source_code.errors
      # compiling_context.source_code.should have(7).errors
    end
    it 'notifies missing =' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing_separator, _ = compiling_context.source_code.errors
      missing_separator.should match /procedur.*/i
    end
  end
  context 'MAL-01.PL0 (2nd)' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        VAR BASE, EXPO, RESU;

        PROCEDURE POT;
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
    it 'has only 3 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(3).errors
    end
    it 'extends assignation syntax as = instead of :=' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      equal_error, _ = compiling_context.source_code.errors
      equal_error.should match /:=.+=/
    end
    it 'notifies missing separator' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, missing_separator = compiling_context.source_code.errors
      missing_separator.should match /expecting.*;.*/i
    end
    it 'notifies missing then' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, missing_separator = compiling_context.source_code.errors
      missing_separator.should match /expecting.*then.*found.*RESU/i
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
    it 'has only 7 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(7).errors
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
      _, _, then_error = compiling_context.source_code.errors
      then_error.should match /do.*then/
    end
    it 'expects open parenthesis in readLn X' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, left_par_error = compiling_context.source_code.errors
      left_par_error.should match /\(\(\).*/
    end
    it 'expects closing parenthesis in readLn X' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, _, right_par_error = compiling_context.source_code.errors
      right_par_error.should match /\(\)\).*/
    end
    it 'notifies that MULTIPLICAR should be a variable' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, _, _, multiplicar_error = compiling_context.source_code.errors
      multiplicar_error.should match /wrong.*type.*multiplicar.*variable/i
    end
  end
  context 'MAL-03.PL0' do
    before(:each) do
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
  context 'MAL-04.PL0' do
    before(:each) do
      # if Y ( 0 then B := -B;
      @src = StringIO.new(<<-MAL)
        var X, Y Z;

        procedure MCD
        var F,G;
        begin
          F := X; G := Y;
          while F <> G do
            begin
              if F < G then  G := G - F;
              IF G < F then  F := F - G
            end;
          Z:= F
        end;

        begin
          do write ('X: '); readln (X);
          if X > 0 then
            begin
              write ('Y: '); readln (Y);
              if Y > 0 then
                begin
                  call MCD;
                  writeln ('MCD: ', Z); writeln ()
                end
            end
        end.
      MAL
    end
    it 'has only 4 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(4).errors
    end
    it 'notifies that DO should be an identifier' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing_separator, _ = compiling_context.source_code.errors
      missing_separator.should match /,.*found.*Z/i
    end
    it 'notifies missing separator , in variable declaration' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, missing_separator = compiling_context.source_code.errors
      missing_separator.should match /;.*found.*VAR/i
    end
    it 'notifies expects . instead of extra end' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, unexpected_reserved_word = compiling_context.source_code.errors
      unexpected_reserved_word.should match /found.*do/i
    end
    it 'notifies garbage' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, missing_point = compiling_context.source_code.errors
      missing_point.should match /expresion.*found.*\)/i
    end
  end
  context 'MAL-05.PL0' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        VAR R, N;

        PROCEDURE INICIALIZAR;
        CONST UNO = ;
        R := -(-UNO);

        PROCEDURE RAIZ;
        BEGIN
          CALL N;
          WHILE R * R < N DO R := R + 1
        END;

        BEGIN
          WRITE ('N: '); READLN (N);
          WRITE ('RAIZ CUADRADA DE ', N, ': ');
          IF N < 0 THEN WRITE ('ERROR');
          IF N = 0 THEN WRITE (0);
          IF N > 0 THEN
            BEGIN
              CALL RAIZ;
              IF R* <>N THEN WRITE (R - 1, '..');
              WRITE (R);
            END;
          WRITELN
        END.
      MAL
    end
    it 'has only 3 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(3).errors
    end
    it 'notifies missing number' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing_separator, _ = compiling_context.source_code.errors
      missing_separator.should match /number.*found.*;/i
    end
    it 'notifies N its not a procedure' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, wrong_type = compiling_context.source_code.errors
      wrong_type.should match /wrong.*type.*N.*procedure.*/i
    end
    it 'notifies N its not a procedure' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, missing_number = compiling_context.source_code.errors
      missing_number.should match /expecting.*found.*<>.*/i
    end
  end
  context 'MAL-06.PL0' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        CONST K1=1, K2=2, K3=3, K4=4, K5=5, K6=6, K7=7, K8=8, K9=9, K10=10,
        K11=11, K12=12, K13=13, K14=14, K15=15, K16=16, K17=17, K18=18, K19=19, K20=20,
        K21=21, K22=22, K23=23, K24=24, K25=25, K26=26, K27=27, K28=28, K29=29, K30=30,
        K31=31, K32=32, K33=33, K34=34, K35=35, K36=36, K37=37, K38=38, K39=39, K40=40,
        K41=41, K42=42, K43=43, K44=44, K45=45, K46=46, K47=47, K48=48, K49=49, K50=50,
        K51=51, K52=52, K53=53, K54=54, K55=55, K56=56, K57=57, K58=58, K59=59, K60=60,
        K61=61, K62=62, K63=63, K64=64, K65=65, K66=66, K67=67, K68=68, K69=69, K70=70,
        K71=71, K72=72, K73=73, K74=74, K75=75, K76=76, K77=77, K78=78, K79=79, K80=80,
        K81=81, K82=82, K83=83, K84=84, K85=85, K86=86, K87=87, K88=88, K89=89, K90=90,
        K91=91, K92=92, K93=93, K94=94, K95=95, K96=96, K97=97, K98=98, K99=99, K100=100,
        K101=101, K102=102, K103=103, K104=104, K105=105, K106=106, K107=107, K108=108, K109=109, K110=110,
        K111=111, K112=112, K113=113, K114=114, K115=115, K116=116, K117=117, K118=118, K119=119, K120=120,
        K121=121, K122=122, K123=123, K124=124, K125=125, K126=126, K127=127, K128=128, K129=129, K130=130,
        K131=131, K132=132, K133=133, K134=134, K135=135, K136=136, K137=137, K138=138, K139=139, K140=140,
        K141=141, K142=142, K143=143, K144=144, K145=145, K146=146, K147=147, K148=148, K149=149, K150=150,
        K151=151, K152=152, K153=153, K154=154, K155=155, K156=156, K157=157, K158=158, K159=159, K160=160,
        K161=161, K162=162, K163=163, K164=164, K165=165, K166=166, K167=167, K168=168, K169=169, K170=170,
        K171=171, K172=172, K173=173, K174=174, K175=175, K176=176, K177=177, K178=178, K179=179, K180=180,
        K181=181, K182=182, K183=183, K184=184, K185=185, K186=186, K187=187, K188=188, K189=189, K190=190,
        K191=191, K192=192, K193=193, K194=194, K195=195;

        var IMPORTE, BILLETE, VUELTO, PESOS, CENTAVOS, VUELTOPESOS, VUELTOCENTAVOS,
            IMPORTEOK, CENTAVOSOK, PESOSOK, BILLETEOK, VUELTOOK,
        DEMASIADOLARGO1234567890123456789012345678901234567890123456789012345678901234567890,
        V1, V2, V3, V4, V5, V6, V7, V8, V9, V10,
        V11, V12, V13, V14, V15, V16, V17, V18, V19, V20,
        V21, V22, V23, V24, V25, V26, V27, V28, V29, V30,
        V31, V32, V33, V34, V35, V36, V37, V38, V39, V40,
        V41, V42, V43, V44, V45, V46, V47, V48, V49, V50,
        V51, V52, V53, V54, V55, V56, V57, V58, V59, V60,
        V61, V62, V63, V64, V65, V66, V67, V68, V69, V70,
        V71, V72, V73, V74, V75, V76, V77, V78, V79, V80,
        V81, V82, V83, V84, V85, V86, V87, V88, V89, V90,
        V91, V92, V93, V94, V95, V96, V97, V98, V99, V100,
        V101, V102, V103, V104, V105, V106, V107, V108, V109, V110,
        V111, V112, V113, V114, V115, V116, V117, V118, V119, V120,
        V121, V122, V123, V124, V125;

        procedure ERROR;
        begin
          writeln ('VALOR FUERA DE RANGO!')
        end;

        begin
          WRITELN ('*******************************************');
          writeLn ('VUELTO PARA IMPORTES PAGADOS CON UN BILLETE');
          WRITELN ('*******************************************');
          writeln;
          IMPORTEOK := -1;
          while IMPORTEOK <> 0 do
            begin
              writeln ('IMPORTE (min $0.01 y max $100.00)');
              CENTAVOSOK := -1;
              while CENTAVOSOK <> 0 do
                begin
                  write ('CENTAVOS: '); readLn (CENTAVOS);
                  CENTAVOSOK := 0;
                  if CENTAVOS < 0 then CENTAVOSOK := -1;
                  if CENTAVOS > 99 then CENTAVOSOK := -1;
                  if CENTAVOSOK <> 0 then call ERROR
                end;
              PESOSOK := -1;
              while PESOSOK <> 0 do
                begin
                  write ('PESOS: '); readLn (PESOS);
                  PESOSOK := 0;
                  if PESOS < 0 then PESOSOK := -1;
                  if PESOS > 100 then PESOSOK := -1;
                  if PESOSOK <> 0 then call ERROR
               end;
              write ('IMPORTE: $', PESOS, '.');
              if CENTAVOS < 10 then write ('0');
              writeLn (CENTAVOS);
              IMPORTE := PESOS * 100 + CENTAVOS;
              IMPORTEOK := 0;
              if IMPORTE < 1 then IMPORTEOK := -1;
              if IMPORTE > 10000 then IMPORTEOK := -1;
              if IMPORTEOK <> 0 then call ERROR
            end;

          VUELTOOK := -1;
          while VUELTOOK <> 0 do
            begin
              BILLETEOK := -1;
              while BILLETEOK <> 0 do
                begin
                  write ('BILLETE (min $2 y max $100): $'); readLn (BILLETE);
                  BILLETEOK := -1;
                  if BILLETE = 2 then BILLETEOK := 0;
                  if BILLETE = 5 then BILLETEOK := 0;
                  if BILLETE = 10 then BILLETEOK := 0;
                  if BILLETE = 20 then BILLETEOK := 0;
                  if BILLETE = 50 then BILLETEOK := 0;
                  if BILLETE = 100 then BILLETEOK := 0;
                  if BILLETEOK <> 0 then writeln ('BILLETE INEXISTENTE!')
                end;
              VUELTO := BILLETE * 100 - IMPORTE;
              VUELTOOK := 0;
              if VUELTO < 0 then
                begin
                  VUELTOOK := -1;
                  writeLn ('BILLETE INSUFICIENTE PARA EL PAGO!')
                end
            end;

          VUELTOPESOS := VUELTO / 100;
          VUELTOCENTAVOS := VUELTO - VUELTOPESOS * 100;

          write ('Su vuelto: $', VUELTOPESOS, '.');
          if VUELTOCENTAVOS < 10 then write ('0');
          writeLn (VUELTOCENTAVOS);

          writeLn;

          if VUELTO >= 5000 then
            begin
              writeLn ('1 billete de $50');
              VUELTO := VUELTO - 5000
            end;

          if VUELTO >= 2000 then
            begin
              if VUELTO / 2000 = 1 then writeLn ('1 billete de $20');
              if VUELTO / 2000 <> 1 then writeLn ('2 billetes de $20');
              VUELTO := VUELTO - VUELTO / 2000 * 2000
            end;

          if VUELTO >= 1000 then
            begin
              writeLn ('1 billete de $10');
              VUELTO := VUELTO - 1000
            end;

          if VUELTO >= 500 then
            begin
              writeLn ('1 billete de $5');
              VUELTO := VUELTO - 500
            end;

          if VUELTO >= 200 then
            begin
              if VUELTO / 200 = 1 then writeLn ('1 billete de $2');
              if VUELTO / 200 <> 1 then writeLn ('2 billetes de $2');
              VUELTO := VUELTO - VUELTO / 200 * 200
            end;

          if VUELTO >= 100 then
            begin
              writeLn ('1 moneda de $1');
              VUELTO := VUELTO - 100
            end;

          if VUELTO >= 50 then
            begin
              writeLn ('1 moneda de 50 centavos');
              VUELTO := VUELTO - 50
            end;

          if VUELTO >= 25 then
            begin
              writeLn ('1 moneda de 25 centavos');
              VUELTO := VUELTO - 25
            end;

          if VUELTO >= 10 then
            begin
              if VUELTO / 10 = 1 then writeLn ('1 moneda de 10 centavos');
              if VUELTO / 10 <> 1 then writeLn ('2 monedas de 10 centavos');
              VUELTO := VUELTO - VUELTO / 10 * 10
            end;

          if VUELTO >= 5 then
            begin
              writeLn ('1 moneda de 5 centavos');
              VUELTO := VUELTO - 5
            end;

          if VUELTO > 1 then writeLn (VUELTO, ' monedas de 1 centavo');
          if VUELTO = 1 then writeLn ('1 moneda de 1 centavo');

          WRITELN ('***************************************************************
          ***************************************************************************
          ***************************************************************************
          *************************************************************************')  
        end.
      MAL
    end
    it 'has only 2 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(2).errors
    end
    it 'notifies missing number' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing_separator, _ = compiling_context.source_code.errors
      missing_separator.should match /expecting.*string.*/i
    end
    it 'expects ) after all wrong something' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, missing_par = compiling_context.source_code.errors
      missing_par.should match /\).*/i
    end
  end
  context 'MAL-07.PL0 (1st)' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        CONST N 20;

        VAR A, B, C;

        PROCEDURE TRI#NGULO;
        VAR A, B;
        BEGIN
          WRITELN;
          A := 15;
          WHILE A > 0 DO
            BEGIN
              B := 0;
              WHILE B < A DO
                BEGIN
                  WRITE ('*')
                  B := B + 1
                END;
              WRITELN;
              A := A - 1;
            END
        END;

        BEGIN
          A := 111111;
          WHILE A <= N DO
            BEGIN
              WRITE (A, ' ');
              A := A + TRIANGULO
            END;

          CALL TRIANGULO;

          B := -N;
          C := 0;
          WHILE B < C DO
            BEGIN
              WRITE (B, ' ');
              B := B + 1
            END;
          WRITELN;

        END.
      MAL
    end
    it 'has cascading errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      # puts compiling_context.source_code.errors
      # compiling_context.source_code.should have(7).errors
    end
    it 'notifies missing =' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing_separator, _ = compiling_context.source_code.errors
      missing_separator.should match /expecting.*=.*/i
    end
    it 'expects ) after all wrong something' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, wrong_symbol = compiling_context.source_code.errors
      wrong_symbol.should match /#.*/i
    end
  end
  context 'MAL-07.PL0 (2nd)' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        CONST N = 20;

        VAR A, B, C;

        PROCEDURE TRIANGULO;
        VAR A, B;
        BEGIN
          WRITELN;
          A := 15;
          WHILE A > 0 DO
            BEGIN
              B := 0;
              WHILE B < A DO
                BEGIN
                  WRITE ('*')
                  B := B + 1
                END;
              WRITELN;
              A := A - 1;
            END
        END;

        BEGIN
          A := 111111;
          WHILE A <= N DO
            BEGIN
              WRITE (A, ' ');
              A := A + TRIANGULO
            END;

          CALL TRIANGULO;

          B := -N;
          C := 0;
          WHILE B < C DO
            BEGIN
              WRITE (B, ' ');
              B := B + 1
            END;
          WRITELN;

        END.
      MAL
    end
    it 'has only 2 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(2).errors
    end
  end
  context 'MAL-08.PL0' do
    before(:each) do
      @src = StringIO.new(<<-MAL)
        var K;
        procedure P;
          procedure coma;
          begin
            write (',')
            K := K + 1;
            call P
          end;
        begin
          if K < 10 then
            begin
              write coma;
              call K;
            end
        end;

        begin
          K := 1;
          call P;
          writeln (10)
      MAL
    end
    it 'has only 7 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(7).errors
    end
    it 'notifies missing separator' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing_separator, _ = compiling_context.source_code.errors
      missing_separator.should match /expecting.*;.*/i
    end
    it 'expects ( after write' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, missing_par = compiling_context.source_code.errors
      missing_par.should match /\(.*found.*coma/i
    end
    it 'expects expression to be of const or variable' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, wrong_type = compiling_context.source_code.errors
      wrong_type.should match /wrong.*type.*coma.*constant.*/i
    end
    it 'expects ) after all wrong something' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, missing_par = compiling_context.source_code.errors
      missing_par.should match /\).*found.*;/i
    end
    it 'expects expression to be of const or variable' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, _, wrong_type = compiling_context.source_code.errors
      wrong_type.should match /wrong.*type.*K.*procedure.*/i
    end
    it 'notifies missing end' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, _, _, missing = compiling_context.source_code.errors
      missing.should match /expecting.*end.*/i
    end
    it 'notifies missing .' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      _, _, _, _, _, _, missing = compiling_context.source_code.errors
      missing.should match /expecting.*\..*/i
    end
  end
  context 'MAL-08.PL0' do
    before(:each) do
      @src = StringIO.new("")
    end
    it 'has only 1 errors' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      compiling_context.source_code.should have(1).errors
    end
    it 'notifies missing .' do
      compiling_context = Ploc::PL0::Language.compile @src, StringIO.new
      missing, _ = compiling_context.source_code.errors
      missing.should match /expecting.*\..*/i
    end
  end
end