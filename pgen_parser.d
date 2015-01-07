module pgen_parser;

Token[] lex(in string source) pure {
	uint col;
	uint line;
	uint pos;
	Token[] result;

//	uint[string] intrmap;

	char peek(int offset) {
		if (pos + offset > source.length - 1) return '\0';
		assert(pos + offset <= source.length && pos + offset >= 0);
		return source[pos + offset];
	}

	bool isWhiteSpace(char c) pure {
		return (c == ' ' || c == '\t' || c == '\n');
	}

	bool isIdentifier(char c) pure {
		return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '_' && c <= '_')); 
	}
	
	bool isNumber(char c) pure {
		return ((c >= '0' && c <= '9'));
	}

	TokenType fixedToken(char[3] c) pure {
		switch (c[0]) {
		//	case '\n' : 
		//		return TokenType.newline;
			case '/' :
				return TokenType.slash;

			case '\0' : 
				return TokenType.eof;

			case ']' : 
				return TokenType.rbracket;

			case '{' : 
				return TokenType.lbrace;
					
			case '}' : 
				return TokenType.rbrace;

			case '(' : 
				return TokenType.lparen;
				
			case ')' : 
				return TokenType.rparen;
						
			case ':' : 
				return TokenType.colon;
			
			case ',' : 
				return TokenType.comma;
						
			case '@' : 
				return TokenType.at;

			case '[' :
				switch (c[1]) {
					case ']' :
						return TokenType.lrbracket;

					default : 
						return TokenType.lbracket;
				}


			case '?' : 
				switch (c[1..$]) {
					case "lb" : 
						return TokenType.lookbehind;
					default : 
						return TokenType.questionmark;
				}


			default :
				return TokenType.INVALID;

		}
	}

	void putDataToken(TokenType ttype, char[] data) {
		assert(ttype == TokenType.identifier 
			|| ttype == TokenType.char_
			|| ttype == TokenType.string_
			|| ttype == TokenType.number);
		
		uint length = cast(uint) data.length;

		if (ttype == TokenType.char_ || ttype == TokenType.string_) {
			length += 2;
		}

		result ~= Token(ttype, line, col, length, data);
		
		col += length;
		pos += length;
	}

	void putToken(TokenType ttype) {
		assert(ttype);
		assert(ttype != TokenType.identifier 
			&& ttype != TokenType.char_
			&& ttype != TokenType.string_
			&& ttype != TokenType.number);

		uint length = 1;

		switch(ttype) {
			case TokenType.lrbracket :
				length = 2;
			break;
			case TokenType.lookbehind :
				length = 3;
			break;
	//		case TokenType.newline :
	//			line++;
	//			col = -1;
	//			return;
			default :
				break;
		}

		result ~= Token(ttype, line, col, length, null);

		col += length;
		pos += length;
	}

	void lexIdentifier() {
		char[] identifier;
		char p = peek(0);
		
		while (isIdentifier(p)) {
			identifier ~= p;
			p = peek(cast(uint) identifier.length);
		}
		
		assert(identifier.length > 0);
		
		putDataToken(TokenType.identifier, identifier);
	}

	void lexChar() {
		assert(peek(0) == '\'');
		char chr = peek(1);
		assert(peek(2) == '\'');


		putDataToken(TokenType.char_, [chr]);
	}

	void lexString() {
		assert(peek(0) == '"');

		char[] string_;
		char p = peek(1);

		while(p != '"') {
			string_ ~= p;
			p = peek(cast (uint) string_.length + 1);
		}

		putDataToken(TokenType.string_, string_);
	}

	void lexNumber() {
		char[] number;
		char p = peek(0);
		
		while (isNumber(p)) {
			number ~= p;
			p = peek(cast(uint) number.length);
		}
		
		assert(number.length > 0);
		
		putDataToken(TokenType.number, number);
	}

	void tokenize() {
//	result ~= Token.init;
		while (pos<source.length) {
//			debug {
//			import std.stdio;
//			writeln(pos,":",source.length,result[$-1]);
//			}
			char p = peek(0);

			if (isWhiteSpace(p)) {
				if(p == '\n') {
					line++;
					col = 0;
				} else {
					col++;
				}
				pos++;
			}

			if (auto t = fixedToken([p, peek(1), peek(2)])) {
				putToken(t);
			} else if (isIdentifier(p)) {
				lexIdentifier();
			} else if (isNumber(p)) {
				lexNumber();
			} else if (p == '"') {
				lexString();
			} else if (p == '\'') {
				lexChar();
			} else {
				import std.conv;
				//assert("char '" ~to!string(p) ~ "' is not handeled" );
			}
		}

		putToken(TokenType.eof);
		return;
	}

	tokenize();

	return result;
}


