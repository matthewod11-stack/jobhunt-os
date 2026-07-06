---
description: One-time setup - interview you, then generate your profile, corpus, and resume variants (replacing the Jordan Reyes examples)
---

# /setup

You are running the one-time setup for this job-search workspace. The repo ships with a fictional example persona (Jordan Reyes) so the user can see what good output looks like. Your job: interview the user, then replace every piece of example content with their real content. Work through the phases in order. Keep momentum: batch related questions, never ask one question at a time when three belong together.

Throughout this command, all paths are relative to the workspace root (the directory containing CLAUDE.md). If any expected file is missing, tell the user what is missing in one sentence and continue with the phases that do not depend on it. Never fabricate content to paper over a missing file.

## Partial progress

Each phase writes its outputs to disk before the next phase begins, so quitting midway leaves the workspace in a usable mixed state (some files theirs, some still Jordan's). If the user stops early, tell them exactly which files are now theirs and which are still example content, and that re-running /setup later is safe: for each phase, check whether the target file's first line begins `<!-- Example output` (the example-content marker; match on this prefix, not the full literal string, since the dash character in the marker can vary) or the file otherwise carries Jordan Reyes content. If it does, run the phase. If the user has already replaced it, ask whether to regenerate or keep it, then skip or redo accordingly.

## Phase 1: Intro and inventory

First, read these files to ground yourself in the example content and its shapes:

- CLAUDE.md
- profile/voice.md
- profile/fit-profile.json
- corpus/answer-bundles.md
- corpus/cheat-sheet.md
- tracker.csv
- List templates/ to see the example resume variants

Then give the user a short (under 150 words) explanation of what /setup will do:

- It interviews them about their resume history, target roles, writing voice, career stories, and search criteria.
- It REPLACES these example files with their real content: templates/resume-*.md and the built .pdf/.html/.docx artifacts, profile/voice.md, profile/fit-profile.json, corpus/answer-bundles.md, corpus/cheat-sheet.md, and, if present, the example application and interview docs in applied/ and interview-prep/.
- corpus/question-trends.md is KEPT as-is. It is shared seed data (anonymized interviewer-question frequencies), not persona content.
- Expect 20 to 30 minutes of conversation. They can stop at any phase boundary and resume later.

Use AskUserQuestion to confirm: "Ready to start?" with options like "Yes, let's go" / "Tell me more first" / "Not now". If they want more detail, answer their questions, then re-confirm. If not now, stop cleanly.

## Phase 2: Resume intake

Ask the user to provide their current resume, any of:

- Paste the text directly into chat
- Give a file path to a .md, .pdf, or .docx (the Read tool handles PDFs; for .docx, convert first with `pandoc <file> -t markdown` via Bash)
- Multiple resumes are welcome; more raw material means better variants

If they have no resume at all, build their history from an interview instead. For each role, ask (batched per role, not one field at a time): employer, title, dates, what they owned, and 2 or 3 concrete outcomes with numbers where they exist. Work backwards from the most recent role. Also collect: name, email, phone, location, LinkedIn URL (these go in the resume header). These populate the resume header in Phase 4. Skip anything already present in a provided resume.

Before moving on, echo back a compact summary of their work history (roles, dates, standout outcomes) and ask them to correct anything wrong. This summary is the factual backbone for Phase 4; errors here propagate everywhere. Keep the echo brief when the user provided a complete resume file; expand it only for interview-built histories.

## Phase 3: Lanes interview

Ask: what 2 or 3 role types are you hunting? A "lane" is a distinct way of packaging the same career, for example "growth" vs "product marketing" vs "founding marketer". Use AskUserQuestion where their earlier answers suggest obvious candidate lanes; free text otherwise.

For each lane, collect in one batched exchange:

- Target titles (the exact strings recruiters use)
- Which parts of their experience LEAD in this lane
- Which parts get deemphasized (never deleted, just moved down or compressed)
- A short slug for the filename, lowercase, no spaces (e.g. "growth", "pmm", "founding")

Write the lane definitions into your working notes for this session and echo them back for confirmation. They drive Phase 4 (one resume variant per lane) and Phase 7 (the lanes object in fit-profile.json).

## Phase 4: Generate resume variants

For each lane, write templates/resume-{lane-slug}.md from the user's real history, reframed for that lane. Study the structure of the existing example variants first and mirror that structure, since templates/resume.css styles it.

Each variant contains, in order: contact header line (name as an H1, then a line with email, LinkedIn, phone, and location separated by " | "); summary paragraph (2-3 sentences, opens with the lane's point of view); `## EXPERIENCE` (roles reverse-chronological, each with a role/company/dates line, a 1-line company-context italic, and 3-6 bullets); `## SELECTED WINS` (2-3 entries, each adding a fact not in the experience bullets); `## SKILLS`; `## EDUCATION`. Insert one `<div style="page-break-before: always;"></div>` at the section boundary nearest the page-1/page-2 break (in the example variants, immediately before `## SELECTED WINS`).

Rules for every variant:

- Never invent experience. Never change titles, dates, or employers.
- Same facts in every variant; only framing differs.
- 2-3 standout metrics per role, not every bullet quantified. Vary bullet lengths and openings.
- Target a clean 2-page PDF.

Show each variant to the user and revise until they approve it. Then:

1. Delete the Jordan example variants and all their build artifacts: templates/resume-growth.md, templates/resume-pmm.md, and every matching .pdf, .html, and .docx in templates/. If any are already gone, skip silently.
2. Build each new variant: `./templates/build-resume.sh "templates/resume-{lane-slug}.md"`. If the script fails because pandoc or weasyprint is not installed, show the install hint it prints, tell the user the .md sources are complete and the PDFs can be built after installing, and continue to Phase 5.
3. Read each generated PDF and check the layout: 2 pages, no heading stranded at the bottom of a page, no single bullet orphaned onto page 3. Fix bad breaks by inserting `<div style="page-break-before: always;"></div>` in the .md at a natural section boundary, then rebuild and re-check.

## Phase 5: Voice profile

Ask the user for 2 or 3 writing samples: work emails, internal docs, Slack posts, anything they actually wrote in their own voice. NOT their resume. A resume is already performative and will teach you the wrong voice. Paste or file path, either works.

Check sample quality before extracting: if the samples total under ~150 words, are all in one register (e.g. all formal announcements), or contradict each other stylistically, say so and ask for one more sample from a different context. Thin or uniform input produces miscalibrated voice rules, and every downstream artifact inherits them.

From the samples, extract:

- Sentence-length habits (short and punchy vs long and subordinate-clause heavy)
- Discourse markers they reach for (their equivalent of "plainly:", "look,", "honestly")
- Words they would never use (build their banned list from evidence plus asking them directly)
- Words they overuse (flag as "ration these" rules)

Read profile/voice.md and overwrite it keeping its existing SHAPE: a "## Voice rules" section of concrete, checkable bullets, then a "## Sample paragraphs" section with 2 paragraphs in the user's voice, each followed by an italic annotation naming which rules it demonstrates. Two of the existing rules are universal, not Jordan's, and must be preserved verbatim: the metrics-density rule and the opening-variety rule. Every other rule gets rewritten from the user's actual samples. For the 2 sample paragraphs, draft them from the user's real stories, show them, and revise until the user says "yes, that sounds like me".

## Phase 6: Positioning seed

### Answer bundles

Interview the user for 3 to 5 career stories. Prompt for these shapes (skip any that do not apply, accept substitutes):

- A bet that worked
- A mess they cleaned up
- Something they built that outlasted them
- Why they are looking (the honest version)
- The hardest question they expect in this search

For each story, dig until you have: the situation in one or two sentences, what they actually did, the measurable or observable result, and what it proves about how they operate.

Read corpus/answer-bundles.md. Mirror its intro and per-answer structure exactly: the intro explains the spine (a principle, what I've done, what I'd do now, and a stop line), including the teaching that the principle is never announced as a thesis, it is the organizing idea folded into how the story is told, coloring at most the first sentence. Keep that intro (it is methodology, not Jordan content, but rewrite any Jordan-specific sentence). Then write one "## {question}" section per story with the four bold-labeled parts: **Principle:** / **What I've done:** / **What I'd do now:** / **Stop line:**. A good principle is a claim the story proves, not a platitude. A good stop line is one short declarative sentence with a payoff, never a summary. Overwrite the file. Show it to the user and revise.

### Cheat sheet

Ask: "What about your history needs careful framing?" Examples to prompt with: a layoff, a short stint, a career change, a gap, a title that undersells the work. For each, agree on the one-or-two-sentence framing they will use every time.

Read corpus/cheat-sheet.md and overwrite it keeping its 5-section skeleton:

1. **## Stories bank**: their best 2 or 3 stories from the bundle interview, each as a bold-titled paragraph with a "**Use when:**" line listing the question types it answers.
2. **## Framing rules**: the careful-framing rules you just agreed on, as bullets.
3. **## Language discipline**: keep the existing section's intent (profile/voice.md is the source of truth; read it before drafting anything a recruiter or interviewer sees), rewritten in the user's terms.
4. **## Scout scoring corrections**: empty except the explainer line that /scout appends corrections here as few-shot examples for future runs.
5. **## Promoted from debriefs**: empty except the explainer line that /debrief adds reusable lessons here. Do not carry over Jordan's promoted example.

## Phase 7: Fit profile

Interview for the search criteria, batched into at most two exchanges. Use AskUserQuestion for the multiple-choice-shaped ones (stages, remote/hybrid/onsite), free text for the rest:

- Lanes: reuse the Phase 3 lane definitions, one line each
- Locations (cities plus remote scope)
- Stages (seed, series-a, series-b, series-c, growth, public; any subset)
- Sectors they want (and any they are lukewarm on)
- Comp floor (base salary minimum, with currency)
- Avoid-list (role types, sectors, or company shapes that are automatic passes)
- One-line notes: any preference that does not fit the fields above

Overwrite profile/fit-profile.json using exactly this schema (same shape as the shipped file):

```json
{
  "name": "string, the user's full name",
  "lanes": {
    "{lane-slug}": "one-line description: target titles plus what leads",
    "...": "one entry per Phase 3 lane, keys match the resume variant slugs"
  },
  "locations": ["array of strings"],
  "stages": ["array of strings"],
  "sectors": ["array of strings"],
  "comp_floor": "string, e.g. 165000 USD base",
  "avoid": ["array of strings"],
  "notes": "string, one or two sentences"
}
```

Validate the result is parseable JSON (`python3 -c "import json; json.load(open('profile/fit-profile.json'))"` or equivalent) before moving on.

## Phase 8: Cleanup and report

If applied/ or interview-prep/ contain files with the example-content marker (first line beginning `<!-- Example output`) or Jordan Reyes content, ask via AskUserQuestion: "Keep the Jordan Reyes example prep, debrief, and recap docs around for reference, or start with a clean slate?" Options: "Keep for reference" / "Clean slate". If they're empty, skip this question entirely.

If clean slate:

- Delete example files in applied/ and interview-prep/ (anything carrying the example-content marker or Jordan Reyes content). If those directories are empty or absent, note it and move on.
- Clear Jordan's rows from tracker.csv, keeping the header row intact. If the tracker is already header-only, leave it untouched.

If keep: leave them, but remind the user those files are fiction and /scout, /apply, and /prep will ignore or replace them as real work accumulates.

Finish with a report, one line per artifact:

- Each templates/resume-{lane-slug}.md plus its .pdf/.html/.docx (or "PDF pending, install pandoc/weasyprint")
- profile/voice.md
- profile/fit-profile.json
- corpus/answer-bundles.md (N bundles)
- corpus/cheat-sheet.md (N stories, N framing rules)
- corpus/question-trends.md (kept, shared seed data)
- tracker.csv state
- Anything skipped and why

Then suggest the next step: run /scout to source the first batch of companies against the new fit profile. If the user wants to commit, a single commit like "chore: replace example persona with my profile (via /setup)" is the clean move, but do not commit without asking.
