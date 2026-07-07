---
description: Post-interview guided debrief - extract insights from a transcript or recollections, write lessons back to the corpus
argument-hint: company name, then the round (e.g. "recruiter", "round-2", or an interviewer name)
---

# /debrief

You are processing an interview that just happened into a structured debrief doc with actionable intel for the next round, and promoting anything reusable back into the corpus so the next prep starts smarter.

All paths are relative to the workspace root (the directory containing CLAUDE.md). If an expected file is missing, say what is missing in one sentence and continue with what you can; never fabricate content to paper over a gap.

## Preflight: corpus write-back gate (note it, don't stop)

Unlike /prep and /apply, the debrief itself does not depend on the corpus being real -- the primary artifact is the debrief doc, built from what actually happened on the call. So this command never hard-stops on example content. But the corpus write-back step (Step 5) does depend on it: appending a real lesson to fictional example content would pollute it and get replaced by /setup anyway.

Check now so you can say so up front: if the first line of corpus/cheat-sheet.md begins with the example-content marker prefix `<!-- Example output` (match on this prefix only, not the full literal string, since the dash character in the marker can vary), it is still the fictional Jordan Reyes example. Same check for corpus/answer-bundles.md. If either trips, proceed with the full debrief but skip the write-back to that file in Step 5, with a note that running /setup first is what makes the corpus loop work.

Exception: corpus/question-trends.md is REAL shared seed data (anonymized interviewer-question frequencies), not persona content. It does not carry the example marker and must never be treated as example content.

## Step 0: Parse arguments

`$ARGUMENTS` is `{company} {round}`. Extract:

- **Company name** (required) -- may be multi-word. If the split between company and round is ambiguous ("Iron Peak recruiter" is clear, but "Iron Peak Casey Lee" could be company "Iron Peak" + interviewer "Casey Lee" or something else), check the candidate splits against tracker.csv Company values and interview-prep/ + applied/ filenames first and take the split that lines up with a known company. If still ambiguous, ask the user rather than guessing.
- **Round identifier** (expected) -- what comes after the company: "recruiter", "round-2", a panel label, or an interviewer name.

If `$ARGUMENTS` is empty, ask the user for at least the company before doing anything else. If only a company is given, infer the round from the docs (a prep doc for this company with no matching debrief yet usually identifies the call), and confirm with the user if more than one candidate fits.

## Step 1: Get the source material

Most people don't have clean transcripts as the interviewee. The debrief always includes a guided Q&A conversation, whether or not a transcript is available. The prep doc provides the scaffolding -- you know what was planned, so you ask what actually happened.

First, gather prior context (Step 2 below) so you have the prep doc loaded. Then ask the user for input:

1. **Ask for source material first.** Transcript file path, pasted text, or "just ask me." Accept whatever the user provides.
2. **If a transcript is provided**, read it and extract what you can. Then proceed to the guided questions below to fill gaps, clarify speaker attribution, and get the user's subjective reads (chemistry, what landed, gut feel) that no transcript captures.
3. **If no transcript**, go straight to guided questions.

### Guided debrief questions (always run, even with a transcript)

Read the prep doc first, then ask these in 1-2 rounds (not all at once -- pick the 4-6 most relevant). If you already have a transcript, skip questions you can confidently answer from it and focus on gaps + subjective reads.

**Round 1 (big picture):**

- How did it go? Gut read -- 1 to 10.
- What was the vibe? Did it click?
- What did they tell you about next steps or timeline?
- Anything surprise you -- stuff that wasn't in the prep?

**Round 2 (prep doc cross-reference -- pick based on what the prep flagged):**

- [If prep flagged specific stories to tell] Which stories did you use? How did they react?
- [If prep flagged landmines] Did [specific landmine] come up? How did you handle it?
- [If prep flagged questions to ask] What did you learn when you asked about [topic]?
- [If prep flagged a specific dynamic] How did the [dynamic the prep predicted] actually play out?
- What did they reveal about the role/team/company that we didn't know?
- What do you wish you'd said differently?

