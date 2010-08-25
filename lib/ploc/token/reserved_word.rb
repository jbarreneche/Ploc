module Token
  class ReservedWord < Token::Base
    ALL = %w[const var procedure begin end if while]
  end
end