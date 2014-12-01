module qcc.driver;

import std.stdio;

void main(string[] args)
{
	// Prints "Hello World" string in console
	writeln("Welcome to the QCC Compiler");

	// First we need a Lexer
	// A lexer will process the source code into little chunks the parser can understand.
	// These chuncks are called Tokens.
	// That is why a lexer is often called a tokenizer :)

	//There are already lists with keywords and other reserved identifiers that a lexer can output as special tokens
	//We will take a list we can find in the sourcecode of http://sourceforge.net/projects/lexerproject/

	// Let's start with comments
	// We will ignore anything BUT comments


	// Lets the user press <Return> before program returns
	stdin.readln();
}

