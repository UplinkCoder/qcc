module qcc.parser;

import qcc.token;
import qcc.parsetree;
import qcc.lexer;

import visitor;

struct Parser {

	bool isOperator(TokenType t) {
		return (t == TokenType.PLUS || t == TokenType.MINUS 
		        || t == TokenType.STAR || t == TokenType.SLASH);
	}

	uint pos;
	Token[] tokens;

	Token pop() {
		return tokens[pos++];
	}

	Token peek(ubyte n=0) {
		return tokens[pos+n];
	}

	Token match(TokenType type) {
		import std.conv:to;
		assert(peek().type == type,"Expected: "~ to!string(type) ~ " Got: " ~ to!string(peek.type));
		return pop();
	}

	AssignmentStatement parseAssignmentStatement() {
		assert(peek(0).type == TokenType.IDENTIFIER &&
		       peek(1).type == TokenType.EQUALS &&
		       peek(2).type != TokenType.EQUALS);

		auto identifier_token = match(TokenType.IDENTIFIER);

		match(TokenType.EQUALS);
		auto expr = parseExpression();
		match(TokenType.SEMICOLON);

		return new AssignmentStatement(identifier_token, expr);
	}

	Declaration parseDeclaration() {
		with (TokenType) {
			if(peek(0).type == STRUCT && peek(1).type == IDENTIFIER && peek(2).type == CURLY_BRACE_OPEN) {
				return parseStructDeclaration();
			} else if(peek(0).type == IDENTIFIER && peek(1).type == IDENTIFIER && peek(2).type == PAREN_OPEN) {
				return parseFunctionDeclaration();
			} else if (peek(0).type == IDENTIFIER && peek(1).type == IDENTIFIER && peek(2).type == SEMICOLON) {
				return parseVaraibleDeclaration();
			}
			assert(0);
		}
	}

	CompilationUnit parseCompilationUnit(Token[] tokens) {
		Declaration[] declarations;

		this.tokens=tokens;
		while (peek() != TokenType.EOF) with (TokenType) {

			if(peek().type == PP_INCLUDE) {
				//TODO use #include not skip it
				match(PP_INCLUDE);
				match(STRING_LITERAL);
			}

			declarations ~= parseDeclaration();
		}

		match(TokenType.EOF);

		return new CompilationUnit(declarations);
	
	}

	StructDeclaration parseStructDeclaration() {
		Declaration[] members;
		match(TokenType.STRUCT);
		auto id = match(TokenType.IDENTIFIER);
		match(TokenType.CURLY_BRACE_OPEN);

		while (peek.type != TokenType.CURLY_BRACE_CLOSE) {
			members ~= parseDeclaration();
		}
		match(TokenType.CURLY_BRACE_CLOSE);
		match(TokenType.SEMICOLON);
		return new StructDeclaration(members);
	}

	VariableDeclaration parseVaraibleDeclaration() {
		with (TokenType) {
			assert(peek(0).type == IDENTIFIER && 
		    	   peek(1).type == IDENTIFIER &&
		    	   peek(2).type == SEMICOLON);
			auto decl = new VariableDeclaration(match(IDENTIFIER), match(IDENTIFIER));
			match(SEMICOLON);
			return decl;
		}
	}

	FunctionDeclaration parseFunctionDeclaration() {
		bool isDecl;
		VariableDeclaration[] params;
		with (TokenType) {
			Token return_type = match(IDENTIFIER);
			Token function_name = match(IDENTIFIER);
			match(PAREN_OPEN);
			
			//TODO refactor this maybe ?
			while(peek().type != PAREN_CLOSE) {
				if (peek(1) == COMMA) {
					isDecl = true;
					assert(peek == IDENTIFIER);
					params ~= new VariableDeclaration(match(IDENTIFIER), Token.init);
				} else {
					assert(peek(1) == IDENTIFIER);
					params ~= new VariableDeclaration(match(IDENTIFIER), match(IDENTIFIER));
				}
				
				match(COMMA);
			}

			match(PAREN_CLOSE);
		
			if (!isDecl && peek() == CURLY_BRACE_OPEN) {
				// Not just a function declaration but a function definition
				auto function_decl = new FunctionDeclaration(return_type, function_name, params);
				auto function_body = parseBlockStatement();
				return new FunctionDefinition(function_decl, function_body);
			} else {
				match(SEMICOLON);
				return new FunctionDeclaration(return_type, function_name, params);
			}
		}
	}

	ParenExpression parseParenExpression () {
		match(TokenType.PAREN_OPEN);
		auto expr = parseExpression();
		match(TokenType.PAREN_CLOSE);

		return new ParenExpression(expr);
	}
	
	Expression parseExpression() {
		Expression expr;
		switch (peek().type) with (TokenType) {
			case IDENTIFIER : 
				expr = new IdentifierExpression(match(IDENTIFIER));
				break;
			case PAREN_OPEN :
				expr = parseParenExpression();
				break;
			case INTEGER_LITERAL :
				expr = new IntegerLiteral(match(INTEGER_LITERAL));
				break;
			case STRING_LITERAL :
				expr = new StringLiteral(match(STRING_LITERAL));
				break;
			default : assert(0, "cannot parse expressoin");
		}

		if (isOperator(peek.type)) {
			return new BinaryExpression(pop(), expr, parseExpression());
		} else {
			return expr;
		}
	}

	CallExpression parseCallExpression() {
		Expression[] parameters;
		Token callee;

		callee = match(TokenType.IDENTIFIER);
		match(TokenType.PAREN_OPEN);

		while (peek(0).type != TokenType.PAREN_CLOSE) {
			parameters ~= parseExpression();
		}
		match(TokenType.PAREN_CLOSE);

		return new CallExpression(callee, parameters);
	}

	Statement parseStatement() {
		std.stdio.writeln(peek(0),peek(1),peek(2));
		if (peek(0).type == TokenType.IDENTIFIER &&
		    peek(1).type == TokenType.EQUALS &&
		    peek(2).type != TokenType.EQUALS) {
			return parseAssignmentStatement();
		} else if (peek(0).type == TokenType.IDENTIFIER &&
		           peek(1).type == TokenType.IDENTIFIER &&
		           peek(2).type == TokenType.SEMICOLON) {
			return new DeclarationStatement(parseDeclaration());
		} else if (peek(0).type == TokenType.IDENTIFIER &&
		           peek(1).type == TokenType.PAREN_OPEN) {
			auto expr = parseCallExpression();
			match(TokenType.SEMICOLON);

			return new ExpressionStatement(expr);
		} else if (peek(0).type == TokenType.RETURN) {
			match(TokenType.RETURN);
			auto expr = parseExpression();
			match(TokenType.SEMICOLON);
			return new ReturnStatement(expr);
		}

		assert(0);

	}

	BlockStatement parseBlockStatement() {
		Statement[] stmts;
		//TODO associate scope with BlockStatement
		with (TokenType) {
			match(CURLY_BRACE_OPEN);

			while (peek() != CURLY_BRACE_CLOSE) {
				stmts ~= parseStatement();
			}

			match(CURLY_BRACE_CLOSE);

			return new BlockStatement(stmts);
		}
	}
	
}