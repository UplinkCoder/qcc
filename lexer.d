module qcc.lexer;
import std.stdio;

static immutable string[] reservedStrings = [
	"unsigned",

	"void",
	"char",
	"short",
	"int",

	"union",
	"struct",

	"for",
	"continue",
	"if",
	"else",
	"return",

	"#include",
	"#define",
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
	public struct Identifier {
		uint id;
		string value;
		bool isType;

		bool opEquals(Identifier that) {
			return this.id == that.id;
		}

	}

	static bool isType(string s) {
		return s == "void" || s == "char" ||  s == "short" || s == "int";
	}

	import qcc.token;
	Identifier[string] intrmap;

	//intrmap = getMap!reservedStrings;

	
	string source;
	int line;  /// current line we are on
	int col; /// current colum in line
	uint pos; ///current position in the string
	Token[] tokens;

	Token[] lex(string source) {

		foreach (uint i,s;reservedStrings) {
			intrmap[s] = Identifier(i+1, s, isType(s));
		}

		this.source = source;
		import std.stdio;
		tokens ~= Token(TokenType.BOF, 0, 0);

		while(pos < source.length) {
			auto tok = getToken();
			if (tok.type != TokenType.INVALID) {
				writeln(tok);
				tokens ~= tok;
			} else {
				assert(0,"INVALID TOKEN");
			}
		}

		auto ret = tokens.dup;

		this.source = "";
		this.line = 0;
		this.col = 0;
		this.tokens = null;

		return ret;
	}

	uint getStringId (string s) {
		return getIdentifier(s, false).id;
	}

	Identifier getIdentifier(string s, bool isType) {
		uint n = cast(uint) intrmap.length+1;
		auto id = intrmap.get(s,Identifier.init);

		return (id == Identifier.init) ? intrmap[s] = Identifier(n, s, isType) : id;
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

			if (c == '=' && source[pos .. $][-0] == '=') {
				col++;
				pos++;
				return Token(TokenType.EQUALS, line, col-2);
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
			|| c == '{'  || c == '}' || c == '<' || c == '>'
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

		bool isType = (tokens[$-1].type == TokenType.STRUCT || tokens[$-1].type == TokenType.UNION) || isType(str);
		auto id = getIdentifier(str, isType);

		auto strId = id.id;
		TokenType type;

		switch (strId) {
			case getReservedStringId!("if") :
				type = TokenType.IF;
				break;
			case getReservedStringId!("else") :
				type = TokenType.ELSE;
				break;
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
				type = id.isType ? TokenType.TYPE : TokenType.IDENTIFIER;
			break;
		}

		/*if (id.isType) {
			ubyte stars;
			while (getToken().type == TokenType.STAR) {
				stars++;
			}

			return Token(TokenType.TYPE, stars, strId, line, _col);
		}*/

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
