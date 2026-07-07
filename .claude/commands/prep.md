---
description: Build an interview prep doc for a specific company, interviewer, and round
argument-hint: company name, then optional interviewer name and/or JD URL
---

# /prep

You are researching a company and building a structured interview prep doc, grounded in the user's corpus and everything already learned from prior rounds with this company.

All paths are relative to the workspace root (the directory containing CLAUDE.md). If an expected file is missing, say what is missing in one sentence and continue with what you can; never fabricate content to paper over a gap.

## Preflight: corpus guard

The prep doc's positioning comes from the corpus. Before doing anything else, check it is the user's real content (same logic /setup and /apply use):

- If corpus/answer-bundles.md or corpus/cheat-sheet.md is missing or empty, stop and tell the user to run /setup first.
- If the first line of corpus/answer-bundles.md begins with the example-content marker prefix `<!-- Example output` (match on this prefix only, not the full literal string, since the dash character in the marker can vary), it is still the fictional Jordan Reyes example. Same check for corpus/cheat-sheet.md. If either trips, STOP and tell the user to run /setup first. A prep doc built on the example persona would coach the user to interview as a fictional person.
- If profile/fit-profile.json still carries the example persona (the `name` field is "Jordan Reyes"), same stop.

Exception: corpus/question-trends.md is REAL shared seed data (anonymized interviewer-question frequencies), not persona content. It does not carry the example marker and must never be treated as example content or a reason to stop.

## Step 0: Parse arguments

`$ARGUMENTS` is `{company} [interviewer] [jd-url]`. Extract:

- **Company name** (required) -- may be multi-word. If the split between company and interviewer is ambiguous ("Iron Peak Casey Lee" could be company "Iron Peak" + interviewer "Casey Lee" or company "Iron" + a three-word remainder), check the candidate splits against tracker.csv Company values and applied/ filenames first and take the split that lines up with a known company. If it's a first-ever contact and the split is still ambiguous, ask the user rather than guessing.
- **Interviewer name** (optional) -- words after the company that are not a URL
- **JD URL** (optional) -- any URL in the arguments

Example: "Acme Jane Rivera https://jobs.example.com/acme/head-of-x", "Acme Jane Rivera", or just "Acme".

If `$ARGUMENTS` is empty, ask the user for at least the company name before doing anything else.

**Classify the round type.** Decide what the round IS: a recruiter/talent screen, a hiring-manager round, a panel/onsite, or something else (exec chat, take-home review). The presence of an interviewer name says nothing about the round type -- a named recruiter is still a screen; the interviewer name affects the FILENAME, not the classification. Classify from what the user told you, and where that's not enough, from Step 1's findings: the tracker row's Status (no row or Status=Applied suggests a first screen; Status=Screen plus a screen debrief on file suggests a later round) and any prior prep/debrief docs (an existing recruiter-prep doc with no debrief yet usually means this IS still the screen). Ask the user only what the docs can't tell you. The round type drives the strategy section, the filename, and the Step 4 status transition.

## Step 1: Gather existing context

### Check what we already have

1. Search applied/ for an existing tailored resume for this company
2. Search interview-prep/ for any existing prep docs, debriefs, recaps, outreach notes, or saved JDs for this company
3. Search tracker.csv for this company's row (role title, fit lane, status, dates, notes)
4. If a tailored resume exists, read it -- this is what the company has seen

### Check for prior interview intel

If previous prep or debrief docs exist for this company, **read them all**. Extract:

- New intel learned from prior calls (corrected numbers, culture details, process info)
- What worked well and what didn't in previous rounds
- Open questions that were flagged but not yet answered
- Relationships built (recruiter chemistry, who championed the user, etc.)

This is a **build-on** process. Later rounds incorporate everything learned in earlier rounds, not start from scratch.

### Read positioning sources

Read these files for framing, fit-point material, and proven answer language:

