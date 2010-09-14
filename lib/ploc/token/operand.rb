module Ploc::Token
  class Operand < Base
    ASSIGN = ':='
    LEFT_PAR, RIGHT_PAR = %w[( )]
    PARENTHESIS = LEFT_PAR, RIGHT_PAR
    EQUAL = '='
    BOPS = %w[= <> >= <= > <]
    SIGNS = %w[+ -]
    RATIONS = %w[* /]
    COMMA_SEPARATOR, SEMICOLON_SEPARATOR = %w[, ;]
    SEPARATORS = COMMA_SEPARATOR, SEMICOLON_SEPARATOR
    DOT = '.'
    ALL = [ASSIGN] + [DOT] + PARENTHESIS + BOPS + SIGNS + RATIONS + SEPARATORS
  end
end