module metad.compiler;

private import pegged.grammar;
private import std.string;
private import std.typecons;

/++
 + A compile-time compiler (meta-compiler).
 +
 + To use: (see the unittest for a running example)
 +
 + Create your pegged grammar.
 +    enum _g = q{ GRAMMAR: ... };
 +    mixin (grammar(_g));
 +
 + Create a template for your compiler, and mixin the default signature.
 +   struct myCompiler(ParseTree T) {
 +      mixin Compiler!(T,myCompiler);
 +      // ....
 +   }
 +
 + The "Compiler" mixin binds the "compileNode" function to a nested scope. We can override the compileNode function 
 + for specific matches in the parse tree. To do this, we use string mixins, that bind to
 + the local scope.  The template "nodeOverride" takes a condition and a function, and creates a local override
 + that binds the function to "compileNode" if the static condition matches against a tree node.  The "compilerOverride" template
 + binds to a node name.
 + This goes inside the parser template definition, and in this case we're overriding the behaviour
 + for a nodes matching a rule named "GRAMMAR.Text".  The override template accepts a second string argument
 + representing the code to be mixed in when the name matches. The code should return a string that will be output
 + from the compiler, to be mixed in to the users program.  In this example, we concantenate the "matches" property.
 + "T" refers to the current node.
 +      // ...
 +      mixin (compilerOverride!("GRAMMAR.Text","T.matches.join(\"\")"));
 +      // ...
 +
 + Then, we invoke the compiler.
 +    enum _d = q{ ... the input to your parser ... };
 +    mixin Compiler!(myParser,GRAMMAR(_d));
 +
 + Or we can just pull out the text and not mix it in to our program right away
 +    enum code = myParser!(GRAMMAR(_d)).compileNode();
 + 
 +/
 
template Compiler(ParseTree T,alias Parser) {

    static string[] compileChildNodes() {
        string[] result;
        static foreach(x;T.children) {
            result~=Parser!(x).compileNode;
        }
        return result;
    }

    static string compileNode() {
        return compileChildNodes().join("");
    }

    template nodeOverride(string Cond,string Func) {
        enum nodeOverride = q{
            static if(__C__) {
                static string compileNode() {
                    return __F__;
                }
            }
        }.replace("__C__",Cond).replace("__F__",Func);
    }

    template compilerOverride(string N,string F) {
        enum compilerOverride = nodeOverride!("T.name == \""~N~"\"",F);
    }

    template compile(alias Parser) {
        mixin(Parser.compileNode);
    }

    //template compileAlias(alias Parser) {
    //    enum compileAlias = mixin(Parser.compileNode);
    //}
}

template Compiler(alias Parser,alias data) {
    alias _compiler = Parser!(data);
    mixin _compiler.compile!(_compiler);
}

//struct MatchesTuple(string M) {
//    alias matches = M;
//}
//
//alias x = MatchesTuple!("X");
//alias y = Tuple!(MatchesTuple!("X"),"m");

template TupleCompiler(ParseTree T,alias Parser) {
    mixin Compiler!(T,Parser);

    static string[] compileChildValues() {
        string[] result;
        static foreach(x;T.children) {
            result ~= "\"" ~ x.name ~ "\"";
            //result ~= "[\"" ~ x.matches.map!(s=>s.replace("\"","\\\"")).join("\",\"") ~ "\"]";
            result ~= "[]";
        }
        return result;
    }
    static string[] compileChildTypes() {
        string[] result;
        //string value = "";
        static foreach(x;T.children) {
            //value = "";
            //value ~= "Tuple!(" ~ Parser!(x).compileNode ~ ",";
            //static if (x.name.indexOf(".")!=-1)
            //    value ~= '"' ~ x.name[x.name.indexOf(".")+1..$] ~ '"';
            //else value ~= '"' ~ x.name ~ '"';
            //value ~= ',';
            //value ~= "MatchesTuple!(\"" ~ (x.matches.join("").replace("\"","\\\"")) ~ "\")";
            ////value ~= "Tuple!(\"" ~ (x.matches.join("").replace("\"","\\\"")) ~ "\")";
            //value ~= ",\"matches\"";
            //value ~= ")";
            result ~= "string";
            result ~= "\"name\"";
            result ~= "string[]";
            result ~= "\"matches\"";
            //result ~= value;
        }
        return result;
        //return value;
    }

    static string compileNode() {
        return "Tuple!("~compileChildTypes().join(",")~")("~compileChildValues().join(",")~")";
    }

}

template TupleCompiler(alias Parser,alias data) {
    alias _compiler = Parser!(data);
    //enum TupleCompiler = _compiler.compileAlias!(_compiler);
    pragma(msg,"Tuples: \n"~_compiler.compileNode);
    mixin("auto TupleCompiler = " ~ _compiler.compileNode ~ ";");
}

template LoadGrammar(string fname,string docRoot) {
    mixin(grammar(import(fname)));
    enum parser = mixin(docRoot);
}

template loadGrammarAndData(string grammarFile,string docRoot,string dataFile) {
    mixin loadGrammar!(grammmarFile,docRoot);
    enum loadGrammarAndData = parser(import(dataFile));
}

template loadAndCompile(string grammarFile,string docRoot,string dataFile,alias _Compiler) {
    enum _data = loadGrammarAndData(grammarFile,docRoot,dataFile);
    mixin Compiler!(_Compiler,_data);
}

unittest {
    import std.array;
    import std.typecons;
    import std.string;
    import std.algorithm;
    
    import pegged.grammar;

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
    
    enum __M = "MyStruct";
    enum __T = "MyType";    

    enum _d = q{
        struct {{__T}} {
            enum v = "v";
            struct {{__M}} {
            };
            static {{__M}} m;
        };
    };
    
    struct myCompiler(ParseTree T,alias Parser=myCompiler) {
        mixin Compiler!(T,Parser);
        //mixin (compilerDocNode!("compileChildNodes().join(\"\")"));
        mixin (compilerOverride!("GRAMMAR.Text","T.matches.join(\"\")"));
        mixin (compilerOverride!("identifier","mixin(T.matches.join(\"\"))"));
    }

    pragma(msg,"Compiling:\n"~_d);
    pragma(msg,"Tree:\n" ~ GRAMMAR!identifier(_d).toString);

    enum compiled = myCompiler!(GRAMMAR!identifier(_d)).compileNode();
    pragma(msg,"Compiled to:\n" ~ compiled);
    //mixin(compiled);
    
    mixin Compiler!(myCompiler,GRAMMAR!identifier(_d));
    static assert(mixin("MyType.v") == "v");
}

unittest {
        
    import pegged.grammar;

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
    
    enum __M = "MyStruct";
    enum __T = "MyType";    

    enum _d = q{
        struct {{__T}} {
            enum v = "v";
            struct {{__M}} {
            };
            static {{__M}} m;
        };
    };
    
    struct myTupleCompiler(ParseTree T,alias Parser=myTupleCompiler) {
        mixin TupleCompiler!(T,Parser);
        //mixin (compilerOverride!("GRAMMAR","compileChildNodes().join(\"\")"));
        //mixin (compilerOverride!("identifier","\" ~ T.matches.join(\"\") ~ \",\"identifier\")"));
    }
    alias compiledTuple = TupleCompiler!(myTupleCompiler,GRAMMAR!identifier(_d));
    //static assert(mixin("MyType.v") == "v");
}