enum  TokenType {
	//CharClassTokens:
	INVALID = 0,

	BOF,

	identifier, // [a-zA-Z_]
	number, // [0-9]
	string_, // "bla"
	char_, // 'b'

	newline, // \n
	lookbehind, // !lb
	minus, // -
	at, // @
	
	lbracket,// [
	rbracket,// ]
	lrbracket, // []
	lparen, // (
	rparen, // )
	lbrace, // {
	rbrace, // }
	slash, // /
	singlequote, // '
	doublequote, // "
	questionmark, // ?
	colon, // :
	comma, // ,

	eof // End of File
}

struct Token {
	TokenType type;

	uint line;
	uint col;
	uint length;

	char[] data;
}

Group parse(in Token[] tokens) pure {
	struct Parser {
	pure:
		const(Token[]) tokens;
		uint pos;
		Token lastMatched;

		this(const(Token[]) tokens) pure {
			this.tokens = tokens;
		}
		import std.traits;

		auto peekParse(F)(F parseFunction)
		if(is(F == delegate)) {
			auto oldpos = pos;
			auto result = parseFunction();
			pos = oldpos;
			return result;
		}

		const(Token) peekToken(int offset) {
			assert(pos + offset <= tokens.length && pos + offset >= 0);
			return tokens[pos + offset];
		}


		bool peekMatch(TokenType[] arr) {
			foreach (uint i,e;arr) {
				if(peekToken(i).type != e) {
					return false;
				}
			}
			return true;
		}

		bool opt_match(TokenType t) {
			lastMatched = cast(Token) peekToken(0);
			
			if (lastMatched.type == t) {
				pos++;
				return true;
			} else {
				lastMatched = Token.init;
				return false;
			}
		}

		Token match(TokenType t) {
			import std.conv;
			import std.exception:enforce;

			enforce(opt_match(t), "Expected : " ~ to!string(t) ~ " Got : " ~ to!string(peekToken(0).type));

			return lastMatched;
		}

		bool isGroup() {
			return peekMatch([TokenType.identifier, TokenType.lbrace]);
		}

		bool isAlternativeElement() {
			return typeid(peekParse(&parseAlternativeElement)) is typeid(AlternativeElement);
		}

		bool isRangeElement() {
			return peekMatch([TokenType.lbracket]);
		}
		
		bool isCharElement() {
			return peekMatch([TokenType.char_]);
		}
		
		bool isStringElement() {
			return peekMatch([TokenType.string_]);
		}
		
		bool isLookbehindElement() {
			return peekMatch([TokenType.lookbehind]);
		}
		
		bool isConstantElement() {
			return isRangeElement() 
				|| isCharElement()
				|| isStringElement()
				|| isLookbehindElement();
		}
		
		bool isOptinalElement() {
			return peekMatch([TokenType.questionmark]);
		}
		
		bool isNamedElement() {
			return peekMatch([TokenType.identifier, TokenType.identifier]);
		}
		
		bool isArrayElement() {
			return peekMatch([TokenType.identifier, TokenType.lrbracket]);
		}

		bool isParenElement() {
			return peekMatch([TokenType.lparen]);
		}

		bool isPatternElement() {
			return isAlternativeElement()
				|| isConstantElement()
				|| isNamedElement()
				|| isArrayElement()
				|| isOptinalElement()
				|| isParenElement();
		}

		Identifier parseIdentifier() {
			Token id = match(TokenType.identifier);
			return new Identifier(id.data);
		}

		PatternElement parseAlternativeElement() {
			PatternElement[] alternatives;

			alternatives ~= parsePatternElement();

			while (opt_match(TokenType.slash)) {
				alternatives ~= parsePatternElement();
			}

			if (alternatives.length > 1) {
				return new AlternativeElement(alternatives);
			} else {
				return alternatives[0];
			}
		}

		PatternElement parsePatternElement() {
			 if (isConstantElement()) {
				return parseConstantElement();
			} else if (isArrayElement()) {
				return parseArrayElement();
			} else if (isNamedElement()) {
				return parseNamedElement();
			} else if (isOptinalElement()) {
				return parseOptionalElement();
			} else if (isParenElement()) {
				return parseParenElement();
			} else {
				assert(0, "No matching PatternElement");
			}
		}

		ConstantElement parseConstantElement() {
			if (isRangeElement()) {
				return parseRangeElement();
	//		} else if (isCharElement()) {
	//			return parseCharElement();
			} else if (isStringElement()) {
				return parseStringElement();
			} else if (isLookbehindElement()) {
				return parseLookBehindElement();
			} else {
				assert(0, "No matching ConstantElement");
			}
		}

		Group parseGroup() {
			Identifier name;
			
			name = parseIdentifier();
			match(TokenType.lbrace);
			
			if (isGroup() /*|| 
			peekMatch([TokenType.identifier,TokenType.at, TokenType.identifier, TokenType.lbracket])*/) {
				Group[] groups;
				
				while (!opt_match(TokenType.rbrace)) {
					groups ~= parseGroup();
				}
				assert(groups.length > 0);
				
				return new Group(name, groups);
			} else if (isPatternElement()) {
				PatternElement[] elements;
				
				while (!opt_match(TokenType.rbrace)) {
					
					elements ~= parseAlternativeElement();
					opt_match(TokenType.comma);
				}
				assert(elements.length > 0);
				
				return new Group(name, elements);  
			} else {
				assert(0,"No matching Group");
			}
		}

		CharRange parseCharRange() {
			char rangeBegin;
			char rangeEnd;
			
			rangeBegin = match(TokenType.char_).data[0];

			if (opt_match(TokenType.minus)) {
				rangeEnd = match(TokenType.char_).data[0];
			} else {
				rangeEnd = rangeBegin;
			}

			return new CharRange(rangeBegin, rangeEnd);
		}

		RangeElement parseRangeElement() {
			CharRange[] ranges;

			match(TokenType.lbracket);
			
			while(!opt_match(TokenType.rbracket)) {
				ranges ~= parseCharRange();
			}
			
			assert(ranges.length > 0);
			
			return new RangeElement(ranges);
		}

		StringElement parseStringElement() {
			return new StringElement(match(TokenType.string_).data);
		}

		LookBehindElement parseLookBehindElement() {
			StringElement str_elm;
			
			match(TokenType.lookbehind);
			match(TokenType.lparen);
			
			str_elm = parseStringElement();
			assert(str_elm);
			
			match(TokenType.rparen);
			
			return new LookBehindElement(str_elm);
		}

		ParenElement parseParenElement() {
			PatternElement[] elements;
			match(TokenType.lparen);
			
			while(opt_match(TokenType.comma)) {
				elements ~= parseAlternativeElement();
			}
			
			match(TokenType.rparen);
			
			return new ParenElement(elements);
		}


		NamedElement parseNamedElement() {
			auto type = parseIdentifier();
			auto name = parseIdentifier();
			
			return new NamedElement(type, name);
		}

		ArrayElement parseArrayElement() {
			auto type = parseIdentifier();
			match(TokenType.lrbracket);

			auto name = parseIdentifier();

			string listSeperator = void;
			if (opt_match(TokenType.colon)) {
				listSeperator = match(TokenType.string_).data.idup;
			}

			return new ArrayElement(type, name, listSeperator);
		}

		OptionalElement parseOptionalElement() {
			match(TokenType.questionmark);
			auto cond = parseConstantElement();
			
			match(TokenType.colon);
			auto elem = parseAlternativeElement();
			
			return new OptionalElement(cond, elem);
		}

	}

	return Parser(tokens).parseGroup();
}