**If a transcript was provided, add these:**

- [Quote ambiguous passage] Who said this -- you or them?
- [If names are garbled] Just to confirm: the transcript's "Jane Riviera" is Jane Rivera, and "Acme Labs" is Acme AI? (verify against known names from the prep doc, tracker, and prior debriefs)
- The transcript shows [X] -- is that what actually happened, or is the transcription off?

After the user's answers, if there are obvious gaps in the debrief sections (new intel, what landed, risk), ask 1-2 targeted follow-ups. Then proceed to building the doc.

### Transcript quality notes

Auto-transcripts (Otter, Grain, etc.) from calls the user doesn't control will typically have:

- No speaker labels -- reconstruct from context + prep doc
- Name garbling -- cross-reference against known names from prior docs
- Blended answers -- speakers' words running together at turn boundaries
- Filler and false starts mixed with real content

Use the guided Q&A answers as the authoritative source. Use the transcript to fill in details the user may have forgotten (exact phrasing, topics covered, sequence of conversation). Flag low-confidence reconstructions in the debrief rather than guessing.

## Step 2: Gather prior context

1. Read all existing prep and debrief docs for this company from interview-prep/
2. Read the submitted resume for this company from applied/, if one exists
3. Read this company's row in tracker.csv (role, fit lane, status, dates, notes)
4. Note what the pre-call prep predicted vs. what actually happened

## Step 3: Build the debrief doc

Create `interview-prep/{company}-post-call-{N}.md`, where N is the round number. Determine N by listing the existing `interview-prep/{company}-post-call-*.md` files: N is one more than the highest existing number (1 if none exist). **Never overwrite an existing debrief** -- if the target filename somehow already exists, bump N until it doesn't. Prior debriefs are the record; new rounds get new files.

### Required sections

#### CALL SUMMARY

- **Interviewer:** Name, title, background details revealed during the call
- **Format:** Duration, structure (who talked when, ratio), overall vibe
- **Chemistry:** Honest read -- did it click? Signs of enthusiasm or hesitation from their side
- **Next steps:** What they said would happen next, timeline given

#### NEW INTEL

Use a table where possible. Compare pre-call research to what was actually said:

| Topic | Pre-call estimate | Actual (from call) |
|-------|------------------|-------------------|

Cover:

