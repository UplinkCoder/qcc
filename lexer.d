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

	 Token getToken() {
		 _source = source [pos .. $];
		 char c = _source[0];
		 import std.stdio;
		 writeln("first char ",c ," at ", pos);
		 switch (c) {
				case '#' :
					return lex_pp();
				case '<','>','[',']','{','}','(',')','.',';','*' :
					pos++;
					return Token(c,line,col++);
				case 'a' .. 'z', 
				case ' ','\t' :
					pos++;
					col++;
					return getToken();
				case '\n' :
					pos++;
					line++;
					col = 0;
					return getToken();

				default : assert(0, "I don't know a token that strarts with " ~ c ~ ".");
		 }
	 }

	 Token lex_pp() {
		import std.conv;
		switch (_source[0 .. "#include".length]) with (TokenType) {
			 case "#include" :
				 writeln("case");
				 auto tok = Token(PP_INCLUDE, line, col);
				 pos += "#include ".length;
				 col += "#include ".length;
				 writeln("before returning PP_INCLUDE");
				 return tok;
			default : assert(0, "no know PreProcessor Decl at " ~ to!string(line) ~ ":" ~ to!string(col)~ _source);
		 }
	 }
}