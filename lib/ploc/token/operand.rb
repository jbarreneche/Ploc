module Ploc::Token
  class Operand < Base
    ASSIGN = ':='
    LEFT_PAR, RIGHT_PAR = %w[( )]
    PARENTHESIS = LEFT_PAR, RIGHT_PAR
    BOPS = %w[= <> >= <= > <]
    SIGNS = %w[+ -]
    RATIONS = %w[* /]
    COMMA_SEPARATOR, SEMICOLON_SEPARATOR = %w[, ;]
    SEPARATORS = COMMA_SEPARATOR, SEMICOLON_SEPARATOR
    ALL = [ASSIGN] + PARENTHESIS + BOPS + SIGNS + RATIONS + SEPARATORS
  end
end