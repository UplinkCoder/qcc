module qcc.lexer;

import qcc.source;
import qcc.token;

struct Lexer {
	Source current_source;
	Source[] source_queue;

	auto spawnLexer(Source src, Location offset) {

	}

	this(Source[] srcs) {

	}
}