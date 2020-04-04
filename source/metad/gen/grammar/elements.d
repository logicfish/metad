/++
This module was automatically generated from the following grammar:

BasicElements : 
    String <~ doublequote (!doublequote Char)* doublequote
    Numeric <- Scientific / Floating / Integer / Hexa
    QualifiedIdentifier <- identifier ( :"." identifier)*

    Char   <~ backslash ( doublequote  # '\' Escapes
                        / quote
                        / backslash
                        / [bfnrt]
                        / [0-2][0-7][0-7]
                        / [0-7][0-7]?
                        / 'x' Hex Hex
                        / 'u' Hex Hex Hex Hex
                        / 'U' Hex Hex Hex Hex Hex Hex Hex Hex
                        )
             / . # Or any char, really
    Hex     <- [0-9a-fA-F]

    Scientific <~ Floating ( ('e' / 'E' ) Integer )?
    Floating   <~ Integer ('.' Unsigned )?
    Unsigned   <~ [0-9]+
    Integer    <~ Sign? Unsigned
    Hexa       <~ [0-9a-fA-F]+
    Sign       <- '-' / '+'
    Bool       <- "true" / "false"



+/
module metad.gen.grammar.elements;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

struct GenericBasicElements(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct BasicElements
    {
    enum name = "BasicElements";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this()
    {
        rules["String"] = toDelegate(&String);
        rules["Numeric"] = toDelegate(&Numeric);
        rules["QualifiedIdentifier"] = toDelegate(&QualifiedIdentifier);
        rules["Char"] = toDelegate(&Char);
        rules["Hex"] = toDelegate(&Hex);
        rules["Scientific"] = toDelegate(&Scientific);
        rules["Floating"] = toDelegate(&Floating);
        rules["Unsigned"] = toDelegate(&Unsigned);
        rules["Integer"] = toDelegate(&Integer);
        rules["Hexa"] = toDelegate(&Hexa);
        rules["Sign"] = toDelegate(&Sign);
        rules["Bool"] = toDelegate(&Bool);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(name,rule; dg.rules)
        {
            if (name != "Spacing")
                rules[name] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
		import std.algorithm : startsWith;
        return s.startsWith("BasicElements.");
    }
    mixin decimateTree;

    alias spacing Spacing;

    static TParseTree String(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "BasicElements.String")(p);
        }
        else
        {
            if (auto m = tuple(`String`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "BasicElements.String"), "String")(p);
                memo[tuple(`String`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree String(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "BasicElements.String")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "BasicElements.String"), "String")(TParseTree("", false,[], s));
        }
    }
    static string String(GetName g)
    {
        return "BasicElements.String";
    }

    static TParseTree Numeric(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Scientific, Floating, Integer, Hexa), "BasicElements.Numeric")(p);
        }
        else
        {
            if (auto m = tuple(`Numeric`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(Scientific, Floating, Integer, Hexa), "BasicElements.Numeric"), "Numeric")(p);
                memo[tuple(`Numeric`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Numeric(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Scientific, Floating, Integer, Hexa), "BasicElements.Numeric")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(Scientific, Floating, Integer, Hexa), "BasicElements.Numeric"), "Numeric")(TParseTree("", false,[], s));
        }
    }
    static string Numeric(GetName g)
    {
        return "BasicElements.Numeric";
    }

    static TParseTree QualifiedIdentifier(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "BasicElements.QualifiedIdentifier")(p);
        }
        else
        {
            if (auto m = tuple(`QualifiedIdentifier`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "BasicElements.QualifiedIdentifier"), "QualifiedIdentifier")(p);
                memo[tuple(`QualifiedIdentifier`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree QualifiedIdentifier(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "BasicElements.QualifiedIdentifier")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "BasicElements.QualifiedIdentifier"), "QualifiedIdentifier")(TParseTree("", false,[], s));
        }
    }
    static string QualifiedIdentifier(GetName g)
    {
        return "BasicElements.QualifiedIdentifier";
    }

    static TParseTree Char(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "BasicElements.Char")(p);
        }
        else
        {
            if (auto m = tuple(`Char`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "BasicElements.Char"), "Char")(p);
                memo[tuple(`Char`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Char(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "BasicElements.Char")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "BasicElements.Char"), "Char")(TParseTree("", false,[], s));
        }
    }
    static string Char(GetName g)
    {
        return "BasicElements.Char";
    }

    static TParseTree Hex(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), "BasicElements.Hex")(p);
        }
        else
        {
            if (auto m = tuple(`Hex`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), "BasicElements.Hex"), "Hex")(p);
                memo[tuple(`Hex`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Hex(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), "BasicElements.Hex")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), "BasicElements.Hex"), "Hex")(TParseTree("", false,[], s));
        }
    }
    static string Hex(GetName g)
    {
        return "BasicElements.Hex";
    }

    static TParseTree Scientific(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "BasicElements.Scientific")(p);
        }
        else
        {
            if (auto m = tuple(`Scientific`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "BasicElements.Scientific"), "Scientific")(p);
                memo[tuple(`Scientific`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Scientific(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "BasicElements.Scientific")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "BasicElements.Scientific"), "Scientific")(TParseTree("", false,[], s));
        }
    }
    static string Scientific(GetName g)
    {
        return "BasicElements.Scientific";
    }

    static TParseTree Floating(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "BasicElements.Floating")(p);
        }
        else
        {
            if (auto m = tuple(`Floating`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "BasicElements.Floating"), "Floating")(p);
                memo[tuple(`Floating`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Floating(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "BasicElements.Floating")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "BasicElements.Floating"), "Floating")(TParseTree("", false,[], s));
        }
    }
    static string Floating(GetName g)
    {
        return "BasicElements.Floating";
    }

    static TParseTree Unsigned(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "BasicElements.Unsigned")(p);
        }
        else
        {
            if (auto m = tuple(`Unsigned`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "BasicElements.Unsigned"), "Unsigned")(p);
                memo[tuple(`Unsigned`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Unsigned(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "BasicElements.Unsigned")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "BasicElements.Unsigned"), "Unsigned")(TParseTree("", false,[], s));
        }
    }
    static string Unsigned(GetName g)
    {
        return "BasicElements.Unsigned";
    }

    static TParseTree Integer(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "BasicElements.Integer")(p);
        }
        else
        {
            if (auto m = tuple(`Integer`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "BasicElements.Integer"), "Integer")(p);
                memo[tuple(`Integer`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Integer(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "BasicElements.Integer")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "BasicElements.Integer"), "Integer")(TParseTree("", false,[], s));
        }
    }
    static string Integer(GetName g)
    {
        return "BasicElements.Integer";
    }

    static TParseTree Hexa(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "BasicElements.Hexa")(p);
        }
        else
        {
            if (auto m = tuple(`Hexa`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "BasicElements.Hexa"), "Hexa")(p);
                memo[tuple(`Hexa`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Hexa(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "BasicElements.Hexa")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "BasicElements.Hexa"), "Hexa")(TParseTree("", false,[], s));
        }
    }
    static string Hexa(GetName g)
    {
        return "BasicElements.Hexa";
    }

    static TParseTree Sign(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "BasicElements.Sign")(p);
        }
        else
        {
            if (auto m = tuple(`Sign`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "BasicElements.Sign"), "Sign")(p);
                memo[tuple(`Sign`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sign(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "BasicElements.Sign")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "BasicElements.Sign"), "Sign")(TParseTree("", false,[], s));
        }
    }
    static string Sign(GetName g)
    {
        return "BasicElements.Sign";
    }

    static TParseTree Bool(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("true", "false"), "BasicElements.Bool")(p);
        }
        else
        {
            if (auto m = tuple(`Bool`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("true", "false"), "BasicElements.Bool"), "Bool")(p);
                memo[tuple(`Bool`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Bool(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("true", "false"), "BasicElements.Bool")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("true", "false"), "BasicElements.Bool"), "Bool")(TParseTree("", false,[], s));
        }
    }
    static string Bool(GetName g)
    {
        return "BasicElements.Bool";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(String(p));
        result.children = [result];
        result.name = "BasicElements";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return BasicElements(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return BasicElements(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "BasicElements";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericBasicElements!(ParseTree).BasicElements BasicElements;

