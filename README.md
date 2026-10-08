# StreamWright Orchestration — running the streamwright CLI as Dagster pipelines (prototype)

`streamwright-orchestration` (`streamwright.orchestration`) runs [StreamWright](https://github.com/karthick-jaganathan/streamwright)
sources as named declarative DAGs (**pipelines**), per **user** and **network**, as Dagster op graphs. It never imports
streamwright: every node shells out to the `streamwright` CLI (`$STREAMWRIGHT_BIN`).

- **Pipelines** (`config/pipelines/<name>.yaml`) — a named DAG of canonical node names and their `after` edges.
- **Networks** (`config/networks.yaml`) — each network's StreamWright source (in [`sources/`](sources/)), `inputs`,
  `connectors`, `image` and `streams:` map (alias or `false`-skip each canonical node), so one pipeline runs across networks.
- **Accounts & secrets** (`src/streamwright/orchestration/accounts.py`) — the account provider (the `(user, account,
  network)` rows a trigger fans out over, each with its own `token`) and the secrets provider (per-network app
  credentials by region); each an API (`STREAMWRIGHT_ACCOUNTS_URL` / `STREAMWRIGHT_SECRETS_URL`) or a file for development.
- **Wrappers** — turn a node into its `streamwright run` command, derived from the source's declared `spec`.
- **Execution** — a local subprocess (default), a `docker run`, or a Kubernetes Job (`STREAMWRIGHT_EXECUTION`); see
  [docker/](docker/README.md) and [k8s/](k8s/).

## Install and test

```sh
python3 -m venv .venv && .venv/bin/pip install -e .
.venv/bin/python -m unittest discover -s tests          # a stand-in streamwright CLI: no connectors needed
```

To run real pipelines, point `STREAMWRIGHT_BIN` at a `streamwright` CLI that has the network's connectors:

```sh
python3 -m venv /tmp/streamwright-sdk-venv
/tmp/streamwright-sdk-venv/bin/pip install streamwright
/tmp/streamwright-sdk-venv/bin/streamwright connectors install google_ads microsoft_ads meta_ads
export STREAMWRIGHT_BIN=/tmp/streamwright-sdk-venv/bin/streamwright
```

📖 Docs: [docs/](docs/index.md) — the [architecture](docs/architecture.md) (model, shared vocabulary, wrappers, execution
mechanics, secrets) and [running](docs/running.md) (triggering, the Dagster UI, execution modes, environment). The
StreamWright documentation: https://streamwright.web.app/docs/orchestration/
