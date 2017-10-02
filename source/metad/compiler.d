module metad.compiler;

private import pegged.grammar;

/++
 + A compile-time compiler (meta-compiler).
 +
 + To use: (see the unittest for a running example)
 +
 + Create your pegged grammar.
 +    enum _g = q{ ... };
 +    mixin (grammar(_g));
 +
 + Create a template for your parser, and mixin the default compiler.
 +   template myParser(ParseTree T,alias Parser=myParser) {
 +      mixin Compiler!(T,Parser);
 +      // ....
 +   }
 +
 + The "Compiler" mixin binds the "compileNode" function to a nested scope. We can override the compileNode function 
 + for specific matches in the parse tree. To do this, we use string mixins, that bind to
 + the local scope.  The template "nodeOverride" takes a condition and a function, and creates a local override
 + that binds the function to "compileNode" if the static condition matches against a tree node.  The "compilerOverride" template
 + binds to a node name, and the "compilerDocNode" template binds to the condition of the name having no "." character, meaning that it is
 + the root node.
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
 + Or we can just pull out the code and not mix it in to our program right away
 +    enum code = myParser!(GRAMMAR(_d)).compileNode();
 + 
 +/
 
template Compiler(ParseTree T,alias Parser) {

    static string[] compileChildNodes() {
        string[] result;
        static foreach(x;T.children) result~=Parser!(x).compileNode;
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

    template compilerDocNode(string F) {
        enum compilerDocNode = nodeOverride!("T.name.indexOf('.')==-1",F);
    }
    
    template compile(alias Parser) {
        mixin(Parser.compileNode);
    }

}

template Compiler(alias Parser,alias data) {
    alias _compiler = Parser!(data);
    mixin _compiler.compile!(_compiler);
}

unittest {
    import std.array;
    import std.typecons;
    import std.string;
    import std.algorithm;
    
    import pegged.grammar;

    enum _g = q{
GRAMMAR:
    Doc <- Line+ :endOfInput
    Line <- (Var / Text)
    Var <- :LDelim ^Template :RDelim
    LDelim <- "{{"
    RDelim <- "}}"
    Text <- ~((!LDelim) Char )*
    Template <- ~((!RDelim) Char )*
    Char <- .
    };
    mixin(grammar(_g));
    
    template myParser(ParseTree T,alias Parser=myParser) {
        mixin Compiler!(T,Parser);
        mixin (compilerDocNode!("compileChildNodes().join(\"\")"));
        mixin (compilerOverride!("GRAMMAR.Text","T.matches.join(\"\")"));
        mixin (compilerOverride!("GRAMMAR.Template","mixin(T.matches.join(\"\"))"));
    }

    enum __M = "MyStruct";
    enum __T = "MyType";    
    enum _d = q{
        struct {{__T}} {
            enum v = "v";
        }
        struct {{__M}} {
            {{__T}} t;
        };
        {{__M}} m;
    };
    pragma(msg,"Compiling:\n"~_d);

    enum compiled = myParser!(GRAMMAR(_d)).compileNode();
    pragma(msg,"Compiled to:\n" ~ compiled);
    //mixin(compiled);
    
    mixin Compiler!(myParser,GRAMMAR(_d));
    static assert(mixin("m.t.v") == "v");

}


