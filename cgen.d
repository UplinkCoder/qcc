module qcc.cgen;

import qcc.parsetree;
import visitor;

struct CGenVisitor {

//	string visit(Identifier i) {
//
//	}
//
//	string visit(Type t) {
//
//	}

	string visit(Node n) {
		return this.dispatch(n);
	}

	string visit (CompilationUnit cu) {
		string result;
		foreach(decl;cu.declarations) {
			result ~= visit(decl);
		}
		return result;
	}

	string visit (VariableDeclaration vd) {
		return "";
		//	return getString(vd.type) ~ " " ~ getString(vd.name);
	}

	string visit (DeclarationStatement ds) {
		return visit(ds.declaration) ~ ";\n";
	}

	string visit (ExpressionStatement es) {
		return visit(es.expression) ~ ";\n";
	}

	string visit (FunctionDeclaration fd) {
		string result;
		result ~= (fd.return_type).toString() ~ " " ~ (fd.function_name).toString() ~ "(";

		foreach (param;fd.parameters) {
			result ~= visit(param);
		}

		result ~= ")";
		return result;
	}

	string visit(FunctionDefinition fd) {
		return visit(cast(FunctionDeclaration) fd) ~ visit(fd.function_body);
	}

	string visit(BlockStatement bs) {
		string result = "{\n";

		foreach (stmt;bs.statements) {
			result ~= visit(stmt);
		}

		return result  ~ "}\n";

	}

}