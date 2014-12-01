module qcc.token;

import qcc.source;

struct Token {
	Location loc;

	enum TokenId {
		bmlc, /// "/*"
		emlc, /// "*/"
		lc, /// "//"
	}
	
	TokenId id;
	
	bool opEquals(TokenId that) {
		return id == that;
	}
	
	
}