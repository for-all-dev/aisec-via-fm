# Audit Prose

Read every `.typ` file under `paper/` (excluding `common/fns.typ` and `common/authors.typ`) and produce a triage report. Do NOT edit any files.

## What to flag

### 1. LLM slop (highest priority)
Language-model tells. These are the #1 thing we're looking for. Flag aggressively.

- **Hollow intensifiers / filler**: "crucial", "vital", "pivotal", "paramount", "indispensable", "fundamental" (when not actually defining a foundation), "It is worth noting that", "Notably,", "Importantly,", "Indeed,", "Furthermore,", "Moreover,", "In essence,"
- **Vague grandiosity**: "transformative potential", "paradigm shift", "represents a significant advancement", "paves the way", "at the forefront", "the landscape of", "in the rapidly evolving", "the ever-growing", "a nuanced understanding"
- **Redundant hedging clusters**: "may potentially", "could possibly", "it is important to note that"
- **Formulaic structure**: paragraphs that open with a claim, give three comma-separated examples, then close with a restatement of the claim
- **Sycophantic connectives**: "Building on this,", "Leveraging this,", "To this end,"
- **Over-enumeration**: bullet lists or numbered lists that pad with near-synonyms to hit a round number
- **"Comprehensive"**: almost always a slop marker in position papers

When flagging, quote the offending phrase and suggest either deletion or a concrete rewrite direction.

### 2. TODOs / placeholders
- Explicit `// TODO`, `#todo`, `lorem ipsum`, or `[TBD]` markers
- Sections that are clearly skeletal (single-sentence paragraphs acting as placeholders)
- Empty or near-empty sections

### 3. Writing quality issues (lower priority)
- Passive voice where active would be clearer
- Sentences over ~40 words that could be split
- Jargon used without definition on first occurrence (for a formal-methods expert audience who may NOT know ML ops jargon, and vice versa)
- Inconsistent terminology (e.g., switching between "model weights" and "parameters" without establishing equivalence)

## Output format

Group findings by file. Within each file, sort by priority: slop first, then TODOs, then quality. Use this format:

```
## paper/path/to/file.typ

### Slop
- **L14**: "This represents a crucial advancement in the landscape of..." -- delete or replace with a concrete claim
- **L27**: "Furthermore, it is worth noting that..." -- cut the throat-clearing, start with the actual point

### TODOs / Placeholders
- **L3-8**: Section is skeletal, single placeholder sentence

### Quality
- **L41**: 52-word sentence, consider splitting at "which"
- **L19**: "RoCE" used without expansion (first occurrence)
```

If a file has no issues, say so in one line and move on.

## Severity summary

End the report with a short summary: how many files audited, counts by category, and which files need the most attention. Keep the summary to 3-5 lines.
