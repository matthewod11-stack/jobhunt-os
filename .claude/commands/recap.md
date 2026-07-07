---
description: Process wind-down recap - whole-arc retrospective when an interview process ends, closing the learning loop
argument-hint: company name, then optional outcome (e.g. "rejected", "declined-offer", "withdrew")
---

# /recap

You are writing a single whole-arc retrospective for an interview process that has ended -- distinct from the per-round debriefs (those are tactical; this is the journey plus the lessons the user will actually browse later). It also closes the learning loop: durable lessons get promoted to the corpus and to memory, and relationships worth keeping warm get flagged.

All paths are relative to the workspace root (the directory containing CLAUDE.md). If an expected file is missing, say what is missing in one sentence and continue with what you can; never fabricate content to paper over a gap.

**When to run:** the moment a process winds down -- rejection received, offer declined, candidate withdrew, role closed/frozen, or gone-quiet-and-closed. One recap per process, written once it's over. (Often fired right after the final /debrief -- its Step 7 hands off here on terminal outcomes.)

## Preflight: corpus write-back gate (note it, don't stop)

The recap itself does not depend on the corpus being real -- the primary artifact is the recap doc, built from the tracker and whatever prep/debrief docs exist. So this command never hard-stops on example content. But the corpus write-back in Step 4 does depend on it: appending a real lesson to fictional example content would pollute it and get replaced by /setup anyway.

Check now so you can say so up front: if corpus/cheat-sheet.md is missing or empty, or its first line begins with the example-content marker prefix `<!-- Example output` (match on this prefix only, not the full literal string, since the dash character in the marker can vary), the corpus is not the user's real content yet -- either never seeded or still the fictional Jordan Reyes example. Same check for corpus/answer-bundles.md. If either trips, proceed with the full recap but skip the write-back to that file in Step 4, with a note that running /setup first is what makes the corpus loop work.

Exception: corpus/question-trends.md is REAL shared seed data (anonymized interviewer-question frequencies), not persona content. It does not carry the example marker and must never be treated as example content.

## Step 0: Parse arguments

`$ARGUMENTS` is `{company} [outcome]`. Extract:

- **Company name** (required) -- may be multi-word. If the split between company and outcome is ambiguous ("Iron Peak rejected" is clear, but a multi-word remainder may not be), check the candidate splits against tracker.csv Company values and interview-prep/ + applied/ filenames first and take the split that lines up with a known company. If still ambiguous, ask the user rather than guessing.
- **Outcome** (optional) -- what comes after the company: "rejected", "declined-offer", "withdrew", "role-closed", or similar. If omitted, infer it from the tracker row's Status (Rejected, Withdrawn, or Closed already says most of it) or from the latest debrief -- its RISK ASSESSMENT and OPEN QUESTIONS sections, and the tracker Status that debrief set -- and confirm the inference with the user before writing anything. The outcome shapes the whole doc, and once confirmed here it is settled: later steps build on it rather than asking again.

If `$ARGUMENTS` is empty, ask the user for at least the company before doing anything else.

## Step 1: Gather the full arc

**Scope to one role first.** Check tracker.csv for this company's rows before reading any docs. If multiple rows exist (several roles tracked for this company), ask the user which role's process this recap is for, and scope the whole arc to that process. Prep and debrief filenames don't encode the role, so attribute each doc to the chosen process by its dates and content -- and flag any doc you can't attribute confidently rather than folding it into the arc. Step 4's tracker update reuses this choice instead of re-asking.

Then read everything on file for this process:

- Every prep doc and every `{company}-post-call-*` debrief in interview-prep/, plus any outreach notes and saved JDs there -- these are the raw material; the recap aggregates and zooms out from them.
- The tailored resume and any cover letter in applied/.
- The tracker.csv row identified above (role, fit lane, status, dates, notes).
- Relevant memory files (e.g. `feedback_hiring_signal_calibration`) and any corpus promotions made during the process (bullets in corpus/cheat-sheet.md tagged `[promoted from {company}-...]`).

Don't re-interview the user round-by-round -- the debriefs already hold that.

**If little or nothing is on file** -- no prep docs, no debriefs, maybe not even a tracker row (the user never ran the other commands) -- the recap still works: build the arc from the tracker.csv row plus whatever exists, lean a little harder on Step 2's questions (they may need to cover the rough timeline too, but keep the count discipline), and say explicitly in the doc which rounds have no written record.

## Step 2: Confirm only what the docs don't capture

The outcome itself was already confirmed in Step 0 -- do NOT re-ask it here. Ask the user 2-4 targeted things, no more, covering only what Step 0 and the docs didn't get:

- How they're reading the outcome, and the exact rejection/decline language if any (pasting the email text is welcome -- it's source material for the doc).
- Their single biggest takeaway from the process.
- Which relationships are worth keeping warm.
- Anything that changed their read since the last debrief.

Drop any question the docs on file (or Step 0) already answered. Four is the cap; when the record is rich, the right count is two or fewer.

## Step 3: Build the recap doc

Create `interview-prep/{company}-recap.md` using this fixed structure -- honest and scannable, **no spin** (a rejection and an offer-declined both get the same clear-eyed treatment):

