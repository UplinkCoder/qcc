module qcc.lexer;

import std.stdio;

/*
 TOKEN_BOF
 PP_TOKEN_INCLUDE, TOKEN_ANGLE_BRACKET_OPEN, TOKEN_IDENTIFIER, TOKEN_DOT, TOKEN_IDENTIFER, TOKEN_ANGLE_BRACKET_CLOSE
 TOKEN_INT, TOKEN_IDENTIFIER, TOKEN_PAREN_OPEN, TOKEN_INT, TOKEN_IDENTIFIER, TOKEN_COMMA,
 TOKEN_CHAR,	TOKEN_STAR, TOKEN_IDENTIFIER, TOKEN_BRACKET_OPEN, TOKEN_BRACKET_CLOSE, TOKEN_PAREN_CLOSE, TOKEN_CURLY_BRACE_OPEN
 TOKEN_IDENIFIER, TOKEN_PAREN_OPEN, TOKEN_STRING_LITERAL, TOKEN_PAREN_CLOSE, TOKEN_SEMICOLON
 TOKEN_RETURN, TOKEN_INTEGER_LITERAL, TOKEN_SEMICOLON,
 TOKEN_CURLY_BRACKET_CLOSE
 TOKEN_EOF
 */
 
struct Lexer {
	import qcc.token;
	size_t[string] intrmap;

	
	string source;
	string _source;
	int line;  /// current line we are on
	int col; /// current colum in line
	uint pos; ///current position in the string

	Token[] lex(string source) {
		this.source = source;
		import std.stdio;
		Token[] ret;
		while(pos < source.length) {
			auto tok = getToken;
			if (tok.type != 0) {
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
	/// lookahead n Tokens
	Token la(ubyte n=0) {
		auto _pos = pos;
		Token tok;
		for (int i=0;i<n;i++) {
			tok = getToken();
		}
		pos = _pos;

		return tok;
	}

	Token getToken() {
		if (pos>=source.length) return Token(cast(char)-8,line,col);
		_source = source [pos .. $];
		char c = _source[0];
		switch (c) {
			case '#' :
				return lex_pp();

			case '[',']','{','}','(',')','.',';','*',',' :
				pos++;
				return Token(c,line,col++);

			case '"' : 
				return lex_string();
				
			case '_', 'a', 'b', 'c', 'd', 'e', 'f','g', 'h', 'i', 'j', 'k', 'l', 'm',
					'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' :
				return lex_identifier();

			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' :
				return lex_integer_literal();
				
			case ' ','\t' :
				pos++;
 				col++;
				return getToken();
			case '\n' :
				pos++;
				line++;
				col = 0;
				return getToken();
				//TODO change this to throw
			default : assert(0, "I don't know a token that strarts with " ~ c ~ ".");
		}
	}

	
	Token lex_pp() {
	
	assert(_source[0] == '#');

	auto tok = lex_identifier(); 
	if(tok.value.stringId == getStringId("#include")) {
		return Token(TokenType.PP_INCLUDE, 0, tok.line, tok.col);
	}

	//throw instead of assert
	import std.conv;
	assert(0, "no know PreProcessor Decl at " ~ to!string(line) ~ ":" ~ to!string(col)~ _source);
	}

	Token lex_string() {
		string str;
		int _col = col;

		assert(_source[0] == '"');
		pos++;
		col++;
		_source = _source[1 .. $];

		while (_source[0] != '"') {
			str ~= _source[0];
			pos++; 
			col++;
			_source = _source[1 .. $];
		}
		pos++;
		col++;
		_source = _source[1 .. $];

		auto strId = getStringId(str);

		return Token(TokenType.STRING_LITERAL, strId, line, _col);	
	}

	Token lex_identifier() {
		string str;
		int _col = col;
		while (_source[0] != ' ' && _source[0] != ',' && _source[0] != '(' &&  _source[0] != ')'
				&& _source[0] != ';'  && _source[0] != '[' && _source[0] != ']' && _source[0] != '.'
				&& _source[0] != '*') {
			str ~= _source[0];
			pos++; 
			col++;
			_source = _source[1 .. $];
		}
		
		auto strId = getStringId(str);
		
		return Token(TokenType.IDENTIFIER, strId, line, _col);
	}

	Token lex_integer_literal() {
		int value;
		int _col = col;
		while (_source[0] != ' ' && _source[0] != ',' && _source[0] != '(' &&  _source[0] != ')'
			   && _source[0] != ';'  && _source[0] != '[' && _source[0] != ']' && _source[0] != '.'
			   && _source[0] != '*') {
			value += (_source[0] - '0') * ((col - _col)^10);
			pos++;
			col++;
			_source = _source[1 .. $];
		}

		return Token(TokenType.INTEGER_LITERAL, value, line, col);

	}
}
