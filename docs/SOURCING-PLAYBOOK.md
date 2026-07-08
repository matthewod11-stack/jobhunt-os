# The Sourcing Playbook

This is the methodology behind [`/scout`](../.claude/commands/scout.md). The command is the tool; this doc is the reasoning. Read it once so you know why scout does what it does, and again when you want to tune how you source.

## 1. The thesis: source companies, not job postings

Job boards are where everyone competes. By the time a role is posted on a board, it has a recruiter, a pipeline, and several hundred applicants who all found it the same way you did. Your resume enters as one row in an ATS, scored by keyword overlap against people who optimized for exactly that.

The alternative is to find the company before the posting exists -- or without one ever existing. Two facts make this work:

1. **Funding creates hiring.** A company that just closed a round has money earmarked for headcount and a board expecting growth. The roles are coming; most are not posted yet. If you show up while the hiring plan is still a spreadsheet, you are not competing with a pipeline -- you are potentially shaping the role.
2. **Hiring precedes posting.** Plenty of startup hires never touch a job board at all. The founder asks their investors, their team, and their inbound before they ask the internet. A well-timed, well-aimed note from someone who obviously fits lands in that window.

So the unit of discovery is the COMPANY, not the job posting. You are building a list of companies where your specific shape of experience would obviously help, ranked by how obvious that is. Whether they have posted a role yet is a secondary fact about timing, not a filter on whether they belong on the list.

This is a head start, not a guarantee. Most leads go nowhere -- that is fine and expected. The point is that the leads that DO go somewhere came from a channel where you were one of five candidates instead of one of five hundred.

## 2. Channels

Scout draws from two channels. They overlap on purpose: a fresh raise often shows up in the news AND on the lead investor's portfolio page, and seeing it twice is itself a signal.

### Funding news

Search recent raises -- roughly the last 30 days -- in your sectors and locations. Older than that and the post-raise hiring window is already closing; the recruiter has been hired and the pipeline is forming.

What to extract per hit: company name, round, amount, lead investors, a one-line description of what they do, and location if stated. The round and investors count for more than the amount: a seed round led by a firm you respect says more about the company's next twelve months than the dollar figure does.

Only count companies that a source actually names with funding news. General "hot startups" listicles are noise; a dated raise announcement is signal.

### VC portfolios

Good investors have already done a screening pass for you. Walking a top firm's portfolio page is borrowing their diligence: every company on it cleared a bar that most companies do not.

The firms live in [`vc-registry.md`](vc-registry.md), tiered by fund size and stage focus. Tier 1 (mega funds) is the default scan -- about 5 portfolio pages. Widening to tier 2 or 3 adds elite early-stage and specialized firms, at the cost of more pages and more API usage. The tier range is the main cost lever on any scout run.

The registry ships Bay-Area-weighted. It is meant to be edited: add the firms that dominate your geography and sector, delete the ones that are irrelevant to you. Portfolio URLs rot over time; the registry file is one table row per firm precisely so fixing a dead link is a one-line change.

## 3. The scoring rubric

Every discovered company gets scored against your `profile/fit-profile.json`. The profile defines your lanes -- the 2-3 role archetypes you are actually pursuing. Each lane is scored independently on a 0-3 scale:

- **3 = a role-shaped hole you could name**: the company's stage, motion, and visible gaps make it obvious what this lane's hire would own
- **2 = clear adjacency**: the lane maps onto real needs, even if the exact role is not obvious
- **1 = plausible stretch**: some path in, but it takes squinting
- **0 = no path**: nothing about this company calls for this lane

The headline Fit Score is the highest lane score, and the Fit Lane is whichever lane earned it. Scoring lanes independently is what lets one scout run serve multiple job-search theses at once -- a company can be a 3 on one lane and a 0 on another, and both facts are useful.

**The avoid list comes first and is absolute.** If a company matches any entry in your profile's `avoid` list -- judged by sector, business model, and description, not literal string match -- it scores 0 on ALL lanes and is flagged with the specific entry it hit. Avoid-matched companies are shown in the report, not hidden: you should always be able to see what was excluded and why, and correct the profile if the avoid list is cutting too wide. They are also written to the tracker at score 0, so future runs dedupe against them instead of rediscovering them.

**Confidence is separate from score.** Each company gets a confidence tag by information completeness: **high** when the one-liner, sector, stage, and investors are all known; **medium** with at least two of those; **low** when there is little beyond a name and the score is speculative. A low-confidence 3 is a research prompt, not a conclusion.

**`comp_floor` shapes confidence and the assessment, never the lane score.** When available comp signals -- a posted salary range, stage norms for the sector -- clearly undercut your floor, the assessment says so and confidence drops a notch. But no lane gets zeroed over inferred pay; only the avoid list hard-zeros.

