module qcc.parser;

import qcc.token;
import qcc.ast;
import qcc.lexer;

import visitor;

struct Parser
{
	uint pos;
	Token[] tokens;

	Token pop () {
		return tokens[pos++];
	}

	Token peek (ubyte n=0) {
		return tokens[pos+n];
	}

	auto parse(Token[] tokens) {
		this.tokens=tokens;
		while (peek() != TokenType.EOF) with (TokenType) {

			if(peek().type == PP_INCLUDE) {
				pop();
				assert(pop().type == STRING_LITERAL);
				//TODO use #include not skip it
			}

			if(peek(0).type == IDENTIFIER && peek(1).type == IDENTIFIER && peek(2).type == PAREN_OPEN) {
				// most likely a function declaratopn
				// now we need todo lookahead and other stuff
			}

		}
	}

}