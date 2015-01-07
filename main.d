module qcc.driver;

import qcc.lexer;
import qcc.parsetree;
import qcc.parser;
import std.stdio;

void main(string[] args)
{
	writeln("Welcome to the QCC Compiler");

	immutable string test_source = `
#include "stdio.h"

struct s {
	int x;
	int *y;
	struct s2 {
		int x2;
		int y2;
	} ;
} ;

int main() {
	int a;
	bool bl;
	a = (4+4)*8+a - add2(7);
	int b;
	b = 12 + a + b;
	int c;
	c = (2 == 5);
	printf("Hello World"); 
	if (a==a) {
		return a;
	} else 

	return 1234;
}

int b;


	`;

	string test_parser = `
Node {
	Group {
		Identifier name, "{", PatternElement[] elements : "," 
		/ Group[] groups, "}"
	}	

	PatternElement {

		ConstantElement {
			charRange {
				char rangeBegin, "-", char RangeEnd
			}

			RangeElement {
				"[", charRange[] ranges : ",", "]"
			}

			LookbehindElement {
				"!lb", "(", string str_elm, ")"
			}

		}

		NamedElement {
			Identifier type, Identifier name
		}
		
		ArrayElement {
			Identifier type, "[]", Identifier name,
			? ":" : string lst_sep
		}

		ParenElement {
			"(", PatternElement[] elements : ",", ")" 
		}
		
		OptionalElement {
			"?", ConstantElement ce, ":", PatternElement elem
		}
		
	}
}`;

	import std.file;
//	auto source = (args.length>1) ? cast(immutable(char[])) read(args[1]) : test_source;
//	writeln(source);
//	writeln("Tokenized Output : ");
//	auto lexer = Lexer();
//	auto tokens = lexer.lex(source);
//	//foreach(token;tokens) {
//	//	writeln(token);
//	//}
//	writeln(lexer.intrmap);
//	auto cu = Parser().parseCompilationUnit(tokens);
//	foreach(decl;cu.declarations) { 
//		writeln (decl); 
//	}
//	foreach(stmt;(cast(FunctionDefinition)(cu.declarations[1])).function_body.statements) {
//		writeln(stmt);
//	}

	import pgen_parser:lex;
	import pgen_parser:parse;
	import pgen_parser:PTreeVisitor;

	auto pres = parse(lex(test_parser));
	writeln(PTreeVisitor().visit(pres.groups));

//	foreach (group;pres.groups) {
//		writeln(group.name.identifier);
//		writeln(group.elements);
//	}
	// Lets the user press <Return> before program returns
	stdin.readln();
}

