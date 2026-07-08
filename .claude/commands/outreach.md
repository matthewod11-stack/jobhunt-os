---
description: Draft LinkedIn-scoped outreach for a company or person - connection note, short DM, or warm follow-up
argument-hint: company name, then optional person (e.g. "Acme" or "Acme Jane Rivera")
---

# /outreach

You are drafting LinkedIn-scoped outreach the user will send themselves: a 300-character connection note, a short DM, or a warm follow-up. Nothing gets sent by this command; the deliverable is copy-paste-ready text in the user's voice, saved for the record and logged to the tracker.

All paths are relative to the workspace root (the directory containing CLAUDE.md). If an expected file is missing, say what is missing in one sentence and continue with what you can; never fabricate content to paper over a gap.

This is where /scout's handoff lands: its report flags high-fit companies with no open role as "-> /outreach {company}". A great company with no posted role is an outreach target, not a miss.

## Preflight: example-content guard

Outreach drafted in a fictional persona's voice is worthless, so this command hard-stops on example content (same logic /setup, /apply, and /prep use):

- If profile/voice.md or corpus/cheat-sheet.md is missing or empty, STOP and tell the user to run /setup first; there is no voice or story bank to draft from.
- If the first line of profile/voice.md begins with the example-content marker prefix `<!-- Example output` (match on this prefix only, not the full literal string, since the dash character in the marker can vary), it is still the fictional Jordan Reyes example. Same check for corpus/cheat-sheet.md.
- If profile/fit-profile.json still carries the example persona (the `name` field is "Jordan Reyes"), the profile has not been replaced either.

If any check trips, STOP and tell the user to run /setup first. Do not continue past this point.

## Step 1: Parse arguments and gather context

`$ARGUMENTS` is `{company} [person]`. Extract:

- **Company name** (required) -- may be multi-word. If the split between company and person is ambiguous ("Iron Peak Casey Lee" could be company "Iron Peak" + person "Casey Lee" or company "Iron" + a three-word remainder), check the candidate splits against tracker.csv Company values and interview-prep/ + applied/ filenames first and take the split that lines up with a known company. If it is a first-ever contact and the split is still ambiguous, ask the user rather than guessing.
- **Person** (optional) -- what comes after the company: a name ("Jane Rivera") or a role ("head of talent"). Absent means company-level outreach.

If `$ARGUMENTS` is empty, ask the user for at least the company before doing anything else.

Then gather context:

1. tracker.csv rows for this company (case-insensitive match on Company). /scout often creates the row (Status=Lead) before this command ever runs. Note Status, Last Touch, Touch Type, and Notes; Step 3 and Step 5 both depend on them.
2. interview-prep/ for an existing `{company}-outreach.md`, prep docs, or debriefs. Prior contact changes what you write; a warm follow-up draws directly on it.
3. profile/voice.md -- the voice source of truth. Its banned words and sentence rules apply to every draft; short-form gets zero dry asides unless voice.md says otherwise.
4. profile/fit-profile.json -- lanes and positioning, plus the user's `name`.
5. corpus/cheat-sheet.md -- stories bank and framing rules. The fit clause in every draft comes from here, not from ad hoc phrasing.

## Step 2: Light research

Run a reduced-depth version of /prep's research checklist: recent news, funding, or product moves for the company, plus the target person's role and background if a person was named. Cap it explicitly: this is a 300-char note, not a prep doc - 3-4 searches max. If a prior prep doc or the tracker Notes already carry the company context, reuse it and spend the budget on the person instead (or skip searching entirely).

Two hard rules:

- **No fabrication.** The ONE specific thing each draft names must come from an actual research finding or a doc on file. If research turned up nothing concrete, say so and ask the user for a hook rather than inventing one.
- **Person unfindable.** If the searches cannot identify the named person or their role, say so plainly and draft company-level notes instead. Address a draft to a plausible role (e.g. "founder") only after the user confirms who they are targeting.
- **Person ambiguous.** If research turns up two or more people with that name at the company, disambiguate by role or title against who the user is trying to reach; if it is still unclear which one they mean, ask the user. Never draft to a guessed identity.

## Step 3: Pick the format

Ask with AskUserQuestion which format to draft, offering these literal options -- "Connection note" (the default and first option), "InMail / DM", and "Warm follow-up":

- **Connection note** -- LinkedIn's 300-character hard limit on invitation notes. Counted, not estimated (Step 5).
- **InMail / DM** -- 3-5 sentences, for messaging an existing connection or sending an InMail.
- **Warm follow-up** -- references the prior touch on record: the tracker row's Last Touch, Touch Type, and Notes, plus any prior section in `{company}-outreach.md`.

