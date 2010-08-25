module Token
  class Operand < Token::Base
    ALL = %w[:= = <> >= <= > < + - ( ) * / , ;]
  end
end