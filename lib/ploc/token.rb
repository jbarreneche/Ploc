module Ploc
  module Token
    def self.tokenize(string)
      s = string.downcase
      case s
      when /^\d+$/
        Number.build(string)
      when /^["']/
        String.build(string)
      when /^\w+$/
        if ReservedWord::ALL.include?(s)
          ReservedWord.build(s)
        else
          Identifier.build(string)
        end
      else
        if Token::Operand::ALL.include?(s)
          Operand.build(s)
        else
          Unknown.build(string)
        end
      end
    end
  end
end

require 'ploc/token/base'
require 'ploc/token/identifier'
require 'ploc/token/number'
require 'ploc/token/operand'
require 'ploc/token/reserved_word'
require 'ploc/token/string'
require 'ploc/token/unknown'
