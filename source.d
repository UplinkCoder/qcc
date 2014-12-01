module qcc.source;

struct SourceBuffer {
	Source* source;
	string content;
	alias content this;

	SourceBuffer[] splitSourceBuffer (uint parts) {
		immutable plen = content.length/parts;
		SourceBuffer[] buffers;
		buffers.length = parts;
		foreach (part;0 .. parts) {
			buffers[part].source = source;
			buffers[part].content = content[(part)*plen .. (part+1)*plen];
		}
		return buffers;
	}
}

unittest {
	SourceBuffer sb = SourceBuffer(null, "ABCD");
	auto bfrs4 = sb.splitSourceBuffer(4);
	auto bfrs2 = sb.splitSourceBuffer(2);
	assert(
		bfrs4[0]=="A" &&
		bfrs4[1] == "B" &&
		bfrs4[2] == "C" &&
		bfrs4[3] == "D"
	);
	assert(
		bfrs2[0]=="AB" &&
		bfrs2[1] == "CD" 
	);
}


struct Source {
	bool isPartial;
	string path = ".";
	string name;
	SourceBuffer content;
	uint length;


	this(in string name, in string content) {
		this.name = name;
		this.content.content = content;
	}

}

struct Location {
	Source source;
	uint line;
	uint col;
	uint length;
}