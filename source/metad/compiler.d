module metad.compiler;

private import pegged.grammar;

private import std.string;
private import std.typecons;
private import std.algorithm;

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
 + "T" is an alias to the current node.
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
 + The compilerOverride template takes two strings:
 + a string matching the name of the node to override,
 + and a string representing the code to mixin in order to parse
 + that particular node type.
 +/

 template loadGrammar(string fname,string docRoot) {
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
                    __F__;
                }
            }
        }.replace("__C__",Cond).replace("__F__",Func);
    }

    template compilerOverride(string N,string F) {
        enum compilerOverride = nodeOverride!(
            "T.name == \""~N~"\"",
            "return " ~ F);
    }

    template compile(alias Parser) {
        mixin(Parser.compileNode);
    }
}

template Compiler(alias Parser,ParseTree data) {
    alias _compiler = Parser!(data);
    mixin _compiler.compile!(_compiler);
}

unittest {
    import std.array;
    import std.typecons;
    import std.string;
    import std.algorithm;

    import pegged.grammar;

    // A grammar that expands {{Template}} into 
    // statements.
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

    // Create a compiler from the parse tree.
    struct myCompiler(ParseTree T,alias Parser=myCompiler) {
        mixin Compiler!(T,Parser);
        // Override two node types: GRAMMAR.Text and identifier.
        // GRAMMAR.Text is just the matches array values concantenated.
        mixin (compilerOverride!("GRAMMAR.Text","T.matches.join"));
        // identifier returns a mixin of the matches value.
        mixin (compilerOverride!("identifier","mixin(T.matches.join)"));
    }

    pragma(msg,"Compiling:\n"~_d);
    pragma(msg,"Tree:\n" ~ GRAMMAR!identifier(_d).toString);

    enum compiled = myCompiler!(GRAMMAR!identifier(_d)).compileNode();
    pragma(msg,"Compiled to:\n" ~ compiled);
    mixin(compiled);

    static assert(mixin("MyType.v") == 'v');
}

/**
The TupleCompiler converts you input to a tuple at compile-time.
The default node parser simply adds the "matches" as an unnamed string[].

The parser works in two phases, and generates code of the
form "Tuple!(types...)(values...)". This can be assigned
to an enum.

As in the ordinary compiler, the parser/generator methods
should be overridden to parse nodes from your grammar.

There are two overrides per-node in the tuple generator -
the type, and the value.  The compileType returns a
string; either single type, or a string of the
form 'type,"name"', which would add the type as a
named field in the tuple.

The compileValue method returns a string - the
code to mixin when the value is computed.

This version of the compilerOverride template takes three
string parameters:

the name of the node type, the code to mixin to generate the
"type" portion of the Tuple! created to represent that node,
and a code string to mixin to generate the "value" part of
the tuple (ie the argument to the tuple constructor).
**/
template TupleCompiler(ParseTree T,alias Parser) {
    mixin Compiler!(T,Parser);

    static string[] compileChildValues() {
        string[] result;
        static foreach(x;T.children) {
            debug {
              pragma(msg,"value: \n"~Parser!(x).compileValue);
            }
            result ~= Parser!(x).compileValue;
        }
        return result;
    }
    static string[] compileChildTypes() {
        string[] result;
        static foreach(x;T.children) {
            debug {
              pragma(msg,"type: \n"~x.name);
            }
            result ~= Parser!(x).compileType;
            // we can't use the node names as field names
            // because they could be non-unique.
            /*static if (x.name.indexOf(".")!=-1) {
                result ~= '"' ~ x.name[x.name.indexOf(".")+1..$] ~ '"';
            } else {
              result ~= '"' ~ x.name ~ '"';
            }*/
        }
        return result;
    }

    template tupleTypes() {
      enum tupleTypes =
        "Tuple!("~compileChildTypes().join(",")~")";
    }

    template tupleValues() {
      enum tupleValues =
        "("~compileChildValues().join(",")~")";
      }

    static string compileNode() {
        return tupleTypes!() ~ tupleValues!();
        //return "Tuple!("~compileChildTypes().join(",")~")("~compileChildValues().join(",")~")";
    }
    static string compileType() {
        return "string[]";
    }
    static string compileValue() {
      debug {
        pragma(msg,"compileValue: \n"~T.name);
        pragma(msg,T.matches.map!(T=>"<"~T~">").join(","));
      }
      enum v = T.matches.map!(x=>"\""~x~"\"").join(",");
      return "[" ~ v ~ "]";
    }
    template nodeOverride(string Cond,string TypeFunc,string ValueFunc) {
        enum nodeOverride = q{
            static if(__C__) {
                static string compileType() {
                    return __F__;
                }
                static string compileValue() {
                    return __G__;
                }
            }
        }.replace("__C__",Cond).replace("__F__",TypeFunc).replace("__G__",ValueFunc);
    }

    template compilerOverride(string Name,string TypeF,string ValueF) {
        enum compilerOverride = nodeOverride!("T.name == \""~Name~"\"",TypeF,ValueF);
    }
}

