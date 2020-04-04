module metad.grammar.basic;

private import pegged.grammar;

enum BasicElementsGrammarFilename = "grammar/elements.peg";
enum BasicElementsGrammarText = import(BasicElementsGrammarFilename);

version(ElementsGrammar_Generate) {
	void main() {
		import std.file;
		mkdirRecurse("source/metad/gen/grammar");
		asModule("metad.gen.grammar.elements","source/metad/gen/grammar/elements",BasicElementsGrammarText);
	}
}
version(ElementsGrammar_Inline) {
	mixin(grammar(BasicElementsGrammarText));
} else {
	private import metad.gen.grammar.elements;
}
