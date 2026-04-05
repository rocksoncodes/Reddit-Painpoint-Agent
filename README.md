# Reddit Painpoint Agent

This agent monitors niche subreddits to surface and validate real, recurring frustrations from real people before you write a single line of product code.

It runs on a scheduled pipeline: collect posts and comments from configured subreddits, score sentiment to filter noise, then use Gemini to produce structured problem briefs your team can actually act on. 

Results are persisted to a database and optionally exported to Notion or delivered by email.
Built with a clean service/repository architecture, pipeline-based data flow and runtime secrets management via Infisical.

*Flask · SQLAlchemy · Gemini · Reddit API · Infisical*

## 1. Why Reddit-only?

Focusing on one platform keeps ingestion, privacy and evaluation requirements simple. Reddit's conversational structure (posts + nested comments) is well-suited to surfacing recurring, real-world problems. Other platforms can be added later by creating a new input client and matching ingress service.


## 2. Problem

Manual discovery of recurring real-world problems across subreddits is slow and noisy. This service automates discovery, validation, and packaging of those findings so teams can act faster.


## 3. Solution

- Periodic collection of posts and comments from configured subreddits
- Sentiment analysis on collected data to validate signal strength
- LLM-based curation (Gemini) to produce structured problem briefs
- Secrets managed dynamically from [Infisical](https://infisical.com) at runtime
- Output: curated briefs persisted to the database and optionally exported (Email / Notion)


## 4. Quick Start

### Prerequisites

- Python 3.11+ (tested with 3.13)
- A Reddit app (client ID & secret)
- A Gemini API key (Google LLM)
- An [Infisical](https://infisical.com) project with secrets configured
- Optional: Notion integration + Email credentials

### Install

#### Option 1. Automated Setup (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/rocksoncodes/Reddit-Painpoint-Agent.git
   cd Reddit-Painpoint-Agent
   ```
2. Run the setup script:
   ```bash
   chmod +x ./setup.sh
   ./setup.sh
   ```
   *This creates a virtual environment, installs dependencies, and initializes your `.env` file.*

#### Option 2. Manual Setup

1. Clone the repository and navigate to the directory.
2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   # Windows
   .\.venv\Scripts\activate
   # macOS/Linux
   source .venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Initialize the environment file:
   ```bash
   # Windows
   copy .env.example .env
   # macOS/Linux
   cp .env.example .env
   ```

### Configure `.env`

Open the `.env` file and fill in your credentials.

**If using Infisical (Recommended for security):**
You only need to provide the Infisical connection details. The agent will fetch all other secrets from your Infisical project at runtime.
```env
INFISICAL_CLIENT_ID=your_client_id
INFISICAL_CLIENT_SECRET=your_client_secret
INFISICAL_PROJECT_ID=your_project_id
```

**If NOT using Infisical:**
Leave the Infisical fields blank and fill in the individual secrets directly in the `.env` file (Reddit, Gemini, Database, etc.).
```env
REDDIT_CLIENT_ID=your_reddit_id
REDDIT_CLIENT_SECRET=your_reddit_secret
GEMINI_API_KEY=your_gemini_key
DATABASE_URL=sqlite:///database.db
...
```

### Run

Run the background scheduler (every 2 weeks):

```cmd
python agent.py
```

Run the full pipeline once manually:

```cmd
python main.py
```

## 5. Project Structure

```
Reddit-PainPoint-Agent/
├── agent.py                    # Background scheduler (APScheduler)
├── main.py                     # Manual entry point
│
├── pipelines/              # Coordinate the data flow between services
│   ├── ingress_pipeline.py
│   ├── sentiment_pipeline.py
│   ├── core_pipeline.py
│   └── egress_pipeline.py
│
├── services/                   # Business logic
│   ├── infisical_service.py    # Runtime secrets loading from Infisical
│   ├── ingress_service.py      # Reddit data collection
│   ├── reddit_service.py       # Scraping & storage pipeline coordinator
│   ├── sentiment_service.py    # Sentiment analysis
│   ├── core_service.py         # Curator Agent (Gemini)
│   └── egress_service.py       # Email & Notion exporters
│
├── repositories/               # Data access layer (SQLAlchemy)
│   ├── post_repository.py
│   ├── comment_repository.py
│   ├── sentiment_repository.py
│   └── brief_repository.py
│
├── clients/                    # External API adapters
│   ├── reddit_client.py
│   └── gemini_client.py
│
├── database/                   # Models and DB initialization
│   └── models.py
│
├── settings/
│   └── settings.py             # Settings & env variable mapping
│
└── utils/
    ├── logger.py               # Shared logger
    └── helpers.py              # Shared utilities: serializers, Reddit fetchers,
                                #   data integrity checks, text chunking,
                                #   Notion block builders & email formatter
```

## 6. Secrets Management

Secrets are loaded dynamically at startup using `InfisicalSecretsService`. When the app initializes, `settings/settings.py` authenticates with Infisical and injects all project secrets into the environment before any constants are resolved.

The following secrets should be configured in your Infisical project:

| Secret | Description |
|---|---|
| `REDDIT_CLIENT_ID` | Reddit app client ID |
| `REDDIT_CLIENT_SECRET` | Reddit app client secret |
| `REDDIT_USER_AGENT` | Reddit API user agent string |
| `GEMINI_API_KEY` | Google Gemini API key |
| `NOTION_API_KEY` | Notion integration token *(optional)* |
| `NOTION_DB_ID` | Notion database ID *(optional)* |
| `EMAIL_ADDRESS` | Sender email address |
| `EMAIL_APP_PASSWORD` | Email app password |
| `RECIPIENT_ADDRESS` | Report recipient email |
| `DATABASE_URL` | SQLAlchemy database connection URL |


## 7. How it Works

1. **Ingress** — Collect posts + comments from configured subreddits via Reddit OAuth
2. **Sentiment** — Normalize text, filter noise, run VADER sentiment scoring
3. **Curation** — Run structured Gemini prompts to identify and package real, recurring problems
4. **Egress** — Persist validated briefs to the DB and export to configured sinks (Notion / Email)

## 8. Development Status

- Reddit ingestion and data collection
- Sentiment analysis pipeline
- Gemini-based Curator Agent
- Notion sync and email notifications
- Repository pattern (data access layer)
- Dynamic secrets loading via Infisical
- Storage logic consolidated into repositories
- Egress helpers (`chunk_text`, `create_notion_blocks`, `format_email`) extracted to `utils/helpers.py`

## 9. Notes & Limitations

- Backend infrastructure only — no UI
- Focused exclusively on Reddit as a data source
- LLM inference costs apply depending on Gemini usage tier

## 10. Project Wiki

See [`project wiki/Home.md`](project%20wiki/Home.md) for extended rationale, architecture notes and running notes.
