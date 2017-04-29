require_relative "scan.rb"

class Parser
	attr_accessor :vars
	
	def initialize()
		@vars = {"PI" => Math::PI}
	end
	
	def program(s)
		if s.empty?
			return
		end
		index = s.rindex{|x| x.kind() == "eol"}
		if index == nil
			statement(s)
		elsif program(s[0,index])
			statement(s[index+1,s.length])
		end
	end
	
	def statement(s)
		if s[0].kind() == "list"
			puts @vars
			return
		elsif s[0].kind() == "clear"
			@vars.delete(s[1].value())
			return
		elsif s[0].kind() == "quit"
			return false
		elsif s[0].kind() == "exit"
			return false
		elsif s.length > 1 && s[1].kind() == "="
			@vars[s[0].value] = exp(s[2,s.length])
			return
		end
		puts exp(s)
	end
	
	def exp(s)
		
		parencounter = 0
		i = 0
		while(s[i] != nil)
			if(s[i].kind() == "(")
				parencounter = parencounter + 1
			elsif(s[i].kind() == ")")
				parencounter = parencounter - 1
			elsif(parencounter == 0 && s[i].kind() == "+")
				index = i
			end
			i = i+1
		end
		
		if index != nil
			return exp(s[0,index]) + term(s[index+1,s.length])
		end
		
		parencounter = 0
		i = 0
		while(s[i] != nil)
			if(s[i].kind() == "(")
				parencounter = parencounter + 1
			elsif(s[i].kind() == ")")
				parencounter = parencounter - 1
			elsif(parencounter == 0 && s[i].kind() == "-")
				index = i
			end
			i = i+1
		end
		
		if index != nil
			return exp(s[0,index]) - term(s[index+1,s.length])
		end
		return term(s)
	end
	
	
	
	def term(s)
		
		parencounter = 0
		i = 0
		while(s[i] != nil)
			if(s[i].kind() == "(")
				parencounter = parencounter + 1
			elsif(s[i].kind() == ")")
				parencounter = parencounter - 1
			elsif(parencounter == 0 && s[i].kind() == "*")
				index = i
			end
			i = i+1
		end
	
		if index != nil
			return term(s[0,index]) * power(s[index+1,s.length])
		end
		
		parencounter = 0
		i = 0
		while(s[i] != nil)
			if(s[i].kind() == "(")
				parencounter = parencounter + 1
			elsif(s[i].kind() == ")")
				parencounter = parencounter - 1
			elsif(parencounter == 0 && s[i].kind() == "/")
				index = i
			end
			i = i+1
		end
		
		if index != nil
			return term(s[0,index]) / power(s[index+1,s.length])
		end
		return power(s)
	end
	
	def power(s)
		parencounter = 0
		i = 0
		while(s[i] != nil)
			if(s[i].kind() == "(")
				parencounter = parencounter + 1
			elsif(s[i].kind() == ")")
				parencounter = parencounter - 1
			elsif(parencounter == 0 && s[i].kind() == "**")
				index = i
			end
			i = i+1
		end
		
		if index == nil
			return factor(s)
		else return factor(s[0,index]) ** power(s[index+1,s.length])
		end
	end
	
	def factor(s)
		case s[0].kind()
		when "("
			return exp(s[1,s.length-2])
		when "id"
			if @vars.key?(s[0].value())
				return @vars[s[0].value()]
			else puts "uninitialized variable"
			end
		when "num"
			return s[0].value()
		when "sqrt"
			return Math.sqrt(exp(s[1,s.length]))
		end	
	end
	
	def calc()
		scanner = Scanner.new()
		t = scanner.next_token()
		i = 0
		s = []
		while(t.kind() != "eof")
			s[i] = t
			i = i + 1
			t = scanner.next_token()
		end
		program(s)
	end
end

