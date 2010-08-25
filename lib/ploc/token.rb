require 'ploc/token/base'
require 'ploc/token/identifier'
require 'ploc/token/number'
require 'ploc/token/operand'
require 'ploc/token/reserved_word'
require 'ploc/token/unknown'

module Token
  def self.tokenize(string)
    s = string.downcase
    case s
    when /^\d+$/
      Token::Number.build(string)
    when /^\w+$/
      Token::Identifier.build(string)
    else
      case
      when Token::ReservedWord::ALL.include?(s)
        Token::ReservedWord.build(s)
      when Token::Operand::ALL.include?(s)
        Token::Operand.build(s)
      else
        Token::Unknown.build(string)
      end
    end
  end
end