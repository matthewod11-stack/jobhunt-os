---
description: Tailor a resume variant to a job posting, build the PDF, optionally draft a cover letter, and log it to the tracker
argument-hint: URL to the job posting
---

# /apply

You are tailoring one of the user's resume variants to a specific job posting, building the PDF, optionally drafting a cover letter, and logging the application to tracker.csv.

All paths are relative to the workspace root (the directory containing CLAUDE.md). If an expected file is missing, say what is missing in one sentence and continue with what you can; never fabricate content to paper over a gap.

Before drafting anything, read profile/voice.md and enforce ITS rules throughout. That file defines the user's voice: their banned words, their sentence habits, their rationed words. The rules below are universal; voice.md is personal and wins on any specifics.

## Natural voice rules (universal)

The goal is output that reads like the user wrote it themselves. ATS AI detection is rare, but recruiter gut-feel detection is real. Avoid both extremes:

- **Don't over-specify.** Naming every tool, API, and platform reads like keyword stuffing. Use 1-2 specific names where they carry weight, generalize the rest. A human says "government procurement sites", not a list of every portal they ever logged into.
- **Don't over-quantify.** Not every bullet needs a metric. Precise-sounding numbers on every line feels optimized. Pick 2-3 standout metrics per role and let the rest speak for themselves.
- **Vary sentence structure.** Don't start every bullet with a past-tense power verb. Mix in fragments, subordinate clauses, and different openings. Some bullets punchy, some longer.
- **Vary bullet lengths.** Mix 1-line and 2-line bullets. Uniform length is an AI signal.
- **Avoid buzzword saturation.** If a word sounds like it came from a LinkedIn optimization guide, cut it. Real humans don't "drive cross-functional alignment", they "got engineering and legal on the same page".
- **Specificity where it counts.** Name the actual company, team size, or outcome when it makes the bullet concrete. Don't name every sub-tool in a stack just to prove depth.
- **Limit dashes.** Dash-connected clauses in every bullet are an AI tell. Restructure with periods, commas, or semicolons instead. Keep it to a few dashes per page at most.

## Step 1: Fetch and analyze the job posting

If no URL was passed as $ARGUMENTS, ask the user up front for the job posting URL or the pasted job description text before doing anything else; never WebFetch an empty string.

Fetch the URL using WebFetch. Extract:

- Company name
- Role title
- Key responsibilities
- Required skills and experience
- Company stage, size, and industry
- Any cultural signals or specific language they use

If the URL fails, ask the user to paste the job description directly and work from that. Treat a soft failure the same way: if the fetch "succeeds" but the extracted content is thin or clearly not a job description (a JS-shell page from Greenhouse, Lever, or LinkedIn is the common case; login walls and dead links too), that counts as a failed fetch. Fall back to the paste rather than analyzing a page skeleton.

Before asking for the paste, if the URL is an ashbyhq.com, greenhouse.io, or lever.co posting, try the host's public posting API once: Ashby via the jobs.ashbyhq.com posting-api job-board endpoint, Greenhouse via boards-api.greenhouse.io, Lever via api.lever.co/v0/postings. One attempt only; if it fails or the posting is not found, fall back to the paste.

When the JD arrives via paste (any path), save it to `interview-prep/{company}-jd.md`, the same file /prep would create, so downstream commands can find it.

## Step 2: Recommend a resume variant

List the available variants: `ls templates/resume-*.md`. If the glob matches nothing, stop and tell the user to run /setup first; there is nothing to tailor.

