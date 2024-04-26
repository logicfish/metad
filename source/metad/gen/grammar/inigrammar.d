/+ DO NOT EDIT BY HAND!
This module was automatically generated from the following grammar:

INIGrammar : 
    Grammar <- Statement*
    Statement <- Section / Comment
    Comment <- "#" (!:endOfLine)* :endOfLine
    Section <- SectionHead (Declaration)*
    SectionHead <- :"[" SectionIdentifier :"]" ( :endOfLine / endOfInput )
    SectionIdentifier <- identifier ( :"." identifier)?
    Declaration <- identifier :"=" Literal ( :endOfLine / endOfInput )
    Literal <- BasicElements.String /  BasicElements.Numeric / BasicElements.Bool


+/
module metad.gen.grammar.inigrammar;

private import metad.gen.grammar.elements;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

@safe struct GenericINIGrammar(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct INIGrammar
    {
    enum name = "INIGrammar";
    static ParseTree delegate(ParseTree) @safe [string] before;
    static ParseTree delegate(ParseTree) @safe [string] after;
    static ParseTree delegate(ParseTree) @safe [string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this() @trusted
    {
        rules["Grammar"] = toDelegate(&Grammar);
        rules["Statement"] = toDelegate(&Statement);
        rules["Comment"] = toDelegate(&Comment);
        rules["Section"] = toDelegate(&Section);
        rules["SectionHead"] = toDelegate(&SectionHead);
        rules["SectionIdentifier"] = toDelegate(&SectionIdentifier);
        rules["Declaration"] = toDelegate(&Declaration);
        rules["Literal"] = toDelegate(&Literal);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p) @safe
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

        static ParseTree hooked(string input) @safe
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax) @safe
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax) @safe
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
        {
            if (ruleName != "Spacing")
                rules[ruleName] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s) pure nothrow @nogc
    {
        import std.algorithm : startsWith;
        return s.startsWith("INIGrammar.");
    }
    mixin decimateTree;

    alias spacing Spacing;

    static TParseTree Grammar(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(Statement), "INIGrammar.Grammar")(p);
        }
        else
        {
            if (auto m = tuple(`Grammar`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(Statement), "INIGrammar.Grammar"), "Grammar")(p);
                memo[tuple(`Grammar`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Grammar(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(Statement), "INIGrammar.Grammar")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(Statement), "INIGrammar.Grammar"), "Grammar")(TParseTree("", false,[], s));
        }
    }
    static string Grammar(GetName g)
    {
        return "INIGrammar.Grammar";
    }

    static TParseTree Statement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Section, Comment), "INIGrammar.Statement")(p);
        }
        else
        {
            if (auto m = tuple(`Statement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(Section, Comment), "INIGrammar.Statement"), "Statement")(p);
                memo[tuple(`Statement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Section, Comment), "INIGrammar.Statement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(Section, Comment), "INIGrammar.Statement"), "Statement")(TParseTree("", false,[], s));
        }
    }
    static string Statement(GetName g)
    {
        return "INIGrammar.Statement";
    }

    static TParseTree Comment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.zeroOrMore!(pegged.peg.discard!(pegged.peg.negLookahead!(endOfLine))), pegged.peg.discard!(endOfLine)), "INIGrammar.Comment")(p);
        }
        else
        {
            if (auto m = tuple(`Comment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.zeroOrMore!(pegged.peg.discard!(pegged.peg.negLookahead!(endOfLine))), pegged.peg.discard!(endOfLine)), "INIGrammar.Comment"), "Comment")(p);
                memo[tuple(`Comment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Comment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.zeroOrMore!(pegged.peg.discard!(pegged.peg.negLookahead!(endOfLine))), pegged.peg.discard!(endOfLine)), "INIGrammar.Comment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.zeroOrMore!(pegged.peg.discard!(pegged.peg.negLookahead!(endOfLine))), pegged.peg.discard!(endOfLine)), "INIGrammar.Comment"), "Comment")(TParseTree("", false,[], s));
        }
    }
    static string Comment(GetName g)
    {
        return "INIGrammar.Comment";
    }

    static TParseTree Section(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.zeroOrMore!(Declaration)), "INIGrammar.Section")(p);
        }
        else
        {
            if (auto m = tuple(`Section`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.zeroOrMore!(Declaration)), "INIGrammar.Section"), "Section")(p);
                memo[tuple(`Section`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Section(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.zeroOrMore!(Declaration)), "INIGrammar.Section")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.zeroOrMore!(Declaration)), "INIGrammar.Section"), "Section")(TParseTree("", false,[], s));
        }
    }
    static string Section(GetName g)
    {
        return "INIGrammar.Section";
    }

    static TParseTree SectionHead(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), SectionIdentifier, pegged.peg.discard!(pegged.peg.literal!("]")), pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.SectionHead")(p);
        }
        else
        {
            if (auto m = tuple(`SectionHead`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), SectionIdentifier, pegged.peg.discard!(pegged.peg.literal!("]")), pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.SectionHead"), "SectionHead")(p);
                memo[tuple(`SectionHead`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SectionHead(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), SectionIdentifier, pegged.peg.discard!(pegged.peg.literal!("]")), pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.SectionHead")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), SectionIdentifier, pegged.peg.discard!(pegged.peg.literal!("]")), pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.SectionHead"), "SectionHead")(TParseTree("", false,[], s));
        }
    }
    static string SectionHead(GetName g)
    {
        return "INIGrammar.SectionHead";
    }

    static TParseTree SectionIdentifier(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "INIGrammar.SectionIdentifier")(p);
        }
        else
        {
            if (auto m = tuple(`SectionIdentifier`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "INIGrammar.SectionIdentifier"), "SectionIdentifier")(p);
                memo[tuple(`SectionIdentifier`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SectionIdentifier(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "INIGrammar.SectionIdentifier")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), identifier))), "INIGrammar.SectionIdentifier"), "SectionIdentifier")(TParseTree("", false,[], s));
        }
    }
    static string SectionIdentifier(GetName g)
    {
        return "INIGrammar.SectionIdentifier";
    }

    static TParseTree Declaration(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.discard!(pegged.peg.literal!("=")), Literal, pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.Declaration")(p);
        }
        else
        {
            if (auto m = tuple(`Declaration`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.discard!(pegged.peg.literal!("=")), Literal, pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.Declaration"), "Declaration")(p);
                memo[tuple(`Declaration`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Declaration(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.discard!(pegged.peg.literal!("=")), Literal, pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.Declaration")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.discard!(pegged.peg.literal!("=")), Literal, pegged.peg.or!(pegged.peg.discard!(endOfLine), endOfInput)), "INIGrammar.Declaration"), "Declaration")(TParseTree("", false,[], s));
        }
    }
    static string Declaration(GetName g)
    {
        return "INIGrammar.Declaration";
    }

    static TParseTree Literal(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(BasicElements.String, BasicElements.Numeric, BasicElements.Bool), "INIGrammar.Literal")(p);
        }
        else
        {
            if (auto m = tuple(`Literal`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(BasicElements.String, BasicElements.Numeric, BasicElements.Bool), "INIGrammar.Literal"), "Literal")(p);
                memo[tuple(`Literal`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Literal(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(BasicElements.String, BasicElements.Numeric, BasicElements.Bool), "INIGrammar.Literal")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(BasicElements.String, BasicElements.Numeric, BasicElements.Bool), "INIGrammar.Literal"), "Literal")(TParseTree("", false,[], s));
        }
    }
    static string Literal(GetName g)
    {
        return "INIGrammar.Literal";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Grammar(p));
        result.children = [result];
        result.name = "INIGrammar";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return INIGrammar(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return INIGrammar(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "INIGrammar";
    }


    static void forgetMemo()
    {
        memo = null;
        import std.traits;
        static if (is(typeof(BasicElements.forgetMemo)))
            BasicElements.forgetMemo();
    }
    }
}

alias GenericINIGrammar!(ParseTree).INIGrammar INIGrammar;

