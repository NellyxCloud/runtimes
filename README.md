# Nellyx runtime images

One image per runtime, published to `ghcr.io/NellyxCloud/runtimes`.

This repository was lost and rebuilt from what `NellyxAgent` actually consumes.
The contract fields below are not aspirational: each one is read by the agent at
container-creation time. Changing a value here without changing the matching
contract in the agent (or vice versa) silently breaks services.

## Relationship with NellyxAgent

`NellyxAgent` resolves, in order:

1. `AGENT_RUNTIME_CONTRACTS_PATH`, if the directory exists
2. a `4.1-RuntimesForConsole` directory next to the agent
3. the contracts embedded in `src/runtime/contracts.builtin.ts`

Steps 1 and 2 let a node override a contract without rebuilding the agent. This
repository is the source of truth for the **images**; the embedded table is the
fallback. A node can also point at a private mirror with `AGENT_RUNTIME_REGISTRY`.

## Invariants every image must satisfy

These come from the agent, not from preference:

| Requirement | Where the agent relies on it |
|---|---|
| Runs as uid `1000` (`1000:1000`) | `dockerSocketRuntime.resolveContainerUser` forces it |
| Workspace at `/home/nellyx/app` | `agentService` mounts the host workspace there |
| Logs at `/var/log/nellyx` | `agentService` mounts the host logs directory there |
| `nellyx-entrypoint` at `/usr/local/bin/` | every contract's `entrypoint.cmd` |
| Listens on `$PORT` | `dockerSocketRuntime` injects `PORT` |
| Honours `INSTALL_COMMAND` / `BUILD_COMMAND` / `START_COMMAND` | `dockerSocketRuntime` injects all three |

The agent also passes `--cap-drop ALL`, `--security-opt no-new-privileges:true`,
a pids limit, tmpfs mounts and (per the contract) a read-only rootfs when the
service asks for one. An image that needs to write outside the mounts, escalate
privileges or bind a port below 1024 will not start.

## Layout

```
shared/entrypoint.sh   the entrypoint every image copies in
node/ bun/ python/ deno/ go/ php/ static/
    Dockerfile         minimal base, no orchestrator
    contract.json      a copy of the contract the agent ships, for reference
```

## Building and publishing

Locally:

```bash
# Build context is the repository root: the Dockerfiles COPY shared/entrypoint.sh.
docker build -t ghcr.io/nellyxcloud/runtimes:node-22 -f node/Dockerfile .
```

`node/Dockerfile.offline` builds the same contract on the Bun base, for hosts
that cannot reach Docker Hub. It exists to smoke-test the contract on a
restricted network; CI never publishes it.

## Consistency check

`contract.json` in each runtime directory is a copy of what the agent resolves.
After changing either side, confirm they still agree:

```bash
cd ../NellyxAgent && bun run build
node -e '
process.env.AGENT_NODE_TOKEN="test-agent-token-12345678";
process.env.AGENT_HMAC_SECRET="test-hmac-secret-12345678";
const {loadRuntimeContract}=require("./dist/runtime/registry.js");
for (const r of ["node","bun","python","deno","go","php","static"]) {
  console.log(r.padEnd(8), JSON.stringify(loadRuntimeContract(r)));
}' > /tmp/from-agent.json
```

A mismatch in `image`, `entrypoint.cmd`, `filesystem.workdir` or
`network.defaultPort` means the node will start the wrong image, or the wrong
command, or the wrong port.

From GitHub Actions, `.github/workflows/publish.yml` builds on push to `main`
and on a manual dispatch, authenticating to GHCR with the standard
`GITHUB_TOKEN` and pushing `<runtime>-<version>` tags.

Tags are immutable by convention: a node that pulls `node-22` should get the
same image on every host, so publish `node-22.1` for a change and keep `node-22`
pointing at the last good build.

## Smoke test

An image is not done until it runs a service end to end:

```bash
docker run --rm -e START_COMMAND="node -e 'require(\"http\").createServer((q,s)=>s.end(\"ok\")).listen(process.env.PORT)'" \
  -e PORT=3000 -p 127.0.0.1:3000:3000 ghcr.io/nellyxcloud/runtimes:node-22
curl -s http://127.0.0.1:3000   # -> ok
```