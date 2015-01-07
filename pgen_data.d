/+module pgen_data;

//Predefined_Range {
//	Identifier {
//		[_a-zA-Z][] 
//	}
//
//	Number {
//		[0-9][]
//	}
//}
//
//Group {
//	Identifier name, "{", PatternElement[] elements : "," / Group[] groups, "}"
//}
//
//PatternElement {
//
//	AnnotatedElement {
//		PatternElement element, "@", Identifier annotation;
//		// Kinda broken since this also matches to Element @   annotation;
//	}
//
//	ConstantElement {
//		// @abstract means it canot be matched to an ConstantElement
//		// but only as part of a Pattern
//		subRange @abstract {
//			char rangeBegin, "-", char RangeEnd
//		}
//
//		RangeElement {
//			"[", subRange[] ranges, "]"
//		}
//
//		StringElement {
//			"\"" char[] string_ "\"" 
//		}
//
//		LookbehindElement {
//			"!lb", "(", "(", int n, ")" StringElement str_elm, ")"
//		}
//
//	}
//
//
//
//	NamedElement {
//		Identifier type ? "[]" : bool isArray = true, Identifier name 
//			? ":" : StringElement lst_sep;
//	}
//
//	ParenElement {
//		"(" PatternElement[] elements : ",", ")" 
//	}
//	
//	
//}

class PatternElement {
	union {
		CharRange range;
		char[] string_;
		PatternElement[] elements;

	}
}

string comment = `
Comment {
	MultiLineComment {
		"/*", char[] comment, "*/" 
	}

	SingleLineComment {
		"//", char[] comment, "\n"
		//EOL matches End Of Line
	}

}`;
string decl = `
Declaration {

	VariableDeclaration {
		Type type, Identifier identifier, ? "=" : Expression initalizer
	}
	
	Type {
		?lb(("struct" / "typedef") Identifier type;
	}

	TypeDeclaration {

		StructDeclaration {
			"struct", Type name, "{", Declaration[] declarations : ";", "}"
		}
		
		TypeDef {
			"typedef", Type old, Type new ";"
		}
	}
	
}
`;
string expr = `
Expression {
	
	IdentifierExpression {
		Identifier expr
	}

	CallExpression {
		Identifier, "(", Expression[] parameters : ",", ")"
		// type[] identifer : ListContinue_marker 
	}

	StringLiteral {
		"\"", char[] str, "\"" 
	}

	IntegerLiteral {
		int val
	}
}
`;
string stmt = `
Statement {

	DeclarationStatement {
		Declaration decl, ";"
	}

	ExpressionStatement {
		Expression expr, ";"
	}

	BlockStatement {
		"{", Statement[] statements, "}"
	}

	AssignmentStatement {
		Identifier var, "=", Expression expr ";"
	}

	IfStatement {
		"If", "(", Expression cond, ")",
		BlockStatement thn, ? "else" : BlockStatement els 
	}


}
`;
SingleLineComment parseSingleLineComment() {
	char[] comment;

	match("//");
	while(!opt_match("\n")) {
		comment ~= pop();
	}

	return SingleLineComment(comment);
}

AssignmentStatement parseAssignmentStatement() {
	Identifier var;
	Expression expr;

	var = parseIdentifier();
	match("=");
	expr = parseExpression();
	match(";");

	return AssignmentStatement(var, expr);
}

BlockStatement parseBlockStatement() {
	Statement[] statements;

	match("{");
	while(!opt_match("}")) {
		statements ~= parseStatement();
	}

	return BlockStatement(statements);
}

IfStatement parseIfStatement() {
	Expression cond;
	Statement thn;
	Statement els;

	match("If");
	match("(");
	cond = parseExpression();
	match(")");
	thn = parseBlockStatement();

	if (opt_match("else") ) {
		els = parseBlockStatement();
	} 

	return IfStatement(cond, thn, els);
}


string ASTdscr = 
`class Statement {}

class BlockStatement : Statement {
	Statement[] statements;

	this(Statement[] statements) {
		this.statements = statements;
	}
}

class IfStatement : Statement {
	Expression cond;
	BlockStatement thn;
	BlockStatement els;

	this(Expression cond, BlockStatement thn, BlockStatement els) {
		this.cond = cond;
		this.thn = thn;
		this.els = els
	}
}`;
Description parseDescription () {
	Group[] groups;

	bool goOn = true;
	while (goOn) {
		groups ~= parseGroup();
	}

}

Group parseGroup() {
	string group_name;

	bool hasGroup;
	bool hasPattern;

	union {
		Group g;
		Pattern p;
	} u;

}

string genAST (Description des) {
	string result;

	foreach (group;des.groups) {
		result ~= genAST(group);
	}
}



struct Token {

	enum TokenType {
		chr_lit,
		str_lit,

		ident_tok,
		chr_tok,

//		lbrace,
//		rbrace,
//		lprarn,
//		rparen
//		lbracket,
//		rbracket
	}

	union Data {
		string slit;
		char clit;

		string id;
		char tok;
	}

	TokenType type;
	Data data;
}+/