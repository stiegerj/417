# CSE 413 16au Assignment 7
require 'readline'

class Token
	attr_accessor :kind
	attr_accessor :value
	
	def initialize(kind, value = nil)
		@kind = kind
		@value = value
	end
	
	def kind()
		return @kind
	end
	
	def value()
		return @value
	end
	
	def to_s
		case @kind
		when 'id'
			return 'identifier with name ' + @value
		when 'num'
			return 'number with value ' + @value.to_s
		when 'eof'
			return 'end of file'
		when "eol"
			return "end of line"
		when '+'
			return 'PLUS'
		when '-'
			return 'MINUS'
		when '*'
			return 'TIMES'
		when '/'
			return 'DIVIDES'
		when '**'
			return 'POWER'
		when '('
			return 'LPAREN'
		when ')'
			return 'RPAREN'
		when '='
			return 'EQUALS'
		when 'clear'
			return 'CLEAR'
		when 'list'
			return 'LIST'
		when 'quit'
			return 'QUIT'
		when 'exit'
			return 'EXIT'
		when 'sqrt'
			return 'SQRT'
		end
	end	
end

class Scanner
	attr_accessor :currentLine
	
	def initialize()
		puts "Accepting input for currentLine: "
		@currentLine = Readline.readline()
		@eof = false
	end
	
	
	
	
	def next_token()
		fileend = @currentLine =~ /\Z/
		if(fileend == 0)
			result = Token.new('eof')
			puts result
			return result
		end
		
		while(@currentLine[0] == "\s" || @currentLine[0] == "\t")
			@currentLine = @currentLine[1..-1]
		end
		
		if(@currentLine == "")
			puts "Accepting input for currentLine: "
			@currentLine = Readline.readline()
			while(@currentLine[0] == "\s" || @currentLine[0] == "\t")
				@currentLine = @currentLine[1..-1]
			end
		end
		
		case @currentLine[0]
		when /"\n"/
			result = Token.new('eol')
			puts result
			return result
		when '+'
			result = Token.new('+')
			@currentLine = @currentLine[1..-1]
			puts result
			return result
		when '-'
			result = Token.new('-')
			@currentLine = @currentLine[1..-1]
			puts result
			return result
		when '*'
			if(@currentLine[1] == "*")
				result = Token.new('**')
				@currentLine = @currentLine[2..-1]
				puts result
				return result
			else
				result = Token.new('*')
				@currentLine = @currentLine[1..-1]
				puts result
				return result
			end
		when '/'
			result = Token.new('/')
			@currentLine = @currentLine[1..-1]
			puts result
			return result
		when '('
			result = Token.new('(')
			@currentLine = @currentLine[1..-1]
			puts result
			return result
		when ')'
			result = Token.new(')')
			@currentLine = @currentLine[1..-1]
			puts result
			return result
		when '='
			result = Token.new('=')
			@currentLine = @currentLine[1..-1]
			puts result
			return result
		when /[0-9]/
			num = /([0-9]+)(.[0-9]+)?([eE][0-9]+)?/
			m = @currentLine.match(num)
			result = Token.new('num',m[0].to_f)
			@currentLine = @currentLine[m[0].length..-1]
			puts result
			return result
		when /[a-zA-Z]/
			temp = /[a-zA-Z][a-zA-Z0-9_]*/
			m = @currentLine.match(temp)
			word = m[0]

			case word
			when 'list'
				result = Token.new('list')
				@currentLine = @currentLine[word.length..-1]
				puts result
				return result
			when 'exit'
				result = Token.new('exit')
				@currentLine = @currentLine[word.length..-1]
				puts result
				return result
			when 'quit'
				result = Token.new('quit')
				@currentLine = @currentLine[word.length..-1]
				puts result
				return result
			when 'sqrt'
				result = Token.new('sqrt')
				@currentLine = @currentLine[word.length..-1]
				puts result
				return result
			when 'clear'
				result = Token.new('clear')
				@currentLine = @currentLine[word.length..-1]
				puts result
				return result
			else 
				result = Token.new('id',word)
				@currentLine = @currentLine[word.length..-1]
				puts result
				return result
			end	
		else
			puts "invalid input"
			@currentLine = @currentLine[1..-1]
			return self.next_token()
		end	
	end
end
	