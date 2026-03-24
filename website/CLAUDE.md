# `tractable.for-all.dev`

## Design
- tacky hacker aesthetic? `tsdh-dark` from doomemacs themes should be the color scheme. Something none distracting 
- password protected (`PASSWORD` in `.env`)
- all content is in `typst`. You need to find some way to render `typst` for web in html. 
- system for partial authorship, like a tag based system that references `./../paper/common/authors.typ` so people can claim authorship on part but not all of the document/website. 
- I think 3 routes: homepage corresponding to "the stack" content, about/authorship page, and "problems" route but the problems route will be more complicated, it'll have like `/problems/[id]` where the id comes from `./../paper/problems/[id].typ` or something like this
- homepage: should be executive summary each of the `stack` categories as dropdown
  - a link to my calendly on homepage https://calendar.app.google/9Xir9aEK9ZrdttAr8

## Dev

- `effect` when appropriate
- will be a standard vercel deploy-- should be stateless (besides the pw env var)
- use `bun add` instead of manually patching `package.json` with whatever version you happen to pull out of your ass.
