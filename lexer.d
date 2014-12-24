module qcc.lexer;
import std.stdio;

static immutable string[] reservedStrings = [
	"union",
	"struct",
	"return",
	"#include",
] ;

int getReservedStringId(string s)() {
	foreach(immutable int i,immutable _s;reservedStrings) {
		if (_s == s) {
			return i+1;
		}
	}
	assert(0);
}


struct Lexer {
	import qcc.token;
	size_t[string] intrmap;

	//intrmap = getMap!reservedStrings;

	
	string source;
	int line;  /// current line we are on
	int col; /// current colum in line
	uint pos; ///current position in the string

	Token[] lex(string source) {

		foreach (i,s;reservedStrings) {
			intrmap[s] = i+1;
		}

		this.source = source;
		import std.stdio;
		Token[] ret;
		while(pos < source.length) {
			auto tok = getToken();
			if (tok.type != TokenType.INVALID) {
				writeln(tok);
				ret ~= tok;
			} else {
				assert(0,"INVALID TOKEN");
			}
		}

		this.source = "";
		this.line = 0;
		this.col = 0;

		return ret;
	}

	size_t getStringId(string s) {
		size_t n = intrmap.length+1;
		if (auto id = intrmap.get(s,0)) {
			return id;
		} else {
			return intrmap[s] = n;
		}
	}

	Token getToken() {
		if (pos>=source.length) return Token(TokenType.EOF, line, col);
		char c = source [pos .. $][0];
		
		if (isSingleToken(c)) {
			pos++;

			if(c == '\n') {
				col=0;
				line++;
			} else {
				col++;
			}

			return isWhiteSpace(c) ? getToken() : Token(c,line,col-1);
		} else if (isIdentifier(c)) {
			return lex_identifier();
		} else if (isNumber(c)) {
			return lex_integer_literal();
		}
		
		switch (c) {
			case '#' :
				return lex_pp();

			case '"' : 
				return lex_string();

				//TODO change this to throw
			default : assert(0, "I don't know a token that strarts with " ~ c ~ ".");
		}
	}

	bool isWhiteSpace(char c) {
		return (c == ' ' || c == '\t' || c == '\n');
	}

	bool isSingleToken(char c) {
		return (c == ' ' || c == '\t'|| c == '.' || c == ';'
			|| c == '('  || c == ')' || c == '[' || c == ']'
			|| c == '+'  || c == '-' || c == '*' || c == '/'
			|| c == '{'  || c == '}' || c == '&' || c == '|'
			|| c == '\n' || c == '='  || c == ',');
	}

	bool isIdentifier(char c) {
		return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_')); 
	}

	bool isNumber(char c) {
		return (c >= '0' && c <= '9');
	}
	
	Token lex_pp() {
		import std.stdio;
		assert(source[pos .. $][0] == '#');

		return lex_identifier;
	}

	Token lex_string() {
		string str;
		int _col = col;

		assert(source[pos .. $][0] == '"');
		pos++;
		col++;

		while (source[pos .. $][0] != '"') {
			str ~= source[pos .. $][0];
			pos++; 
			col++;
		}
		pos++;
		col++;

		auto strId = getStringId(str);

		return Token(TokenType.STRING_LITERAL, strId, line, _col);	
	}

	Token lex_identifier() {
		string str;
		int _col = col;

		if (source[pos .. $][0] == '#') { //NOTE: special case for preProcessor stuff 
			str ~= '#';
			pos++;
			col++;
		}

		while (isIdentifier(source[pos .. $][0]) || isNumber(source[pos .. $][0]) ) {
			str ~= source[pos .. $][0];
			pos++; 
			col++;
		}

		auto strId = getStringId(str);
		TokenType type = TokenType.IDENTIFIER;

		switch (strId) {
			case getReservedStringId!("union") :
				type = TokenType.UNION;
				break;
			case getReservedStringId!("struct") :
				type = TokenType.STRUCT;
				break;
			case getReservedStringId!("return") :
				type = TokenType.RETURN;
			break;
			case getReservedStringId!("#include") :
				type = TokenType.PP_INCLUDE;
			break;
			default : 
				type = TokenType.IDENTIFIER;
			break;
		}

		return Token(type, strId, line, _col);
	}

	Token lex_integer_literal() {
		int _col = col;
		int value;
		while (isNumber(source[pos .. $][0])) {
			pos++;
			col++;
		}

		for (int i=col - _col; i>0;--i) {
			import std.math:pow;
			value += (source[pos-i .. $][0] - '0') * pow(10,i-1);
		}

		return Token(TokenType.INTEGER_LITERAL, value, line, col);

	}
}