- Company numbers (headcount, growth targets, team size)
- Product/business updates not in public research
- Role scope clarifications (is it what we thought?)
- Team structure, reporting, who else is on the team the role sits in
- Culture and work style signals
- Compensation signals
- Process details (how many rounds, who's next, timeline)

#### WHAT LANDED

- Which talking points or stories got a visible reaction?
- What questions did the interviewer lean into or ask follow-ups on?
- Any moments where the user clearly differentiated themselves?

#### WHAT DIDN'T LAND (or wasn't tested)

- Stories or points that fell flat or weren't relevant
- Topics that never came up that the prep doc flagged
- Moments of hesitation or misalignment

#### POSITIONING ADJUSTMENTS

Based on what was learned, how should the user adjust their positioning for the next round?

- New angles to emphasize
- Things to stop saying or de-emphasize
- Specific interviewer preferences or values revealed

#### OPEN QUESTIONS

Things flagged but not answered, or new questions raised by the conversation. These feed directly into the next round's prep doc.

#### RISK ASSESSMENT

Honest read:

- What could kill this? (comp expectations, location, culture fit, competing candidates)
- What's the strongest signal in the user's favor?
- Probability read (gut feel, not science)

## Step 4: Update the tracker

tracker.csv is the single log; a completed interview is a touch. Columns, in order:

```
Company,Role,Source,Fit Score,Fit Lane,Status,Date Added,Date Applied,Last Touch,Touch Type,Response,Response Date,Notes
```

Get today's date with `date +%Y-%m-%d`. Pick the target status from what the debrief established:

- **Terminal outcome revealed on or after the call** (rejection, declined offer, withdrawal, role frozen/closed): Status=Rejected, Withdrawn, or Closed as appropriate; Response=a short phrase (e.g. "rejected after screen"); Response Date=the date it happened (today if that's when the user learned it). Terminal statuses always apply -- ending a process is an outcome, not a regression.
- **Offer extended:** Status=Offer.
- **Process still alive:** a recruiter/talent screen debrief means Status=Screen; a hiring-manager, panel, or any later round means Status=Interviewing -- but never regress a later stage. If the row's Status is already further along than the target (e.g. already Interviewing when debriefing a screen that happened out of order), leave Status as it is.

Match rows on Company (case-insensitive):

- **If exactly one row exists for this company**: that's the row.
- **If multiple rows exist (several roles tracked for this company)**: match by Role using the prep doc and round context. If it's still ambiguous which role this interview was for, ask the user which row it belongs to -- never silently update an arbitrary row.
- **On the matched row**: set Last Touch=today, Touch Type=debrief, Status per the rules above, and add a short phrase to Notes with the round result and next step (e.g. "screen done, HM round next week"). Keep every other field.
- **If no row exists**: append one -- Company and Role from what you know, Source=direct, Status=the target status, Date Added=today, Last Touch=today, Touch Type=debrief, other fields empty. Flag to the user that this company wasn't tracked yet.

CSV rules: quote any field containing a comma; escape embedded double-quotes by doubling them (RFC 4180). Keep the header row intact and don't disturb other rows.

## Step 5: Corpus write-back (how the system compounds)

Before reporting, ask yourself: did this debrief surface a REUSABLE lesson -- a story that landed, a framing that flopped, an answer that needs a new spine? Not every round produces one; a lesson earns promotion when it would change how the user handles a FUTURE interview at a DIFFERENT company, not just the next round here (round-specific intel already lives in the debrief doc).

If yes:

1. **Check the gate from the preflight.** If corpus/cheat-sheet.md is still example content, skip the promotion with a note to run /setup, and continue to Step 6.
2. **Propose the promotion with AskUserQuestion.** Draft the lesson as 1-3 sentences of directly reusable guidance (what to do, not what happened), show it, and offer: promote as drafted / let the user edit it / skip. Multiple lessons from one debrief are fine -- propose each.
3. **On approval**, append each lesson as a bullet to corpus/cheat-sheet.md under the `## Promoted from debriefs` section, ending with the tag `[promoted from {company}-post-call-{N}]` -- lowercase, matching the Step 3 debrief filename without the extension. If a promoted lesson supersedes something elsewhere in the cheat sheet (a stories-bank framing, a framing rule), say so inside the bullet rather than editing the older entry.
4. **If the lesson is an ANSWER that needs a new or updated spine** -- a question the user fumbled, or a bundle whose telling improved on the call -- offer to also add or update the bundle in corpus/answer-bundles.md, using its four-part spine: Principle, What I've done, What I'd do now, Stop line. New questions get a new `##` section; an improved telling revises its existing bundle in place (that file is designed to grow this way). Show the new or revised bundle for approval before writing, and apply the same example-content gate to answer-bundles.md.

If no reusable lesson surfaced, say so in one line and move on -- don't manufacture one.

## Step 6: Report

Summarize:

- One-line call result (e.g., "Strong recruiter screen, moving to hiring manager")
- Top 3 new intel points
- Biggest positioning adjustment for next round
- Risk/signal read
- What was promoted to the corpus (or why nothing was)
- File paths written (the debrief doc, plus corpus files touched) and the tracker row updated

If there's a clear next interviewer or round, flag it: "Ready for `/prep {company} {next-interviewer}`."

## Step 7: If the process just ended, hand off to /recap

If this debrief records a **terminal outcome** -- rejection, declined offer, withdrawal, or role frozen/closed -- don't stop at the round-level debrief. Offer to run **`/recap {company}`**: the whole-arc retrospective that zooms out from every debrief, captures durable lessons to the corpus (calibration misses especially), and flags relationships to keep warm. This is the "write one as each process winds down" habit.

If the process is still alive (advancing to a next round), skip this -- /recap is only for the wind-down.
