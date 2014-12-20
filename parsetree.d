module qcc.parsetree;
import qcc.token;

abstract class Node {}

abstract class Expression : Node {}

abstract class Statement : Node {}

abstract class Declaration : Node {}

abstract class Annotation : Node {}

class VaraibleDeclaration : Declaration {
	Token type;
	Token name;
}

class FunctionDeclaration : Declaration {
	Token return_type;
	Token function_name;
	VaraibleDeclaration[] parameters;
}

class Block : Statement {
	Statement[] statements;
}

class FunctionDefinition : Statement {
	FunctionDeclaration function_decl;
	Block function_body;
	
}