template TupleCompiler(alias Parser,alias data) {
    alias _compiler = Parser!(data);
    //enum TupleCompiler = _compiler.compileAlias!(_compiler);
    debug {
      pragma(msg,"Tuples: \n"~_compiler.compileNode);
    }
    mixin("enum TupleCompiler = " ~ _compiler.compileNode ~ ";");
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
    //enum __T = "\"MyType\""; // quotes causes error.
    enum __T = "MyType";

    enum _d = q{
        struct {{__T}} {
            enum v = 'v';
            struct {{__M}} {
            };
            static {{__M}} m;
        };
    };

    struct myTupleCompiler(ParseTree T,alias Parser=myTupleCompiler) {
        mixin TupleCompiler!(T,Parser);
        //mixin (compilerOverride!("GRAMMAR","compileChildNodes().join(\"\")"));

        /* mixin (compilerOverride!(
          "identifier",
          "\" ~ T.matches.join(\"\") ~ \",\"identifier\")")
          ); */
        /*mixin (compilerOverride!(
          "GRAMMAR.Doc",
          "Tuple!("
            ~ "compileChildTypes.join(\",\")"
            ~ ")",
          "Tuple!("
            ~ "compileChildTypes.join(\",\")"
            ~ ")("
            ~ "compileChildValues.join(\",\")"
            ~")"
           )
        );
        mixin (compilerOverride!(
          "GRAMMAR.Line",
          "Tuple!("
            ~ "compileChildTypes.join(\",\")"
            ~ ")",
          "Tuple!("
            ~ "compileChildTypes.join(\",\")"
            ~ ")("
            ~ "compileChildValues.join(\",\")"
            ~")"
           )
        );*/
        /*mixin (compilerOverride!(
          "GRAMMAR.Var",
          "compileChildTypes.join(\",\")",
          "compileChildValues.join(\",\")"
        ));*/
        mixin (compilerOverride!(
          "GRAMMAR.Var",
          "tupleTypes!()",
          //"tupleTypes!()(tupleValues!())"
          //"tuple(tupleValues!())"
          "compileNode"
        ));
        mixin (compilerOverride!(
          "GRAMMAR.Text",
          "\"string\"",
          " '\"' ~ T.matches.join ~ '\"'"
        ));
        static foreach(i;["GRAMMAR.Line","GRAMMAR.Doc"]) {
          mixin (compilerOverride!(
            i,
            "compileChildTypes.join(\",\")",
            "compileChildValues.join(\",\")"
          ));

        }
        /* mixin (compilerOverride!(
          "GRAMMAR.Line",
          "compileChildTypes.join(\",\")",
          "compileChildValues.join(\",\")"
        ));
        mixin (compilerOverride!(
          "GRAMMAR.Doc",
          "compileChildTypes.join(\",\")",
          "compileChildValues.join(\",\")"
        )); */
        // the "identifier" token is replaced by
        // a mixin of it's value.
        mixin (compilerOverride!(
          "identifier",
          "\"string,\" ~ '\"' ~ T.matches[0] ~ '\"'",
          "'\"' ~ mixin(T.matches[0]) ~ '\"'"
        ));
    }
    enum compiledTuple = TupleCompiler!(myTupleCompiler,GRAMMAR!identifier(_d));
    //mixin compiledTuple;
    //static assert(mixin("MyType.v") == "v");
    pragma(msg,"Tuple Compiler:");
    pragma(msg,typeof(compiledTuple));
    pragma(msg,compiledTuple);
}
