# encoding: utf-8
require 'ploc/semantic_context'
require 'ploc/binary_data'
module Ploc::PL0
  class CompilingContext < Ploc::SemanticContext
    attr_reader :output
    def initialize(source_code = nil)
      super(source_code)
      @output = []
    end
    def initialize_new_program!(*args)
      self.outuput << Ploc::BinaryData.new(<<-BIN)
      #  /* ELF HEADER */
      7F 45 4C 46 # ELF
      01 01 01    # Flags
      00 00 00    # Padding zeroes
      00 00 00    # Padding zeroes
      00 00 00    # Padding zeroes
      02 00       # Type: 2 (Executable)
      03 00       # Machine: 3 = i32
      01 00 00 00 # Version: 1 (Current)
      80 84 04 08 # Entry: absolute entry point (_start)
      34 00 00 00 # File offset to PHT
      65 00 00 00 # File offset to SHT
      00 00 00 00 # Flags: 0 for i386
      34 00       # ELF Header size
      20 00       # PHT Entry size
      01 00       # Entries in PHT
      28 00       # SHT Entry size
      03 00       # Entries in SHT
      01 00       # Index of .shstrtab

      # /* PHT (1 Entry) */
      01 00 00 00 # 1 = Load into memory
      00 00 00 00 # file offset to start of segment
      00 80 04 08 # Virtual address where loaded
      00 80 04 08 # Absolute address where loaded

      00 00 00 00 # File size <---

      14 04 00 00 # Memory size
      07 00 00 00 # Permissions (rwx)
      00 10 00 00 # Alignment required

      # /* SH STRING TABLE (3 Strings) */
      00                            # Empty string
      2E 73 68 73 74 72 74 61 62 00 # .shstrtab
      2E 74 65 78 74 00             # .text

      # /* SHT (3 Entries) */
      # Entry 0 (reserved)
      00 00 00 00 # name
      00 00 00 00 # type
      00 00 00 00 # flags
      00 00 00 00 # addr
      00 00 00 00 # offset
      00 00 00 00 # size
      00 00 00 00 # link
      00 00 00 00 # info
      00 00 00 00 # addrAlign
      00 00 00 00 # entSize

      # Entry 1 (.shstrtab)
      01 00 00 00 # name
      03 00 00 00 # type
      00 00 00 00 # flags
      00 00 00 00 # addr
      54 00 00 00 # offset
      11 00 00 00 # size
      00 00 00 00 # link
      00 00 00 00 # info
      01 00 00 00 # addrAlign
      00 00 00 00 # entSize

      # Entry 2 (.text)
      0B 00 00 00 # name
      01 00 00 00 # type
      06 00 00 00 # flags
      E0 80 04 08 # addr
      E0 00 00 00 # offset

      00 00 00 00 # size <---

      00 00 00 00 # link
      00 00 00 00 # info
      01 00 00 00 # addrAlign
      00 00 00 00 # entSize

      00 00 00    # Filling with zeroes

      # Input output rutines
    #  0  1  2  3  4  5  6  7   8  9  A  B  C  D  E  F
    # ------------------------------------------------
      52 51 53 50 b8 04 00 00  00 bb 01 00 00 00 89 e1
      ba 01 00 00 00 cd 80 58  5b 59 5a c3 55 89 e5 81
      ec 24 00 00 00 52 51 53  b8 36 00 00 00 bb 00 00
      00 00 b9 01 54 00 00 8d  55 dc cd 80 81 65 e8 f5
      ff ff ff b8 36 00 00 00  bb 00 00 00 00 b9 02 54
      00 00 8d 55 dc cd 80 31  c0 50 b8 03 00 00 00 bb
      00 00 00 00 89 e1 ba 01  00 00 00 cd 80 81 4d e8
      0a 00 00 00 b8 36 00 00  00 bb 00 00 00 00 b9 02
      54 00 00 8d 55 dc cd 80  58 5b 59 5a 89 ec 5d c3

      # 0x0170: muestra por consola una cadena alojada a partir de la dirección guardada en ECX, y cuya longitud es EDX.
      b8 04 00 00 00 bb 01 00  00 00 cd 80 c3 90 90 90

      # 0x0180: envía un salto de línea a la consola.
      b0 0a e8 59 ff ff ff c3  04 30 e8 51 ff ff ff c3

      # 0x0190: muestra por consola el número entero contenido en EAX.
      3d 00 00 00 80 75 4e b0  2d e8 42 ff ff ff b0 02
      e8 e3 ff ff ff b0 01 e8  dc ff ff ff b0 04 e8 d5
      ff ff ff b0 07 e8 ce ff  ff ff b0 04 e8 c7 ff ff
      ff b0 08 e8 c0 ff ff ff  b0 03 e8 b9 ff ff ff b0
      06 e8 b2 ff ff ff b0 04  e8 ab ff ff ff b0 08 e8
      a4 ff ff ff c3 3d 00 00  00 00 7d 0b 50 b0 2d e8
      ec fe ff ff 58 f7 d8 3d  0a 00 00 00 0f 8c ef 00
      00 00 3d 64 00 00 00 0f  8c d1 00 00 00 3d e8 03
      00 00 0f 8c b3 00 00 00  3d 10 27 00 00 0f 8c 95
      00 00 00 3d a0 86 01 00  7c 7b 3d 40 42 0f 00 7c
      61 3d 80 96 98 00 7c 47  3d 00 e1 f5 05 7c 2d 3d
      00 ca 9a 3b 7c 13 ba 00  00 00 00 bb 00 ca 9a 3b
      f7 fb 52 e8 30 ff ff ff  58 ba 00 00 00 00 bb 00
      e1 f5 05 f7 fb 52 e8 1d  ff ff ff 58 ba 00 00 00
      00 bb 80 96 98 00 f7 fb  52 e8 0a ff ff ff 58 ba
      00 00 00 00 bb 40 42 0f  00 f7 fb 52 e8 f7 fe ff
      ff 58 ba 00 00 00 00 bb  a0 86 01 00 f7 fb 52 e8
      e4 fe ff ff 58 ba 00 00  00 00 bb 10 27 00 00 f7
      fb 52 e8 d1 fe ff ff 58  ba 00 00 00 00 bb e8 03
      00 00 f7 fb 52 e8 be fe  ff ff 58 ba 00 00 00 00
      bb 64 00 00 00 f7 fb 52  e8 ab fe ff ff 58 ba 00
      00 00 00 bb 0a 00 00 00  f7 fb 52 e8 98 fe ff ff
      58 e8 92 fe ff ff c3 90  90 90 90 90 90 90 90 90

      # 0x300: finaliza el programa.
      b8 01 00 00 00 bb 00 00  00 00 cd 80 90 90 90 90

      # 0x310: lee por consola un número entero y lo deja guardado en EAX.
      b9 00 00 00 00 b3 03 51  53 e8 de fd ff ff 5b 59
      3c 0a 0f 84 34 01 00 00  3c 7f 0f 84 94 00 00 00
      3c 2d 0f 84 09 01 00 00  3c 30 7c db 3c 39 7f d7
      2c 30 80 fb 00 74 d0 80  fb 02 75 0c 81 f9 00 00
      00 00 75 04 3c 00 74 bf  80 fb 03 75 0a 3c 00 75
      04 b3 00 eb 02 b3 01 81  f9 cc cc cc 0c 7f a8 81
      f9 34 33 33 f3 7c a0 88  c7 b8 0a 00 00 00 f7 e9
      3d 08 00 00 80 74 11 3d  f8 ff ff 7f 75 13 80 ff
      07 7e 0e e9 7f ff ff ff  80 ff 08 0f 8f 76 ff ff
      ff b9 00 00 00 00 88 f9  80 fb 02 74 04 01 c1 eb
      03 29 c8 91 88 f8 51 53  e8 cb fd ff ff 5b 59 e9
      53 ff ff ff 80 fb 03 0f  84 4a ff ff ff 51 53 b0
      08 e8 0a fd ff ff b0 20  e8 03 fd ff ff b0 08 e8
      fc fc ff ff 5b 59 80 fb  00 75 07 b3 03 e9 25 ff
      ff ff 80 fb 02 75 0f 81  f9 00 00 00 00 75 07 b3
      03 e9 11 ff ff ff 89 c8  b9 0a 00 00 00 ba 00 00
      00 00 3d 00 00 00 00 7d  08 f7 d8 f7 f9 f7 d8 eb
      02 f7 f9 89 c1 81 f9 00  00 00 00 0f 85 e6 fe ff
      ff 80 fb 02 0f 84 dd fe  ff ff b3 03 e9 d6 fe ff
      ff 80 fb 03 0f 85 cd fe  ff ff b0 2d 51 53 e8 8d
      fc ff ff 5b 59 b3 02 e9  bb fe ff ff 80 fb 03 0f
      84 b2 fe ff ff 80 fb 02  75 0c 81 f9 00 00 00 00
      0f 84 a1 fe ff ff 51 e8  04 fd ff ff 59 89 c8 c3

      BIN
    end
  end
end