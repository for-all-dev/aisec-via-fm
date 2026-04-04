// Tag: verified-input-parsers
// Layers: execution-harness, software-framework
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers

== Verified Input Parsers <sec:verified-input-parsers>

#related-layers("verified-input-parsers")

Every boundary in the AI serving stack where text is parsed or transformed is a security boundary. The abuse classifier preprocessor tokenizes, truncates, and encodes user input before classification --- if that pipeline is wrong in any of several subtle ways (non-idempotent truncation, encoding expansion, off-by-one in token windowing), an adversary can craft inputs that the classifier never actually sees. The prompt assembly layer concatenates system instructions, developer instructions, retrieved context, and user messages into a single model input, relying on implicit priority ordering that the model is supposed to respect but cannot enforce. The tokenizer itself --- typically byte-pair encoding --- is deterministic but has never been formally specified; BPE admits multiple encodings for the same string and includes control-character tokens that downstream components may interpret specially. And on the output side, tool-call parsers extract structured invocations from free-form model text, where any confusion between "model is describing a tool call" and "model is issuing a tool call" is a direct security breach.

These are not four separate problems. They are one problem with four instances: _unverified parsers at trust boundaries_. The LangSec movement @sassaman2013langsec has argued for years that ad-hoc input handling is the root cause of most exploitation. In the AI serving stack the argument applies with unusual force, because the inputs are adversarially chosen (user prompts), the transformation pipelines are subtle (BPE, priority-based concatenation), and the consequences of parser confusion range from safety-filter bypass to arbitrary tool execution.

The formal methods tooling for this class of problem is mature. EverParse @ramananandro2019everparse produces verified zero-copy parsers from format specifications, with extraction to C. Parser-combinator libraries in Lean and Coq can produce proofs of totality, soundness, and completeness alongside executable code. The properties we need --- that truncation is idempotent, that encoding is non-expanding, that user-supplied characters cannot occupy system-privileged token positions, that tool-call extraction is sound and complete with respect to a grammar --- are all first-order properties over finite structures, well within reach of existing verification technology.

What has been missing is not capability but _targeting_: nobody has written the formal grammars for these specific interfaces and connected them to the actual serving code. The gap is an engineering gap, not a research gap.

=== Solution/project Sketch <sec:verified-input-parsers-sketch>

Frame this as a family of verification targets sharing a common methodology: for each trust boundary, (1) write a formal grammar of the interface, (2) implement a verified parser (EverParse for C-level components, Lean parser combinators for higher-level ones), and (3) prove the relevant security properties.

_Abuse classifier interface._ Specify the grammar of valid requests. Verify that the preprocessing pipeline is a total function from the grammar to classifier inputs. Prove truncation is idempotent and encoding is non-expanding --- i.e. that `preprocess(preprocess(x)) = preprocess(x)` and `|encode(x)| <= |x|` for the relevant notion of length.

_Prompt assembly._ Define a structured document format with explicit priority zones. Prove non-interference: no user-supplied byte sequence can place tokens into the system-prompt zone. This is a separation property on the assembly function, checkable by symbolic execution or refinement proof.

_Tokenizer._ Formalize BPE in Lean or Coq. Prove totality (every byte string has exactly one encoding), surjectivity onto the vocabulary, and that detokenization is a left-inverse of tokenization. Define a "safe" token subset and verify that user-controlled input maps only into this subset.

_Tool-call parser._ Define the tool-call grammar as a formal language. Implement as a verified parser. Prove soundness (anything extracted is a valid tool call per the grammar) and completeness (no valid tool call in the output is missed). The parser should reject ambiguous outputs rather than guess.

Each of these is a standalone artifact producing a verified `.c` or `.lean` module that can be linked into existing serving infrastructure. The shared methodology means the second target is cheaper than the first, and the fourth is routine.
