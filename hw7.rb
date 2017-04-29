require_relative "scan.rb"

s = Scanner.new()
t = s.next_token()

while(t.kind != 'exit' && t.kind != 'quit' && t.kind != 'eof')
	t = s.next_token()
end