module metad.grammar.inifile;

private import std.array;

private import pegged.grammar;
private import metad.compiler;
private import metad.interp;

private import metad.gen.grammar.elements;

enum INIGrammarFilename = "grammar/inifile.peg";
enum INIGrammarText = import(INIGrammarFilename);

version(INIGrammar_Generate) {
	static this() {
		import std.file;
		mkdirRecurse("source/metad/gen/grammar");
		asModule("metad.gen.grammar.inigrammar","source/metad/gen/grammar/inigrammar",INIGrammarText,"private import metad.gen.grammar.elements;");
	}
}

version(INIGrammar_Inline) {
	mixin(grammar(INIGrammarText));
} else {
	private import metad.gen.grammar.inigrammar;
}

struct INIGrammarCompiler(ParseTree T) {
	template _ident(alias id) {
		enum _ident = id;
	}
	template _section(alias head,T...) {
		//enum _section=compileNode!(T.children[0]);
		//enum _section = compileChildNodes;
	}
	template _sectionhead() {

	}
	template _declaration() {

	}
	template _literal() {

	}
	//@Match!(INIGrammar.Section)
	@MatchCond("T.children.length>=1 && T.Name == INIGrammar.Section")
	static auto matchSection(ParseTree t) {
		return "_section!("~compileChildNodes.join(",")~")";
	}
	@MatchName("INIGrammar.SectionHead")
	static auto matchSectionHead(ParseTree t) {
		return "_sectionhead!("~compileChildNodes~")";
	}
	//@Match!(INIGrammar.Declaration)
	@MatchName("INIGrammar.Declaration")
	static auto matchDefinition(ParseTree t) {
		return "declaration!("~")";
	}
	//@Match!(identifier) 
	@MatchName("identifier") 
	static auto matchIdentifier(ParseTree t) {
		return "_ident!("~T.matches.join~")";
	}
	@MatchName("INIGrammar")
	static auto matchGrammar(ParseTree t) {
		return compileChildNodes.join;
	}
	mixin Compiler!(T,INIGrammarCompiler!T);
	mixin processTypeAnnotations!INIGrammarCompiler;

}

unittest {
	import std.experimental.logger;
	enum INIFILE = "tests/test.ini";
	enum INITEXT = import(INIFILE);
	enum compiled = INIGrammarCompiler!(INIGrammar(INITEXT)).compileNode();
	pragma(msg,"Compiled: " ~ compiled);
	//mixin(compiled);
}
