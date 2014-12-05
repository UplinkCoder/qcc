module qcc.token;

import qcc.source;
enum TokenType : int {
	INVALID = 0,
	
	BOF = -9,

	PP_INCLUDE = 1, 
	ANGLE_BRACKET_OPEN = '<',
	ANGLE_BRACKET_CLOSE = '>',
	BRACKET_OPEN = '[',
	BRACKET_CLOSE= ']',
	CURLY_BRACE_OPEN = '{',
	CURLY_BRACE_CLOSE = '}',
	PAREN_OPEN = '(', 
	PAREN_CLOSE = ')',
	IDENTIFIER = -2 ,		 // needs context
	STRING_LITERAL = -3 ,	 // needs context
	INTEGER_LITERAL = -4, // needs context
	DOT = '.',
	COMMA = ',',
	SEMICOLON = ';',
	STAR = '*',
	INT = -5,
	CHAR = -6,
	RETURN = -7,

	EOF = -8
}

struct Token {
	TokenType type;
	size_t string_id;
	int line = -1;
	int col = -1;

	this(TokenType type, size_t string_id, int line, int col) {
		this.type = type;
		this.string_id = string_id; 
		this.line = line;
		this.col = col;
	}

	this(char c, int line, int col) {
		import std.conv;
		this.type = to!(TokenType)(c);
		this.line = line;
		this.col = col;
	}

	bool opEquals(TokenType that) {
	//if (isUniqueToken())
		return type == that;
	//	else {
	//		assert("cannot compare variable tokens yet");
	//	}
	}
	
	
}