class CharRange {
	char rangeBegin;
	char rangeEnd;
	
	this(char rangeBegin, char rangeEnd) pure {
		this.rangeBegin = rangeBegin;
		this.rangeEnd = rangeEnd;
	}
}

abstract class Node {}
abstract class Range : Node {}
abstract class PredefinedRange : Range {}

class Identifier : PredefinedRange {
	char[] identifier;
	this(char[] identifier) pure {
		this.identifier = identifier;
	}
}

class Group : Node {
	Identifier name;
	bool hasGroups;

	union {
		Group[] groups;
		PatternElement[] elements;
	}

	this(Identifier name, Group[] groups) pure {
		this.name = name;
		this.groups = groups;
		this.hasGroups = true;
	}

	this(Identifier name, PatternElement[] elements) pure {
		this.name = name;
		this.elements = elements;
	}
}


abstract class PatternElement {}

class AlternativeElement : PatternElement {
	PatternElement[] alternatives;
	this(PatternElement[] alternatives) pure {
		this.alternatives = alternatives;
	}
}

abstract class ConstantElement : PatternElement {}

class RangeElement : ConstantElement {
	CharRange[] ranges;
	this(CharRange[] ranges) pure {
		this.ranges = ranges;
	}
}

class StringElement : ConstantElement {
	char[] string_;
	this(char[] string_) pure {
		this.string_ = string_;
	}
}