Read the first 10 lines of each variant (the header and summary reveal the lane's point of view). If every variant's first line begins with the example-content marker prefix `<!-- Example output`, stop here and tell the user to run /setup first; no need to ask them to pick a variant that is about to be rejected by the Step 3 guard. Otherwise, based on the role's core mandate, recommend one variant with 1-2 sentences of reasoning, then confirm with AskUserQuestion, offering each variant as an option so the user can override.

## Step 3: Read the selected variant

Read the chosen file from templates/ in full. Also read profile/fit-profile.json; you need the `name` field for output filenames and the lane keys for the tracker row.

**Example-content guard.** Before proceeding, check for the shipped example persona (same logic /setup uses):

- If the chosen variant's first line begins with the example-content marker prefix `<!-- Example output` (match on this prefix only, not the full literal string, since the dash character in the marker can vary), it is still the fictional Jordan Reyes example.
- If profile/fit-profile.json still carries the example persona (the `name` field is "Jordan Reyes"), the profile has not been replaced either.

If either check trips, STOP and tell the user to run /setup first. Tailoring the example content would produce a fictional person's resume submitted under a real application. Do not continue past this point.

## Step 4: Tailor the resume

Make targeted adjustments to the selected variant. DO NOT rewrite from scratch; the variants are already well-crafted. Only modify:

1. **Summary/headline**: adjust 1-2 sentences to directly address this role's core mandate. Mirror their language where natural. Be honest about who the user is; don't claim titles they haven't held.
2. **Bullet emphasis**: reorder or lightly adjust 2-3 bullets in the most recent roles to foreground the experience most relevant to THIS job's specific needs.
3. **Skills section**: reorder to put their most-wanted skills first. Add any specific tools or platforms the posting names that the user has actually used.
4. **Wins/projects section**: reorder to lead with the entries most relevant to this role.
5. **Earlier roles**: every role keeps at least 1 bullet with context. Don't compress older roles into a one-liner.

DO NOT:

- Change job titles, dates, or company names
- Invent experience the user doesn't have
- Add buzzwords or fluff
- Remove sections that differentiate the user just because the posting doesn't mention them
- Over-optimize; subtle tailoring beats keyword stuffing

## Step 5: Save and build the PDF

Get the user's name from the `name` field of profile/fit-profile.json. Save the tailored resume as `applied/{Name} {Company} Resume.md` (e.g. "Jordan Reyes Acme Resume.md"). When building the filename, replace any path-unsafe characters in the company name (especially `/`, also `:` and quotes) with a hyphen or a space; "TBD Health / Labs" becomes "TBD Health - Labs". Then build:

```bash
./templates/build-resume.sh "applied/{Name} {Company} Resume.md"
```

The script resolves its CSS by absolute path, so it works on files in applied/ without copying anything. It produces .html, .pdf, and .docx next to the .md; delete the .html (build intermediate) and keep the .md, .pdf, and .docx (some application portals want a .docx). (Deleting the .html here while templates/ keeps its .html files is intentional: templates are reference masters, applied docs are one-offs.)

If the script fails because pandoc or weasyprint is not installed, show the install hint it prints, tell the user the .md is complete and the PDF can be built after installing, and continue to Step 7 (skip the PDF review).

## Step 6: Review the PDF

Read the generated PDF and verify:

- Clean 2-page layout: no heading stranded at the bottom of a page, no single bullet orphaned onto a page by itself
- No rule violations from profile/voice.md or the universal rules above
- Sections render cleanly (skills and education on their own lines)

If there are page-break issues, either trim a few words from bullets or insert `<div style="page-break-before: always;"></div>` in the .md at a natural section boundary to force a clean break, then rebuild and re-check.

## Step 7: Cover letter (optional)

Ask with AskUserQuestion: "Generate a cover letter for this application?" Options: "Yes" / "No, resume only".

If yes:

- Reuse the Step 1 job analysis and the tailored resume already in context; don't re-fetch or re-read.
- Read corpus/cheat-sheet.md and pick the ONE story or framing that best hooks into this specific company and role. One hook, developed well, beats three mentioned in passing.
- Lead with why THIS company: something specific from the posting or your Step 1 research, not a generic opener that could go to any company.
- Never restate the resume. The letter earns its place by saying what the resume can't: motivation, fit, the story behind one relevant win.
- Keep it under one page. Three or four short paragraphs.
- The voice rules apply doubly here. A cover letter in template-speak is worse than no cover letter. Draft it in the user's voice per profile/voice.md, show it, and revise until they approve.

Save as `applied/{Name} {Company} Cover Letter.md` and build the PDF with the same pipeline:

```bash
./templates/build-resume.sh "applied/{Name} {Company} Cover Letter.md"
```

Delete the .html intermediate and keep the .docx, same rationale as the resume (some application portals want a .docx). Verify the PDF is a single page; trim if not.

## Step 8: Update the tracker

tracker.csv is the single log; every application gets a row. Columns, in order:

```
Company,Role,Source,Fit Score,Fit Lane,Status,Date Added,Date Applied,Last Touch,Touch Type,Response,Response Date,Notes
```

Get today's date with `date +%Y-%m-%d`. Match existing rows on Company AND Role (both case-insensitive), not company alone. Then:

- **If a row for this company and role already exists**: update it in place. Set Status=Applied, Date Applied=today, Last Touch=today, Touch Type=application. Keep the existing Source, Fit Score, Fit Lane, and Date Added.
- **If a row matches on Company and its Role field is EMPTY** (a /scout row): treat it as this application's row. Fill in the Role from Step 1 and update it in place as above, preserving Source, Fit Score, Fit Lane, and Date Added.
- **If the company exists but with a DIFFERENT role**: append a new row for this role rather than overwriting the other one, and flag it to the user ("you already have {Company} tracked for {other role}; adding a second row for {this role}").
- **If no row exists**: append one. Company and Role from Step 1, Source=applied-direct, Fit Score empty (that's /scout's job), Fit Lane=the lane slug of the variant used, Status=Applied, Date Added=today, Date Applied=today, Last Touch=today, Touch Type=application, Response and Response Date empty, Notes=one short phrase if there's anything worth remembering (else empty).

CSV rules: quote any field containing a comma; escape embedded double-quotes by doubling them (RFC 4180). Keep the header row intact and don't disturb other rows.

## Step 9: Report

Close with a brief report:

- File paths written: the tailored .md, the .pdf (and .docx), and the cover letter files if generated
- What you changed in the variant and why, 3-5 bullets tied to the job posting
- The tracker row written or updated, shown as a single line

Suggest the natural next step: /outreach {company} to line up a warm touch alongside the application.
