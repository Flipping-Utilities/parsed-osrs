# Wiki data snapshots

Extracted JSON snapshots live under [`wiki-scraper/data/`](./wiki-scraper/data) on `main`:

```
data/
├── osrs/                    # OSRS pipeline output
│   ├── items/all-items.json
│   ├── monsters/all-monsters.json
│   ├── shops/all-shops.json
│   └── ...                  # one folder per extractor (16 total)
└── rs3/                     # RS3 pipeline output (same layout)
```

## Cadence

A GitHub Actions workflow (`.github/workflows/wiki-scrape.yml`) refreshes
both pipelines daily at 06:00 UTC. **Mondays are "weekly" runs**: they also
run the slow alias/redirect sweep and commit the fresh JSON to `main`.
Tuesday–Sunday runs ("daily") only refresh page content + re-extract, and
leave `main` untouched — state still lands in the Turso DB, but no commit.

## Consuming the data

The repo grows by ~50–100 MB per weekly snapshot, so a full clone pulls the
entire history. Get just the latest snapshot with a shallow clone:

```bash
git clone --depth=1 https://github.com/<owner>/<repo>.git
```

If you only need one game's JSON, use a sparse-checkout after the shallow
clone:

```bash
git clone --depth=1 --filter=blob:none --sparse https://github.com/<owner>/<repo>.git
cd <repo>
git sparse-checkout add wiki-scraper/data/osrs
```

## Programmatic access

For "give me the JSON as of date X", use the GitHub API to list commits on
`wiki-scraper/data/` and fetch the tree at that SHA. The Actions artifact
attached to each weekly workflow run is also downloadable via the API for
~30 days after the run.
