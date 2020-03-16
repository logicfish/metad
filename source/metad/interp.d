module metad.interp;

private import pegged.grammar;

private import std.variant;
private import std.typecons;
private import std.algorithm;

private import metad.compiler;

/++
+ The run-time verstion of the meta-compiler (meta-compiler).
+/

template loadGrammarAndData(string grammarFile,string docRoot) {
    mixin loadGrammar!(grammmarFile,docRoot);
    auto loadGrammarAndData(string dataString) {
        return parser(dataString);
    }
}

template loadAndInterpret(string grammarFile,string docRoot,alias _Interpreter) {
	auto loadAndInterpret(string data) {
		auto _data = loadGrammarAndData(grammarFile,docRoot)(data);
		return Interpreter!(_Interpreter)(_data);
	}
}

template Interpreter(N) {
	static Variant[] interpChildNodes(N nodes,ParseTree t) {
		Variant[] result;
		foreach(x;t.children) {
			result~=Interpreter!N(nodes,x);
		}
		return result;
	}
    //return Parser(data.name)(data);
	Variant[] Interpreter(N nodes,ParseTree data) {
		import std.stdio;
		writeln("Interpreter " ~ data.name);
		if(data.name in nodes) {
			return [nodes[data.name](data)];
		}
		//return interpChildNodes(nodes,data).join("");
		return interpChildNodes(nodes,data);
	}
}

unittest {
    import std.array;
    import std.typecons;
    import std.string;
    import std.algorithm;
    import std.stdio;

    import pegged.grammar;

    // A grammar that parses {{Template}}
    // statements in a body of text.
    enum _g = q{
		GRAMMAR(Template):
		Doc <- Line+ :endOfInput
			Line <- (Var / Text)
			Var <- :LDelim ^Template :RDelim
			LDelim <- "{{"
			RDelim <- "}}"
			Text <- ~((!LDelim) Char )*
			Char <- .
    };
    mixin(grammar(_g));

    // Replace these identifiers in the input
    enum __M = "MyStruct";
    enum __T = "MyType";

    // some input data.
    enum _d = q{
        struct {{__T}} {
            enum v = 'v';
            struct {{__M}} {
            };
            static {{__M}} m;
        };
    };
    static string idParser(string s) {
		writeln("idParser" ~ s);
		if(s=="__T") {
			return __T;
		} else if (s=="__M") {
			return __M;
		}
		return s;
    }
    // Create a compiler from the parse tree.
    auto myInterpreter(ParseTree t) {
		Variant delegate(ParseTree)[string] nodes;
		//nodes["GRAMMAR.Var"] = f=>idParser(f.children[1].matches);
		nodes["GRAMMAR.LDelim"] = f=>Variant();
		nodes["GRAMMAR.RDelim"] = f=>Variant();
		nodes["GRAMMAR.Text"] = f=>Variant(f.matches.join(""));
		nodes["identifier"] = (f)=>Variant(idParser(f.matches.join("")));

		return Interpreter(nodes,t);
    }
    auto interp = myInterpreter(GRAMMAR!identifier(_d));
	
	import std.conv;
	auto interpString = interp.map!(x=>x.to!string).join("");
    writeln(" INTERP: " ~ interpString );
    
	auto expected = _d.replace("{{__T}}",__T).replace("{{__M}}",__M);
    assert(interpString == expected,"Expected: "~expected ~ "\nGot: "~interpString);
}
