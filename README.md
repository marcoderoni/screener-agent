# Investment Screener Agent v1.0

Stock screener combining analyst upside targets, options flow, and short squeeze signals.
Runs weekly, sends an Excel report by email with AI-generated narratives per stock.

---

## How it works

### Universe
S&P 500 + Nasdaq 100 + Dow Jones 30 — three tabs in the Excel output.

### Hard filters (all four must pass)
| # | Filter | Threshold |
|---|--------|-----------|
| 1 | Upside to analyst mean target | > 20% |
| 2 | Number of analysts with coverage | ≥ 5 |
| 3 | Target dispersion (high–low / mean) | < 40% |
| 4 | Revision momentum (targets rising vs ~60d ago) | positive or no history |

### Scoring (+1 per condition, max 3)
| Condition | Threshold | What it signals |
|-----------|-----------|-----------------|
| Days-to-cover | > 5 | Squeeze fuel — shorts need time to exit |
| Put/Call OI ratio | < 0.70 | Options market positioned bullish |
| Call volume / Call OI | > 1.50 | Unusual call activity (session proxy) |

**🟢 Score 3** = all three bonus conditions met  
**🟡 Score 2** = two conditions met  
Score 0 stocks still appear — ranked below for reference.

### AI narratives
Gemini 2.0 Flash generates a 2-sentence plain-English explanation for every stock with score ≥ 1.

### Revision momentum & data_store.json
On first run, no historical targets exist so all stocks pass filter 4.
From the second run onward, the script compares current analyst targets to those stored ~60 days ago.
Targets actively declining = filtered out.
The file `data_store.json` is updated automatically each run — do not delete it.

---

## Setup

### 1. Install dependencies
```bash
pip install -r requirements.txt
```

### 2. Get API keys (both free)

**Gemini 2.0 Flash**
- Go to https://aistudio.google.com/
- Create API key → copy it
- Paste into `GEMINI_API_KEY` in screener.py

**SendGrid**
- Go to https://signup.sendgrid.com/ (free tier = 100 emails/day)
- Create an API key
- Verify a sender email address (Settings → Sender Authentication)
- Paste API key into `SENDGRID_API_KEY`
- Paste verified email into `SENDGRID_FROM`
- Set your recipient in `EMAIL_TO`

### 3. Run manually to test
```bash
python3 screener.py
```
Output Excel lands on your Desktop: `screener_YYYYMMDD.xlsx`

### 4. Schedule weekly (Mac)
```bash
chmod +x setup_cron.sh
./setup_cron.sh
```
This adds a cron job that runs every Friday at 18:00 and logs to `/tmp/screener_agent.log`.

To check the log:
```bash
tail -f /tmp/screener_agent.log
```

---

## Output Excel structure

| Column | Description |
|--------|-------------|
| Ticker / Name / Sector | Identity |
| Price ($) | Current market price |
| Target Mean ($) | Analyst consensus target |
| Upside (%) | Gap between price and target |
| Analysts (#) | Number of analysts covering |
| Dispersion (%) | (High target – Low target) / Mean |
| Days-to-Cover | Short ratio (days) |
| Fwd P/E | Forward P/E if available |
| P/C OI Ratio | Put/Call open interest ratio |
| Call Activity (×) | Call volume / Call OI |
| Score (0–3) | Sum of bonus conditions |
| Score Breakdown | Which conditions triggered |
| AI Narrative | Gemini-generated 2-sentence summary |

---

## Estimated runtime
- S&P 500 alone: ~4–5 min (500 tickers × yfinance + options on shortlist)
- All three universes: ~6–8 min depending on internet speed and shortlist size
- AI narratives: ~0.5s per stock with score ≥ 1 (free tier rate limit)

---

## Notes & limitations
- yfinance `targetMeanPrice` reflects the last known consensus — may lag a few days vs live Bloomberg/FactSet
- Call volume / OI ratio is a same-session proxy for unusual activity; a true 20-day average would require storing historical options snapshots (future enhancement)
- SendGrid free tier = 100 emails/day; well within weekly cadence
- Gemini free tier = 15 requests/minute; script sleeps 0.5s between calls
