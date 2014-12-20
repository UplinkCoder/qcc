module qcc.parsetree;
import qcc.token;

abstract class Node {}

abstract class Expression : Node {}

abstract class Statement : Node {}

abstract class Declaration : Node {}

abstract class Annotation : Node {}

abstract class Reference : Node {}

abstract class ConstantExpression : Expression {}


class AssignmentStatement : Statement {
	Token variable;
	Expression expr;

	this(Token variable, Expression expr) {
		this.variable = variable;
		this.expr = expr;
	}
}

class BinaryExpression : Expression {
	Token op;
	Expression lhs;
	Expression rhs;

	this(Token op, Expression lhs, Expression rhs) {
		this.op = op;
		this.lhs = lhs;
		this.rhs = rhs;
	}
}
class StringLiteral : ConstantExpression {
	Token lit;
	//string value;
	this(Token lit) {
		assert(lit.type == TokenType.STRING_LITERAL);
		
		this.lit = lit;
		//this.value = getString(lit.string_id_or_value);
	}
	
}


class IntegerLiteral : ConstantExpression {
	Token lit;
	ulong value;
	this(Token lit) {
		assert(lit.type == TokenType.INTEGER_LITERAL);

		this.lit = lit;
		this.value = lit.string_id_or_value;
	}
	
}

class CallExpression : Expression {
	Expression[] parameters;
	Token callee;

	this(Token callee, Expression[] parameters) {
		this.callee = callee;
		this.parameters = parameters;
	}

}

class ParenExpression : Expression {
	Expression expr;

	this(Expression expr) {
		this.expr = expr;
	}
}

class CompilationUnit : Node {
	Declaration[] declarations;

	this (Declaration[] declarations) {
		this.declarations = declarations;
	}
}

//class VaraibleDefinition : VaraibleDeclaration {
//	Expression value;
//
//	this(Expression value) {
//		this.value = value;
//	}
//}

class VariableDeclaration : Declaration {
	Token type;
	Token name;

	this(Token type, Token name) {
		this.type = type;
		this.name = name;
	}
}

class FunctionDeclaration : Declaration {
	Token return_type;
	Token function_name;
	VariableDeclaration[] parameters;

	this(Token return_type, Token function_name, VariableDeclaration[] parameters) {
		this.return_type = return_type;
		this.function_name = function_name;
		this.parameters = parameters;
	}
}

class BlockStatement : Statement {
	Statement[] statements;

	this(Statement[] statements) {
		this.statements = statements;
	}
}

class DeclarationStatement : Statement {
	Declaration declaration;

	this(Declaration declaration) {
		this.declaration = declaration;
	}
}

class ExpressionStatement : Statement {
	Expression expression;
	
	this(Expression expression) {
		this.expression = expression;
	}
}

class ReturnStatement : Statement {
	Expression expression;
	
	this(Expression expression) {
		this.expression = expression;
	}
}

class FunctionDefinition : FunctionDeclaration {
	BlockStatement function_body;

	this(FunctionDeclaration function_decl, BlockStatement function_body) {
		super(function_decl.return_type, function_decl.function_name, function_decl.parameters);
		this.function_body = function_body;
	}
}