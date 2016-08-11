require 'strscan'

#  ebnf = { rule } ;
#  rule = identifier , '=' , definition , ';' ;
#  identifier = letter , { word | ' ' } ;
#  letter = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' | 'i'
#         | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p' | 'q' | 'r'
#         | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z'
#         | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H' | 'I'
#         | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P' | 'Q' | 'R'
#         | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z' ;
#  word = letter
#       | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
#       | '_' | ' ' ;
#  definition = alternation ;
#  alternation = concatenation, { '|', definition } ;
#  concatenation = atom, { ',', definition } ;
#  atom = '[', definition, ']'
#       | '(', definition, ')'
#       | '{', definition, '}'
#       | identifier
#       | terminal ;

module EBNF
  class Error < RuntimeError; end

  class Scanner
    class Error < EBNF::Error; end

    def initialize(input)
      @scanner = StringScanner.new(input)
      @backlog = []
    end

    PUNCT = {
      '=' => :equal,
      ';' => :terminator,
      '[' => :start_optional,
      ']' => :end_optional,
      '(' => :start_group,
      ')' => :end_group,
      '{' => :start_repeat,
      '}' => :end_repeat,
      '|' => :alternator,
      ',' => :concatenator
    }

    def shift
      return @backlog.pop if @backlog.any?

      @scanner.scan(/\s+/)
      return nil if @scanner.eos?

      pos = @scanner.pos
      at = @scanner.rest[0, 10]

      if (id = @scanner.scan(/[a-z][a-z0-9_ ]*/i))
        [ :id, id.strip, pos, at ]
      elsif @scanner.match?(/['"]/)
        [ :terminal, _scan_terminal, pos, at ]
      elsif (char = @scanner.scan(/[=;\[\](){}|,]/))
        type = PUNCT[char] or raise Error, "unknown punctuation #{char}"
        [ type, char, pos, at ]
      else
        raise Error, "unexpected character at #{@scanner.pos}, #{@scanner.rest[0..-10]}..."
      end
    end

    def unshift(token)
      @backlog.push(token)
    end

    def _scan_terminal
      quote = @scanner.scan(/['"]/)
      if quote == "'"
        content = @scanner.scan(/[^#{quote}]*/)
      else
        content = ""
        loop do
          chunk = @scanner.scan(/[^\\#{quote}]/)

          if chunk
            content << chunk
          elsif @scanner.scan(/\\/)
            escaped = @scanner.getch
            content << case escaped
              when "n" then "\n"
              else escaped
            end
          else
            break
          end
        end
      end

      @scanner.scan(/#{quote}/) or raise Error, "unterminated string"
      content
    end
  end

  class Parser
    class UnexpectedToken < EBNF::Error; end

    attr_reader :grammar

    def initialize(tokens)
      @tokens = tokens
      @grammar = Grammar.new
    end

    def parse
      _parse_rule while _peek
      @grammar
    end

    def _parse_rule
      id = _expect :id
      _expect :equal
      definition = _parse_definition
      _expect :terminator

      @grammar[id[1]] = definition
    end

    def _parse_definition
      _parse_alternation
    end

    def _parse_optional
      Optional.new(_parse_definition).tap do
        _expect :end_optional
      end
    end

    def _parse_group
      Group.new(_parse_definition).tap do
        _expect :end_group
      end
    end

    def _parse_repeat
      Repeat.new(_parse_definition).tap do
        _expect :end_repeat
      end
    end

    def _parse_alternation
      left = _parse_concatenation

      if _peek.first == :alternator
        _next
        right = _parse_definition

        if Alternation === right
          right = right.options
        else
          right = [ right ]
        end

        Alternation.new([left, *right])
      else
        left
      end
    end

    def _parse_concatenation
      left = _parse_atom

      if _peek.first == :concatenator
        _next
        right = _parse_definition

        if Concatenation === right
          right = right.options
        else
          right = [ right ]
        end

        Concatenation.new([left, *right])
      else
        left
      end
    end

    def _parse_atom
      tok = _next

      case tok.first
      when :id then Nonterminal.new(tok[1])
      when :terminal then Terminal.new(tok[1])
      when :start_optional then _parse_optional
      when :start_group then _parse_group
      when :start_repeat then _parse_repeat
      else raise UnexpectedToken, "expected id|terminal, got #{tok.inspect}"
      end
    end

    def _expect(types)
      types = [ types ] unless Array === types
      tok = @tokens.shift
      return tok if types.include?(tok.first)
      raise UnexpectedToken, "got #{tok.inspect} instead of #{types.inspect}"
    end

    def _next
      @tokens.shift
    end

    def _peek
      @tokens.shift.tap do |tok|
        @tokens.unshift(tok)
      end
    end
  end

  class Grammar
    def initialize
      @rules = {}
      @start = nil
    end

    def start
      @start && @start.symbol
    end

    def [](symbol)
      @rules[symbol]
    end

    def []=(symbol, definition)
      rule = Rule.new(symbol, definition)
      @start ||= rule
      @rules[symbol] = rule
    end

    def generate
      _expand(self[start])
    end

    def _expand(term)
      case term
        when Rule then _expand(term.definition)
        when Terminal then term.content
        when Nonterminal then _expand(self[term.content])
        when Optional then
          if rand(100) < 50
            _expand(term.definition)
          else
            ""
          end
        when Group then
          _expand(term.definition)
        when Repeat then
          s = ""
          loop do
            break if rand(100) < 50
            s << _expand(term.definition)
          end
          s
        when Concatenation then
          term.options.map { |item| _expand(item) }.join
        when Alternation then
          _expand(term.options.sample)
        else
          raise Error, "not sure what to make of #{term.inspect}"
      end
    end
  end

  class Rule < Struct.new(:symbol, :definition)
    def to_s
      "#{symbol} = #{definition}"
    end
  end

  class Terminal < Struct.new(:content)
    def to_s
      if content.include?("'")
        '"' + content + '"'
      else
        "'" + content + "'"
      end
    end
  end

  class Nonterminal < Struct.new(:content)
    def to_s
      content
    end
  end

  class Optional < Struct.new(:definition)
    def to_s
      "[ #{definition} ]"
    end
  end

  class Group < Struct.new(:definition)
    def to_s
      "( #{definition} )"
    end
  end

  class Repeat < Struct.new(:definition)
    def to_s
      "{ #{definition} }"
    end
  end

  class Concatenation < Struct.new(:options)
    def to_s
      options.map { |o| o.to_s }.join(" , ")
    end
  end

  class Alternation < Struct.new(:options)
    def to_s
      options.map { |o| o.to_s }.join(" | ")
    end
  end
end

if ENV["TEST"]
  require 'minitest/autorun'

  class ScannerTest < Minitest::Test
    def test_recognizes_alphanumeric_ids
      scanner = EBNF::Scanner.new("hello_123")
      token = scanner.shift
      assert_equal :id, token[0]
      assert_equal "hello_123", token[1]
    end

    def test_recognizes_ids_with_spaces
      scanner = EBNF::Scanner.new("hello world ")
      token = scanner.shift
      assert_equal :id, token[0]
      assert_equal "hello world", token[1]
    end

    def test_parse_single_quote_string
      scanner = EBNF::Scanner.new("'hello world'")
      token = scanner.shift
      assert_equal :terminal, token[0]
      assert_equal "hello world", token[1]
    end

    def test_parse_double_quote_string
      scanner = EBNF::Scanner.new('"hello world"')
      token = scanner.shift
      assert_equal :terminal, token[0]
      assert_equal "hello world", token[1]
    end

    def test_parse_escapes_in_double_quoted_string
      scanner = EBNF::Scanner.new('"hello\\\\\n"')
      token = scanner.shift
      assert_equal :terminal, token[0]
      assert_equal "hello\\\n", token[1]
    end

    def test_ignore_escape_in_single_quoted_string
      scanner = EBNF::Scanner.new("'hello\\\\n'")
      token = scanner.shift
      assert_equal :terminal, token[0]
      assert_equal 'hello\\\n', token[1]
    end

    def test_parse_punctuation
      EBNF::Scanner::PUNCT.each do |key, token_type|
        scanner = EBNF::Scanner.new("#{key}")
        token = scanner.shift
        assert_equal token_type, token[0]
      end
    end
  end

  class ParserTest < Minitest::Test
  end

else
  file_name = ARGV.first or abort "please specify an EBNF file"
  contents = File.read(file_name)

  scanner = EBNF::Scanner.new(contents)
  parser = EBNF::Parser.new(scanner)
  grammar = parser.parse

  10.times do |n|
    puts "%2d. %s" % [ n+1, grammar.generate ]
  end
end