**One sentence per company.** Every scored company gets a one-sentence assessment: why the top lane fits, or what kills it. The discipline of one sentence is the point -- if the fit cannot be stated in a sentence, it is probably a 1 wearing a 2's score.

## 4. The feedback loop

Scout's first run scores with generic judgment. Its tenth run scores with yours.

When a run ends, scout asks whether you disagree with any score. Each correction you give is appended to the "Scout scoring corrections" section of `corpus/cheat-sheet.md` as a compact example: the company's facts, the score it got, the score you gave it, and your reason. The tracker row is updated to your corrected score at the same time.

On every future run, scout reads those corrections before scoring and carries them as few-shot calibration examples. When a new company resembles a corrected one, the scorer leans toward your corrected verdict instead of its own instinct. Over- and under-scoring patterns both count: "you called this a 3 and I would never work there" is exactly as valuable as "you called this a 1 and I applied."

This mirrors the corpus principle that runs through the whole workspace: everything you teach the system compounds. Correcting two or three scores per run costs you thirty seconds and permanently sharpens every run after it. The scorer learns your taste -- but only if you tell it when it is wrong.

## 5. The no-open-role doctrine

A high-fit company with NO open role is a LEAD, not a dead end -- flag it for /outreach.

This is the single most counterintuitive rule in the playbook, so here is the math. A posted role means the competition has been invited: hundreds of applicants, keyword screening, a process designed to reject efficiently. No posted role means one of two things -- the need exists but the posting has not caught up (common right after a raise), or the need has not been articulated yet (common at seed, where the founder does not know they need your function until someone shows them). In both cases, a direct note from a high-fit person arrives with effectively zero competition.

The worst case for reaching out to a high-fit company with no posting is a polite non-answer. The best case is a role that gets shaped around you. Compare that to the expected value of application number 340 in an ATS queue, and "no open role" starts looking like a feature of a lead rather than a bug.

Concretely: when a scout run finishes, the report's "No role yet - outreach candidates" section is not the leftovers. For the companies where your fit is a 3, it is often the best section on the page. Run `/outreach {company}` on them.

## 6. Cadence

Weekly is right. Funding news has roughly a 30-day useful window, so a weekly run keeps you comfortably inside it while giving each run enough fresh raises to be worth the cost. Daily runs mostly rediscover what you found yesterday; monthly runs mean you arrive after the hiring window has closed.

You can make it literally weekly with a Claude Code scheduled task or a cron entry that runs `/scout` on a fixed morning. Before you do, two honest warnings:

- **API cost is real.** Every run pays for web searches, portfolio-page fetches, careers-page fetches, and scoring calls. A tier-1 run is modest; a tier 1-3 run is roughly four times the portfolio pages. Automating it means paying that every week whether or not you read the output.
- **Run it manually first -- for a few weeks.** The feedback loop in section 4 only works if you are present to correct scores, and the early runs are exactly when the scorer needs correcting most. Automate the run only after the scores mostly match your taste and you trust the report enough to skim it. An unattended pipeline feeding an unread report is worse than no pipeline.

The manual weekly ritual is genuinely good: run `/scout` Monday morning, correct a score or two, fire off `/outreach` at the leads, and get on with your week.

## Appendix: industrializing it

`/scout` is the agentic, file-based distillation of a heavier system: a database-backed pipeline of scripts that did the same job at larger scale. This appendix describes that architecture for the day you outgrow the command. It describes it -- this repo deliberately does not ship it.

**The pipeline order:** discover (pull funding news, extract companies) -> resolve (dedupe by normalized name and by website domain against everything already tracked) -> enrich (visit each company's site and fill missing fields: description, stage, headcount, careers URL) -> score (batch-score against the fit profile, with past disagreements injected as calibration examples) -> scrape-careers (walk careers pages of the top-scoring companies and classify every open role by lane). Each stage reads and writes a database, so stages can run independently, on their own schedules, and re-run only what is stale -- for example, re-scoring only companies whose data changed or whose profile hash no longer matches.

**Why parser health-checks exist:** scrapers rot. Portfolio and careers pages get redesigned, move behind JavaScript rendering, or vanish, and a broken parser fails silently -- it returns zero companies and looks like a quiet week. The industrial version tracks consecutive zero-result runs per source; two in a row auto-files a maintenance issue and the pipeline skips that source until the issue is closed. Silent decay becomes a visible, assignable task. `/scout`'s skip-and-report behavior on failed pages is the lightweight cousin of the same idea.

**When to graduate:** the agentic command is the right tool while you are running weekly and tracking dozens to a few hundred companies. Consider the database-and-scripts version when you want daily automated volume, when your tracker passes roughly 500 companies (CSV dedupe and re-scoring get slow and error-prone at that size), or when you need incremental re-scoring and field-level provenance. Until then, the command's economics are better: zero infrastructure, and the corpus feedback loop travels with your workspace.