Pre-filter before asking: warm follow-up is only eligible when a prior touch is on record (the tracker row has a Last Touch, or a prior outreach doc exists). If neither exists, omit that option (or mark it unavailable, with the one-line reason) rather than offering it and redirecting after the pick.

Person-scoping for warm follow-ups: tracker touches are company-level, not person-level. If the prior touch was to a DIFFERENT person than the current target (check the prior outreach doc's headings), do not present it as shared history with the new target. Either reference it accurately ("I reached out to your colleague {X} about...") or ask the user how to frame it.

## Step 4: Drafting rules

Every draft follows these rules:

- Name ONE specific thing about the company (funding, product, post).
- State fit in one clause drawn from the cheat-sheet's most relevant story or hook.
- Ask small (a conversation, not a job).
- Write in the user's voice per profile/voice.md.
- Banned: "I'm passionate about", resume dumps, attachments, flattery openers.

The universal natural-voice rules from /apply hold here too, compressed for short-form: don't over-specify (one specific name where it carries weight, not a tool list), don't over-quantify (at most one number in something this short), vary sentence structure, no buzzword saturation, no dash overuse, specificity where it counts.

## Step 5: Draft, confirm, save, track

### Draft and confirm

Write 2-3 candidate drafts in the chosen format. The candidates must differ substantively, not be three rewordings of the same sentence: vary the hook (funding vs product vs a recent post), the ask size (a question vs a conversation), or the opening structure. Label each with what varies (e.g. "hook: Series B", "hook: product launch") so the user can choose meaningfully.

For connection notes, count each candidate's characters and show the count next to it ("247/300"). Count safely: never interpolate the note into a shell command line -- an apostrophe (near-certain in casual voice: "I'd", "there's") breaks the quoting and printf then repeats its format string, silently under- or over-counting. Instead, write the candidate to a scratch file with no trailing newline and run `wc -c < {file}` (that counts bytes; use `wc -m` instead if the note contains any non-ASCII characters). If a draft runs over 300, cut it BEFORE presenting; never show an over-limit candidate. The user picks one or edits; revise (and re-count) until they approve.

### Save the chosen set

Save the approved draft(s) to `interview-prep/{company}-outreach.md`, each under a heading carrying the date, format, and target (e.g. `## 2026-07-08 - connection note - Jane Rivera`). If the file already exists from a prior run, never overwrite it: append the new dated section below the existing content (the same never-overwrite, append-a-dated-section principle /prep and /recap apply to their docs; the heading shape above is this command's own). The file is the record of what was said to whom, so the next touch never repeats itself.

### Ask whether it was sent

Picking a draft is not sending it. Ask the user: did you send this (or are you sending it right now)? The answer decides the tracker update.

### Update the tracker

tracker.csv is the single log; a SENT outreach is a touch, a saved draft is not. Columns, in order:

```
Company,Role,Source,Fit Score,Fit Lane,Status,Date Added,Date Applied,Last Touch,Touch Type,Response,Response Date,Notes
```

Get today's date with `date +%Y-%m-%d`. Match rows on Company (case-insensitive):

- **If exactly one row exists for this company**: that's the row.
- **If multiple rows exist (several roles tracked)**: ask the user which role or process this outreach belongs to; never silently update an arbitrary row.
- **On the matched row, if the user SENT it**: set Last Touch=today, Touch Type=the format (connection-note, dm, or follow-up), Status=Outreach Sent -- but never regress a later stage. If Status is already further along (Applied, Screen, Interviewing, Offer), keep it; only Last Touch and Touch Type change. If Status is terminal (Rejected, Withdrawn, Closed), ask whether this outreach reopens the process (then set Outreach Sent) or is just keeping a relationship warm (then keep the terminal Status and update only Last Touch and Touch Type).
- **On the matched row, if NOT sent**: leave the row untouched except a Notes hint (append "outreach drafted {date}, not sent" to Notes). No Status, Last Touch, or Touch Type change.
- **If no row exists**: append one -- Company from Step 1, Role empty, Source=outreach, Fit Score and Fit Lane empty, Date Added=today. If sent: Status=Outreach Sent, Last Touch=today, Touch Type=the format. If not sent: Status=Lead, Notes="outreach drafted {date}, not sent". Flag to the user that this company wasn't tracked yet.

CSV rules: quote any field containing a comma; escape embedded double-quotes by doubling them (RFC 4180). Keep the header row intact and don't disturb other rows.

## Step 6: Report

Close with a brief report:

- The approved draft(s), with char counts for connection notes
- File path written, and whether it was a new file or a dated addendum
- The tracker row written or updated, shown as a single line (or "tracker untouched: draft saved, not sent")
- The natural next step: when a reply lands, log it (Response + Response Date in the tracker); a booked call means /prep {company} {person}; a role opening up means /apply {jd-url}.