- corpus/answer-bundles.md -- canonical answer spines (principle -> what I've done -> what I'd do now -> stop line). The source of truth for how the user answers.
- corpus/cheat-sheet.md -- stories bank, framing rules, language discipline, and the "Promoted from debriefs" section (lessons earned in past interviews; treat these as current).
- corpus/question-trends.md -- real interviewer-question frequencies across many processes. Ground the "likely questions" section in this data, not guesses.
- profile/voice.md -- per the cheat sheet's Language discipline section, this is the voice source of truth; read it before drafting anything the user will say or send.
- The submitted resume for this company (from the search above), if one exists.

### If a JD URL was provided

Fetch the URL and extract the full job description. Save it to `interview-prep/{company}-jd.md` for reference. If that file already exists from an earlier round, never overwrite it: append the new JD under a dated heading, or save it as `interview-prep/{company}-jd-{round}.md`. If the fetch fails or returns a thin JS-shell page instead of a job description, ask the user to paste the JD text and work from that.

### Identify framing gaps

Compare the submitted resume's language against the Framing rules section of corpus/cheat-sheet.md. If no tailored resume exists in applied/, use the base variant in templates/ closest to this role's lane instead. Prep docs use soft framing: lead with the situation, not the credential. If the resume states something more bluntly than the user would say it aloud, note the gap for the Resume vs. Talking Points section and the report.

## Step 2: Research the company

Use web search to gather:

1. **Company basics** -- what they do, HQ, employee count, funding, valuation, stage
2. **Founder/CEO background** -- where they came from, what drives them
3. **Recent news** -- product launches, partnerships, expansions (last 3-6 months)
4. **Products** -- what they sell, who buys it, what's new
5. **The function** -- who leads the org this role sits in, their background, how long they've been there
6. **The role** -- use the JD if provided, otherwise find the job posting. Pull responsibilities and requirements
7. **The interviewer** -- search LinkedIn/web for the specific person the user is meeting. Role, background, tenure at the company

Run these searches in parallel where possible.

**Skip research you already have from prior rounds.** If a previous prep doc already has the company profile, funding, and products, don't re-research -- just verify nothing major has changed since the last prep.

## Step 3: Build the prep doc

Using the round type from Step 0: create `interview-prep/{company}-recruiter-prep.md` for a recruiter screen, or `interview-prep/{company}-{interviewer-name}-prep.md` (or another `{company}-{context}-prep.md` naming the round) for non-recruiter rounds.

**Never overwrite or rewrite existing prep content.** If a prep doc for this round already exists, ask with AskUserQuestion which case this is:

- **Refreshing the same upcoming round** (new intel, rescheduled call): update the SAME doc by ADDING a clearly dated addendum section (e.g. `## Addendum {date}`) carrying what changed. Leave the existing content untouched.
- **Genuinely a new round**: create a new file with a suffix naming the round (e.g. `{company}-{interviewer-name}-prep.md`, `{company}-panel-prep.md`, `{company}-round-2-prep.md`).

### Required sections

1. **Company Profile** -- table: what, founded, HQ, employees, funding, investors, stage
2. **Founder/Leadership** -- brief background on CEO and relevant leaders
3. **Recent News** -- bullet points, last 3-6 months
4. **Products to Know** -- table: product name, what it does
5. **The Role** -- what it actually is, likely responsibilities, requirements, who you report to. Link to JD if available.
6. **Why This Is a Strong Fit** -- 3-5 numbered points mapping the user's experience to the role's needs. Use soft framing. Draw from the corpus (answer bundles, cheat sheet stories) patterns and proof points where relevant.
7. **Recruiter Call Strategy** (or Interview Strategy for later rounds)
   - Positioning statement (30 seconds, soft framing)
   - Key messages to land (3-4 bullets)
   - Questions they'll likely ask + suggested answers. Weight the question list by the frequencies in corpus/question-trends.md, then adjust for this company's specific signals. Shape each suggested answer on the canonical spine from corpus/answer-bundles.md: principle -> what I've done -> what I'd do now -> stop line
   - Questions the user should ask (5-6, showing homework)
