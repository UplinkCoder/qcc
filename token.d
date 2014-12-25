module qcc.token;

enum TokenType : int {
	INVALID = 0,
	
	BOF = -9,


	LESS = '<',
	GREATER = '>',
	BRACKET_OPEN = '[',
	BRACKET_CLOSE= ']',
	CURLY_BRACE_OPEN = '{',
	CURLY_BRACE_CLOSE = '}',
	PAREN_OPEN = '(', 
	PAREN_CLOSE = ')',

	TYPE = -1,
	IDENTIFIER = -2 ,		 // needs context
	STRING_LITERAL = -3 ,	 // needs context
	INTEGER_LITERAL = -4, // needs context

	ASSIGN = '=',
	DOT = '.',
	COMMA = ',',

	SEMICOLON = ';',
	PLUS = '+',
	MINUS = '-',
	STAR = '*',
	SLASH = '/',

	STRUCT = -5,
	UNION = -6,
	RETURN = -7,

	PP_INCLUDE = -8,
	TYPEDEF = -9,

	EQUALS = -10,
	EOF = -11
}

struct Token {
	TokenType type;
	uint string_id_or_value;
	int line = -1;
	int col = -1;

	this(TokenType type, uint string_id_or_value, int line, int col) {
		this.type = type;
		this.string_id_or_value = string_id_or_value; 
		this.line = line;
		this.col = col;
	}

	this(char c, int line, int col) {
		import std.conv;
		//TODO get rid of to!(TokenType)
		this.type = to!(TokenType)(c);

		this = Token(type, line, col);
	}

	this(TokenType type, int line, int col) {
		this = Token(type, 0, line, col);
	}

	 @property uint length() {
		 assert(0, "length is on the TODO list");
	 }

	string toString() {
		import std.conv;
		return "Type : " ~ to!string(type) ~ " Val : " ~  to!string(string_id_or_value) ~ " Line: " ~ to!string(line) ~ " Colum :" ~ to!string(col);
	}

	bool opEquals(TokenType that) {
	//if (isUniqueToken())
		return type == that;
	//	else {
	//		assert("cannot compare variable tokens yet");
	//	}
	}
	
	
}