1. **Header** -- role / comp / location / stage; **Outcome** (with date); **Window** (applied -> closed).
2. **TL;DR** -- 3-5 lines: the fit, how far it got, how it ended, the one-line lesson.
3. **The arc** -- timeline table: `Date | Stage | With | Format | Gut | Result`. One row per touchpoint (application, outreach, coordination, each conversation, decision). Rounds with no written record get a row built from the user's recollection, flagged as such.
4. **Why it ended here (honest read)** -- separate a *shape / relative-fit decision above the room* from chemistry or quality. Tie to risks the prep docs already flagged. Don't flatter; don't self-flagellate.
5. **What went well (keep doing)** -- frames, stories, questions, prep moves that landed. Reusable next time.
6. **What to improve (-> corpus/memory)** -- and actually promote the durable lessons (calibration misses, recurring risks) in Step 4; note here what was promoted.
7. **Relationships to keep warm** -- name the highest-value one explicitly (a champion, a well-connected recruiter or investor). Note thank-you / feedback follow-ups.
8. **Assets produced** -- link the prep docs, debriefs, saved JDs, the tailored resume, and any cheat-sheet/answer-bundle promotions that outlive this process. Use plain relative markdown links (e.g. `[screen debrief](acme-post-call-1.md)`).
9. **Open threads** -- pending feedback asks, follow-ups, and the net "second-guess or respect the base rate?" call.

Close the doc with a one-line **template reminder** so the structure stays consistent across processes.

**Never overwrite an existing recap.** If `interview-prep/{company}-recap.md` already exists (a process that reopened and then closed again), ask with AskUserQuestion which case this is:

- **Same process, new coda** (e.g. a post-close feedback call changed the read): update the SAME doc by ADDING a clearly dated addendum section (e.g. `## Addendum {date}`). Leave the existing content untouched.
- **Genuinely a second, separate process** with this company: create `interview-prep/{company}-recap-2.md` (bump the number until the filename is free).

## Step 4: Close the learning loop

Three write-backs, each with its own rules:

### Memory promotion

Promote any durable lesson to a `feedback_*` memory file in Claude Code's memory -- guidance framed as **Why** + **How to apply**, not a diary entry. Calibration misses especially (the gut read said one thing, the outcome said another). Memory holds the user's own accumulated guidance, so the example-content gate does not apply here.

### Corpus promotion (gated)

Same discipline as /debrief Step 5: a lesson earns corpus promotion when it would change how the user handles a FUTURE process at a DIFFERENT company.

1. **Check the gate from the preflight.** If corpus/cheat-sheet.md is still example content, skip the promotion with a note to run /setup.
2. **Propose each promotion with AskUserQuestion** -- draft the lesson as 1-3 sentences of directly reusable guidance, show it, and offer: promote as drafted / let the user edit it / skip. On approval, append it as a bullet under the `## Promoted from debriefs` section of corpus/cheat-sheet.md, ending with the tag `[promoted from {company}-recap]` -- lowercase, matching the Step 3 filename without the extension.
3. **If a lesson is an ANSWER that needs a new or updated spine** in corpus/answer-bundles.md, offer that too, using its four-part spine: Principle, What I've done, What I'd do now, Stop line. Show the new or revised bundle for approval before writing, and apply the same example-content gate to answer-bundles.md.

If no reusable lesson surfaced, say so in one line and move on -- don't manufacture one.

### Tracker update

tracker.csv is the single log; closing a process is its final touch. Columns, in order:

```
Company,Role,Source,Fit Score,Fit Lane,Status,Date Added,Date Applied,Last Touch,Touch Type,Response,Response Date,Notes
```

Get today's date with `date +%Y-%m-%d`. Match rows on Company (case-insensitive):

- **If exactly one row exists for this company**: that's the row.
- **If multiple rows exist (several roles tracked for this company)**: use the role the user chose in Step 1 -- don't re-ask. If Step 1 somehow left it unsettled, ask now; never silently update an arbitrary row.
- **On the matched row**: set Status per the outcome -- rejection means Rejected; the user declined the offer or withdrew means Withdrawn; role frozen/closed or gone-quiet-and-closed means Closed. Set Response=a short phrase (e.g. "rejected after onsite"), Response Date=the date the outcome landed (today if that's when the user learned it), Last Touch=today, Touch Type=recap, and add the one-line outcome + lesson to Notes. Keep every other field. Terminal statuses always apply -- ending a process is an outcome, not a regression.
- **If no row exists**: append one -- Company and Role from what you know, Source=direct, the terminal Status, Date Added=today, Last Touch=today, Touch Type=recap, Response and Response Date per above, Notes=the one-line outcome. Flag to the user that this company wasn't tracked yet.

CSV rules: quote any field containing a comma; escape embedded double-quotes by doubling them (RFC 4180). Keep the header row intact and don't disturb other rows.

## Step 5: Report

- One-line outcome.
- Top 1-3 lessons (and where each was promoted -- memory, cheat sheet, answer bundles -- or why nothing was).
- Relationships to keep warm.
- File paths written (the recap doc, plus any corpus files touched) and the tracker row updated.

---

**Filename convention:** `{company}-recap.md` -- one per process, in interview-prep/. If the workspace still carries the example persona's interview docs, `interview-prep/solara-recap.md` shows a finished recap; if it is not present, skip this -- nothing in this command depends on that file existing.
