module visitor;

U fastCast(U, T)(T t) if(is(T == class) && is(U == class) && is(U : T)) in {
	assert(cast(U) t);
} body {
	return *(cast(U*) &t);
}


auto dispatch(
	alias unhandled = function void(t) {
	throw new Exception(typeid(t).toString() ~ " is not supported.");
	// XXX: Buggy for some reason.
	// throw new Exception(typeid(t).toString() ~ " is not supported by visitor " ~ typeid(V).toString() ~ " .");
}, V, T, Args...
)(ref V visitor, Args args, T t) if(is(V == struct) && (is(T == class) || is(T == interface))) {
	return dispatchImpl!(unhandled)(visitor, args, t);
}

auto dispatch(
	alias unhandled = function void(t) {
	throw new Exception(typeid(t).toString() ~ " is not supported.");
	// XXX: Buggy for some reason.
	// throw new Exception(typeid(t).toString() ~ " is not supported by visitor " ~ typeid(V).toString() ~ " .");
}, V, T, Args...
)(V visitor, Args args, T t) if((is(V == class) || is(V == interface)) && (is(T == class) || is(T == interface))) {
	return dispatchImpl!(unhandled)(visitor, args, t);
}

// XXX: is @trusted if visitor.visit is @safe .
private auto dispatchImpl(
	alias unhandled, V, T, Args...
	)(auto ref V visitor, Args args, T t) in {
	assert(t, "You can't dispatch null");
} body {
	static if(is(T == class)) {
		alias o = t;
	} else {
		auto o = cast(Object) t;
	}
	
	auto tid = typeid(o);
	
	import std.traits;
	static if(is(V == struct)) {
		import std.typetuple;
		alias Members = TypeTuple!(__traits(getOverloads, V, "visit"));
	} else {
		alias Members = MemberFunctionsTuple!(V, "visit");
	}
	
	foreach(visit; Members) {
		alias parameters = ParameterTypeTuple!visit;
		
		static if(parameters.length == args.length + 1) {
			alias parameter = parameters[args.length];
			
			// FIXME: ensure call is correctly done when args exists.
			static if(is(parameter == class) && !__traits(isAbstractClass, parameter) && is(parameter : T)) {
				if(tid is typeid(parameter)) {
					return visitor.visit(args, () @trusted {
						// Fast cast can be trusted in this case, we already did the check.
						return fastCast!parameter(o);
					} ());
				}
			}
		}
	}
	
	// Dispatch isn't possible.
	enum returnVoid = is(typeof(return) == void);
	static if(returnVoid || is(typeof(unhandled(t)) == void)) {
		unhandled(t);
		assert(returnVoid);
	} else {
		return unhandled(t);
	}
}
