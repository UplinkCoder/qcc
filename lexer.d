module qcc.lexer;

import qcc.source;
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
		writeln(this.source);
		Token[] ret;
		while(pos < source.length) {
			auto tok = getToken;
			writeln("Token :",tok);
			if (tok.type != 0) {
				ret ~= tok;
			} else {
				assert(0,"INVALID TOKEN");
			}
			writeln(ret);
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
		_source = source [pos .. $];
		char c = _source[0];
		import std.stdio;
		writeln("first char ",c ," at ", pos);
		switch (c) {
			case '#' :
				return lex_pp();

			case '<','>','[',']','{','}','(',')','.',';','*',',' :
				pos++;
				return Token(c,line,col++);

			case '"' : 
				return lex_string();
				
//			case '_', 'a', 'b', 'c', 'd', 'e', 'f','g', 'h', 'i', 'j', 'k', 'l', 'm',
//					'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' :
//				return lex_identifier_or_keyword();
				
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
		import std.conv;
		assert(_source[0] == '#');
		_source = _source[1.. $];
		// use std.algorithm.startsWith
		switch (_source[0 .. "include".length]) with (TokenType) {
			case "include" :
				writeln("case");
				auto tok = Token(PP_INCLUDE, line, col);
				pos += "#include".length;
				col += "#include".length;
				return tok;
				//throw instead of assert
			default : assert(0, "no know PreProcessor Decl at " ~ to!string(line) ~ ":" ~ to!string(col)~ _source);
		}
	}

	Token lex_string() {
		string str;
		int _col = col;
		assert(_source[0] == '"');
		pos++;
		col++;
		_source = _source[1 .. $];

		while (_source[0] != '"') {
			pos++; 
			col++;
			_source = _source[1 .. $];
			str ~= _source[0];
		}
		pos++;
		col++;
		_source = _source[1 .. $];

		auto strId = getStringId(str);
		writeln(pos);

		return Token(TokenType.STRING_LITERAL, strId, line, _col);	
	}
}
