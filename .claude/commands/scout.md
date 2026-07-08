---
description: Source new opportunities - funding news + VC portfolios, scored against your fit profile. Companies, not job boards.
argument-hint: optional limit and tier, e.g. "40", "tier 2", or "40 tier 1-2"
---

# /scout

You are sourcing companies worth the user's time: recent raises from funding news, plus portfolio walks of the VC firms in docs/vc-registry.md, each scored against profile/fit-profile.json. The unit of discovery is the COMPANY, not the job posting. A great company with no posted role is an outreach target, not a miss.

All paths are relative to the workspace root (the directory containing CLAUDE.md). If an expected file is missing, say what is missing in one sentence and continue with what you can; never fabricate content to paper over a gap. (For the full sourcing methodology behind this command, see docs/SOURCING-PLAYBOOK.md.)

## Step 0: Preflight, arguments, and limits

**Profile guard.** Read profile/fit-profile.json. If it is missing, unparseable, or still carries the example persona (the `name` field is "Jordan Reyes"), STOP and tell the user to run /setup first. Scouting against the fictional profile would source companies for a person who does not exist.

From the profile, load: `lanes` (a keyed map, usually 2-3 entries; every user's lanes are different), `locations`, `stages`, `sectors`, `comp_floor`, `avoid`, `notes`. **Everything downstream keys off the lanes actually in this file. Never hardcode lane names.**

**Parse `$ARGUMENTS` leniently:**

- A bare number = max new companies for this run, N (default 25)
- `tier X` = scan tiers 1 through X (widening); `tier X-Y` = exactly tiers X through Y; default is tier 1 only
- Both may appear together in any order ("40 tier 1-2"). Anything you cannot parse: ask rather than guess.

**State the limits before doing any work**, in one or two lines: "This run: up to {N} new companies, tier-{T} VCs. Tier range is the main cost lever (tier 1 is about 5 portfolio pages, tier 1-3 closer to 19); every run also pays a fixed floor of sector searches plus up to 10 careers fetches, and N mainly caps how many companies get scored and written." Keep a running count of discoveries against N; stop discovering when you reach the cap, not after; if strong leads remain beyond it, ask before exceeding.

## Step 1: Discover - funding news

Web-search recent raises (last 30 days) in the profile's sectors and locations. Build several queries and run them in parallel, for example:

- "{sector} startup seed series A funding" + the current month and year, per sector
- "startup raised funding {sector} {location}" for each profile location
- "recently funded {sector} startups"

From the results, extract per hit: company name, round, amount, lead investors, a one-line description of what they do, and location if stated. Only include companies the sources actually name with funding news; never fabricate or pad from general knowledge. If a sector yields nothing, say so and move on. Zero hits across all queries is a valid (reportable) outcome, not a failure to hide.

## Step 2: Discover - VC portfolios

Read the table in docs/vc-registry.md (columns: | Firm | Tier | Portfolio URL | Blog/News URL | Focus |). If the file is missing or the table cannot be parsed, skip this step and say why in the report; funding-news leads alone still make a valid run.

Select the firms in the tiers in scope, prioritizing firms whose Focus overlaps the profile's sectors. For each firm, WebFetch the Portfolio URL and extract companies that plausibly match the profile's sectors, with whatever detail the page carries (name, one-liner, sector, stage if shown).

**Skip-and-report, never block:** portfolio pages rot and many are JS-heavy shells that return little text. If a fetch fails or returns thin content, note the firm, optionally try its Blog/News URL as a fallback source of recent investments, and move on to the next firm. Tally every skipped page for the final counts. One bad page must never stall the run.

The cap applies mid-page, not just between firms: on a large portfolio page, stop extracting the moment combined discoveries reach N; a 500-company page must not blow past the cap in one pass. Once N is reached, stop walking firms and score what you have.

## Step 3: Dedupe against the tracker

Read tracker.csv and collect the Company column. Normalize both sides before comparing: lowercase, collapse whitespace, drop punctuation, strip trailing suffixes. Suffixes come in two classes that behave differently: generic legal suffixes (Inc, Inc., LLC, HQ, Co) carry no identity, while meaningful tokens (AI, Labs) can be the whole difference between two companies.

Scraped names come in mangled: a portfolio grid can glue a company's name to an adjacent word (a name concatenated with a word like "music" is a real failure mode). So match generously, but only drop silently when the match is safe:

- A raw exact normalized match, or one that becomes exact after stripping only generic legal suffixes = duplicate; drop it
- A match that only appears after stripping a meaningful token (discovered "Sierra AI" vs a tracked "Sierra") = candidate duplicate; confirm with the user before dropping. Never drop these silently: discarding a real new lead is invisible to the user, which makes it the worst failure this step can have
- A normalized tracker name appearing as a prefix or substring of a scraped name (or the reverse) = candidate duplicate; confirm ambiguous cases with the user rather than silently dropping or double-adding
- Also dedupe within the discovered batch itself (the same raise shows up in news AND a portfolio; keep one, remember both sources)

Count everything dropped here for the report.

## Step 4: Score against the fit profile

**Load past corrections first.** If corpus/cheat-sheet.md exists and its first line does not begin with the example-content marker prefix `<!-- Example output` (prefix match only; the dash character in the marker can vary), read its "Scout scoring corrections" section, if present. Each entry is a real user decision that overrode a past score. Carry them into your scoring as few-shot calibration examples: when a new company resembles a corrected one, lean toward the user's corrected score, not your instinct.

**Avoid list comes first and is absolute.** If a company matches any entry in the profile's `avoid` list (judge by sector, business model, and description, not literal string match), it scores **0 on ALL lanes** and is flagged avoid-matched with the specific entry it hit. Avoid-matched companies are SHOWN in the report, not hidden; the user should see what was excluded and why. They skip Step 5.

For every other company, score each lane in the profile independently on a 0-3 scale:

- **3 = a role-shaped hole you could name**: the company's stage, motion, and visible gaps make it obvious what this lane's hire would own
- **2 = clear adjacency**: the lane maps onto real needs, even if the exact role is not obvious
- **1 = plausible stretch**: some path in, but it takes squinting
- **0 = no path**: nothing about this company calls for this lane

Rules of thumb:

- Weight what is actually known (round, investors, one-liner, sector, location) heavily; inferred signals are supplementary
- Stage outside the profile's `stages`, or location incompatible with `locations`, is not an automatic zero (only the avoid list hard-zeros) but pushes scores down and belongs in the assessment
- Assign a confidence per company: **high** = one-liner, sector, stage, and investors all known; **medium** = at least two of those; **low** = little beyond a name, the score is speculative
- `comp_floor` shapes confidence and the assessment, never the lane score: when available comp signals (a posted salary range, stage norms for the sector) clearly undercut the floor, say so in the one-sentence assessment and drop confidence a notch; do not zero a lane over inferred pay
- Write a one-sentence assessment per company: why the top lane fits, or what kills it

Headline **Fit Score** = the highest lane score. **Fit Lane** = that lane's key (empty when the headline is 0).

## Step 5: Careers check (top 10)

Take the 10 highest-scoring non-avoid companies. For each, locate and WebFetch the careers page (try the company site's /careers or /jobs path; fall back to a quick web search). Classify every open role against the profile's lanes: tag each with the best-fitting lane key, or `other` when none fits. If the page cannot be found or will not load, mark the company "careers page not found" and keep it in the run; that is a data gap, not a disqualifier.

A high-fit company with NO open role is a LEAD, not a dead end -- flag it for /outreach.

## Step 6: Write to the tracker and report

**Read tracker.csv fresh right before writing** (the user may have edited it since Step 3) and re-check today's additions against that fresh copy so a concurrent manual edit is never clobbered or duplicated. Then append one row per new company. Columns, in order:

```
Company,Role,Source,Fit Score,Fit Lane,Status,Date Added,Date Applied,Last Touch,Touch Type,Response,Response Date,Notes
```

Get today's date with `date +%Y-%m-%d`. Per row:

- **Company** = the cleaned company name
- **Role** = the best lane-fit open role title from Step 5 if one was found, else empty
- **Source** = `scout-funding-news` or `scout-vc-portfolio` (whichever surfaced it first)
- **Fit Score** = the headline 0-3; **Fit Lane** = the lane key (empty at 0)
- **Status** = Lead; **Date Added** = today; all other date/response fields empty
- **Notes** = the one-liner plus round and amount when known; for avoid-matched rows, "matches avoid list: {entry}" (avoid-matched companies ARE written, at score 0, so future runs dedupe against them instead of rediscovering them)

CSV rules: quote any field containing a comma; escape embedded double-quotes by doubling them (RFC 4180). Keep the header row intact and do not disturb existing rows.

**Then output the ranked leads report:**

1. **Top matches with open roles**: company, score + lane, confidence, one-liner, the lane-fit role title (with link if you have one)
2. **No role yet - outreach candidates**: high-fit companies with no lane-fit opening (including "careers page not found" cases), one per line, each ending "-> /outreach {company}"
3. **The long tail**: everything else added, one line each (name, score, lane, one-liner). Say plainly that role presence is only KNOWN for the top-10 careers-checked companies; a long-tail company with no role listed is unchecked, not role-less
4. **Excluded by avoid list**: name + the avoid entry it matched
5. **Counts**: found {X} / duplicates dropped {Y} / added {Z} / pages skipped {W}, naming the firms whose pages failed

If found is 0, or everything deduped away and nothing was added, say so plainly and suggest a concrete next move: widen the tier range ("/scout tier 1-2"), re-run in a week when fresh raises have landed, or revisit fit-profile.json if the sectors are cutting too narrow.

## Step 7: Correction hook

Close with: "Disagree with a score? Tell me now -- corrections are saved and improve future runs."

When the user corrects a score:

1. Append it to the "Scout scoring corrections" section of corpus/cheat-sheet.md; create the section (a `## Scout scoring corrections` heading) at the end of the file if it does not exist. Write it as a compact few-shot example, company facts first, then the verdict:

   ```
   - {Company} ({sector}, {stage}, {one-liner}): scored {lane} {old}, user corrected to {new}. Reason: {user's reason}. Score similar profiles {higher|lower}.
   ```

2. Update that company's tracker row: set Fit Score and Fit Lane to the corrected values (a scoring fix is not a touch; leave Last Touch alone).
3. Future runs read these entries in Step 4. That is the loop working: every correction makes the next scout smarter.
