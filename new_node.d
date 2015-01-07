module qcc.new_node;
import qcc.parsetree;

struct New_Node {

	enum NodeType {
		Declaration,
		Statement,
		Expression,
	}

	union subtype {
		DeclarationType dtype;
		StatementType stype;
		ExpressionType etype;
	}

	enum StatementType {
		AssignmentStatement,
		BlockStatement,

		DeclarationStatement,
		ExpressionStatement,

		IfStatement,
		ReturnStatement,
	}

	enum ExpressionType {
		IdentifierExpression,
		BinaryExpression,
		CallExpression,
		ParenExpression,

		ConstantExpression,
		IntegerLiteral,
		StringLiteral,

	}

	enum DeclarationType {
		VariableDeclaration,
		StructDeclaration,
		FunctionDeclaration,

		FunctionDefinition,
	}


}

