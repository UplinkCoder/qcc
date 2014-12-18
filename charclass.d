module qcc.charclass;

bool isAlphaNumeric(char c) {
	return (isAlpha(c) || isNumeric(c));
}

bool isNumeric (char c) {
	return (c >= '0' && c <= '9');
}

/// checks weather given char is in the [a-zA-Z] range
bool isAlpha (char c) {
	return (isLowerAlpha(c) || isUpperAlpha(c)); 
}

bool isLowerAlpha(char c) {
	return (c >= 'a' && c <= 'z');
}


bool isUpperAlpha(char c) {
	return (c >= 'A' && c <= 'Z'); 
}


unittest {
	assert(isLowerAlpha('l'));
	assert(isLowerAlpha('z'));
	assert(isLowerAlpha('a'));
	assert(!isLowerAlpha('9'));
	assert(!isLowerAlpha('A'));
	assert(!isLowerAlpha('!'));

}