8. **Potential Landmines** -- tough questions and how to handle them
9. **Resume vs. Talking Points** -- table mapping submitted resume language to conversational framing. Required for every prep doc. If no tailored resume exists in applied/, map the user's base variant instead (the templates/resume-*.md closest to this role's lane) against the role's demands, and note in the section that no tailored resume was submitted. (No further fallback needed: if the variants are still example content, the preflight guard already stopped the run.)
10. **Prior Round Intel** (if applicable) -- summary of what was learned in previous interviews. Corrected facts, open threads, relationships
11. **Research Gaps** -- what we couldn't find, things to ask on the call

### For later rounds (non-recruiter)

When building prep for round 2+:

- Lead with what we learned from prior rounds, not generic research
- Tailor strategy to the specific interviewer's role and likely priorities
- Reference prior debrief docs for what resonated and what didn't
- Update company profile only where new intel contradicts old

### Framing rules

- Read the Framing rules section of corpus/cheat-sheet.md and enforce every rule there. Those are the framings the user has committed to using every time.
- Soft-framing principle (universal): lead with the situation, not the credential -- let the interviewer connect the dots. If they surface the pattern themselves, the user leans in.
- Draw positioning language from the corpus (answer-bundles.md, cheat-sheet.md) first, not ad hoc phrasing.
- Apply profile/voice.md to anything the user will say out loud or send.

### Domain positioning angles

Pre-agreed positioning angles live in two places in corpus/cheat-sheet.md: the Framing rules section (a rule for a company archetype) and the Stories bank (a story whose "Use when:" line fits this company's situation). When the company's signals match one -- for example, a founder-led, process-averse company skeptical of the user's function, where the agreed framing positions the function as operating leverage rather than gatekeeping -- thread that angle through **Why This Is a Strong Fit**, **Interview Strategy**, and **Potential Landmines**, keeping whatever nuance the cheat sheet specifies. Don't invent an angle that isn't in the cheat sheet.

## Step 4: Update the tracker

tracker.csv is the single log; a prep session is a touch. Columns, in order:

```
Company,Role,Source,Fit Score,Fit Lane,Status,Date Added,Date Applied,Last Touch,Touch Type,Response,Response Date,Notes
```

Get today's date with `date +%Y-%m-%d`. Pick the target status from the round type Step 0 classified -- don't ask the user again: a recruiter/talent screen means Status=Screen; a hiring-manager, panel, or any later round means Status=Interviewing. Match rows on Company (case-insensitive):

- **If exactly one row exists for this company**: that's the row.
- **If multiple rows exist (several roles tracked for this company)**: match by Role using the JD and round context. If it's still ambiguous which role this interview is for, ask the user which row it belongs to -- never silently update an arbitrary row.
- **On the matched row**: set Last Touch=today, Touch Type=prep, and Status to the target status -- but never regress a later stage. If the row's Status is already further along than the target (e.g. already Interviewing or Offer when prepping another screen), leave Status as it is. Keep every other field.
- **If no row exists**: append one -- Company and Role from what you know, Source=direct, Status=the target status, Date Added=today, Last Touch=today, Touch Type=prep, other fields empty. Flag to the user that this company wasn't tracked yet.

CSV rules: quote any field containing a comma; escape embedded double-quotes by doubling them (RFC 4180). Keep the header row intact and don't disturb other rows.

## Step 5: Report

Summarize:

- Company snapshot (1-2 sentences)
- Who the user is meeting / would report to, and their background
- Top 3 fit points
- Any resume-vs-talking-point gaps to be aware of
- Prior round intel incorporated (if applicable)
- Research gaps / things to ask on the call
- File paths written (the prep doc, plus the saved JD if there was one) and the tracker row updated

After the interview happens, the natural next step is /debrief {company} {round} to write what was learned back into the corpus.