class LookBehindElement : ConstantElement {
	StringElement str_elm;
	this(StringElement str_elm) pure {
		this.str_elm = str_elm;
	}
}

class ParenElement : PatternElement {
	PatternElement[] elements;
	this(PatternElement[] elements) pure {
		this.elements = elements;
	}
}

class NamedElement : PatternElement {
	Identifier type;
	Identifier name;
	
	this(Identifier type, Identifier name) pure {
		this.type = type;
		this.name = name;
	}
}

class ArrayElement : PatternElement {
	Identifier type;
	Identifier name;
	string lst_sep;

	this(Identifier type, Identifier name, string lst_sep) pure {
		this.type = type;
		this.name = name;
		this.lst_sep = lst_sep;
	}
}

class OptionalElement : PatternElement {
	ConstantElement cond;
	PatternElement elem;

	this(ConstantElement cond, PatternElement elem) pure {
		this.cond = cond;
		this.elem = elem;
	}
}

struct ConstructorVisitor {
	import visitor;

	uint pos;
	uint[] alternativePositions;
	bool[] hasConsturctorElement;
	string[] alternativeParams;
	string[] alternativeBodys;

	struct Constructor {
		string params;
		string _body;
	}

	Constructor[] constructors;

	string visit(ParenElement[] elements) {
		string ret;

		foreach (element;elements) {
			dispatch!((a){return "";})(this, element);
		}

		foreach(constructor;constructors) {
			ret ~= "\tthis(" ~ constructor.params ~ ") {\n" ~
				constructor._body ~ "\t}\n";
		}

		return ret;
	}

	void visit(AlternativeElement ae) {
		alternativePositions ~= pos;

		foreach (i,alt;ae.alternatives) {
			AlternativeElement cons = visit(alt);
			if (cons != Constructor.init) {

			}
			if (as != "") {
				tmp ~= as;
			}
		}

		result ~= "\t\t" ~ str.split("[]").split(" ")[0][0].toUpper ~ ",\n";
	}
}

struct PTreeVisitor {
	import visitor;
	string parent_name;

	string visit(Group[] groups) {
		string result;

		foreach(group;groups) {
			result ~= visit(group);
		}

		return result;
	}

	string visit(PatternElement pe) {
		return dispatch!((a){return "";})(this, pe);
	}

	string visit(AlternativeElement ae) {
		string result;
		string[] tmp;
		foreach (alt;ae.alternatives) {
			auto as = visit(alt);
			if (as != "") {
				tmp ~= as;
			}
		}
		if (tmp.length > 0) {
			result ~="enum {\n";
			import std.string;
			foreach(str;tmp) {
				result ~= "\t\t" ~ str.split("[]").split(" ")[0][0].toUpper ~ ",\n";
			}
			result ~= "\t}\n";

			result ~= "\tunion {\n";
			foreach(str;tmp) {
				result ~= "\t\t" ~ str;
			}
			result ~= "\t}\n";
		}
		return result;
	}

	string visit(NamedElement ne) {
		return cast(string) (ne.type.identifier ~ " " ~ ne.name.identifier ~ ";\n");
	}

	string visit(OptionalElement oe) {
		return dispatch(this, oe.elem);
	}

	string visit(ArrayElement ae) {
		return cast(string) (ae.type.identifier ~ "[] " ~ ae.name.identifier ~ ";\n");
	}

	string visit(Group group) {
		string result;


		if (group.hasGroups) {
			result ~= "abstract class " ~ group.name.identifier;
			if (parent_name) {
				result ~= " : " ~ parent_name;
			}
			result ~= " {}\n\n";
			string old_parent = parent_name;
			parent_name = cast(string) group.name.identifier;
			foreach(group_;group.groups) {
				result ~= visit(group_);
			}
			parent_name = old_parent;
		} else {
			result ~= "class " ~ group.name.identifier;
			if (parent_name) {
				result ~= " : " ~ parent_name;
			}
			result ~= " {\n";
			foreach(element;group.elements) {
				auto s = visit(element);
				result ~= (s != "") ? "\t" ~ s : "";
			}
			result ~= "\n";

			result ~= ConsturctorVisitor().visit(group.elements);

			result ~= "}\n";
		}

		return result;
	}
}