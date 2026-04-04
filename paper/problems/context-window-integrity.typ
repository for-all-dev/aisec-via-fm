// Tag: context-window-integrity
// Layers: execution-harness
// Category: widget

#import "../common/fns.typ": related-layers

== Context Window Integrity Under Adversarial Length <sec:context-window-integrity>

#related-layers("context-window-integrity")

A model's context window is a fixed-size resource. The serving harness fills it by concatenating, in priority order, a system prompt, developer instructions, retrieved context (from RAG or tool outputs), and the user message. When the user message or retrieved context is long enough, something has to be truncated --- and in most deployed systems, truncation is last-in-wins or proportional, not priority-respecting. An adversary who controls message length (trivially: just send a long message) or who can influence retrieved-context length (less trivially: poison a document store with padding) can force eviction of the system prompt. Once the system prompt is gone, so are the behavioral constraints it encodes.

This is a resource-scheduling problem in disguise. The system prompt and developer instructions are hard reservations; user input and retrieved context are elastic. The invariant is simple to state: _the system prompt occupies a reserved prefix of guaranteed minimum size, and truncation of lower-priority sections never reduces the system-prompt allocation_. This is a monotonicity property --- increasing the length of a lower-priority section can only shrink other lower-priority sections, never the reserved prefix. It is exactly the kind of property that tools like Dafny and Frama-C are built to verify, because it reduces to an invariant over a bounded integer program (token counts, priority levels, allocation sizes).

The reason this has not been done is that context assembly logic is typically embedded in application code --- a few dozen lines of Python in a LangChain pipeline or a custom harness --- and nobody has extracted a specification from it. But the specification is short, the code is short, and the proof obligation is a loop invariant. This is one of the lowest-effort, highest-value verification targets in the serving stack.

=== Solution/project Sketch <sec:context-window-integrity-sketch>

Model context allocation as a resource-bounded scheduler with a fixed budget of $N$ tokens and $k$ priority levels. Each level has a minimum reservation $r_i$ with $sum r_i <= N$. Surplus tokens are distributed to lower-priority levels in priority order. Specify the allocator in Dafny or Frama-C and prove two properties: (1) _reservation guarantee_ --- for all inputs, every priority level receives at least $r_i$ tokens, and (2) _monotonicity_ --- increasing the requested length of level $j$ does not decrease the allocation of any level $i$ with $i < j$ (higher priority).

Extract the verified allocator as a standalone function that existing harnesses can call to compute truncation boundaries before assembling the context. The function takes token counts per section and returns per-section truncation limits. Integration is a one-line change in any harness that currently does its own ad-hoc truncation.
