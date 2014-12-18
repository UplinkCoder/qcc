module qcc.lexer;
import std.stdio;

struct Lexer {
	import qcc.token;
	size_t[string] intrmap;

	
	string source;
	int line;  /// current line we are on
	int col; /// current colum in line
	uint pos; ///current position in the string

	Token[] lex(string source) {
		writeln(isIdentifier(' '));
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
		if (pos>=source.length) return Token(TokenType.EOF,line,col);
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
		writeln("in lex_pp");
		assert(source[pos .. $][0] == '#');

		auto tok = lex_identifier();
		if(tok.string_id_or_value == getStringId("#include")) {
			return Token(TokenType.PP_INCLUDE, 0, tok.line, tok.col);
		}

		//throw instead of assert
		import std.conv;
		assert(0, "no know PreProcessor Decl at " ~ to!string(line) ~ ":" ~ to!string(col)~ source[pos .. $]);
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
		
		return Token(TokenType.IDENTIFIER, strId, line, _col);
	}

	Token lex_integer_literal() {
		int value;
		int _col = col;
		while (isNumber(source[pos .. $][0])) {

			value += (source[pos .. $][0] - '0') * ((col - _col)^10);
			pos++;
			col++;
		}

		return Token(TokenType.INTEGER_LITERAL, value, line, col);

	}
}
