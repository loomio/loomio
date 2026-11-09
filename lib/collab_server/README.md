# Loomio collaboration server

This library is Loomio's server for live collaborative editing. It runs inside the Rails app, at `/collab_server`, and speaks the [Hocuspocus](https://tiptap.dev/docs/hocuspocus) collaboration protocol, so the Vue client's editor (`collab_editor.vue`) connects to it with the unmodified `@hocuspocus/provider`.

It is compatible with Hocuspocus but is not Hocuspocus. It is not affiliated with or endorsed by Tiptap GmbH, which makes Hocuspocus. It implements only the part of the protocol that Loomio uses.

## What it aims to do

Loomio used to run the Node `@hocuspocus/server` as a separate service. That service needed its own container, hostname and TLS certificate. It authorized each browser by calling back into Rails with the user's permanent secret token, which the page had to expose to JavaScript.

This library replaces that service. Its aims are:

- Keep the browser side unchanged. The client keeps using the standard Hocuspocus provider and Yjs.
- Remove the separate service. Collaboration runs in the same Puma processes as the app.
- Authorize with the session cookie, the way Action Cable does. No secret token reaches the browser.
- Be pure Ruby, with no native extension or Rust toolchain.
- Stay small, with only the features Loomio uses.

The server relays documents. It does not store them, and it does not read their content. Saved records hold the content. A document lives in memory only while someone has it open. Browsers also keep a copy in IndexedDB.

## How it works

A WebSocket starts as an HTTP request to `/collab_server`. `Server#call` checks the `Origin` header, then takes over the socket from Puma (a Rack full hijack). From there, four layers handle the traffic:

- **Reactor** (`reactor.rb`). One thread per process waits on every socket with `nio4r`. It reads frames, hands each message to its socket's handler, and writes buffered output in one system call per socket.
- **WebSocket** (`web_socket.rb`). Wraps `websocket-driver` for framing. It sets `TCP_NODELAY`, so small frames are sent at once.
- **ClientConnection** (`client_connection.rb`). One per socket. A socket can carry several documents. A client opens a document with an Auth message. The server then calls `config.authenticate` with the document name and the Rack env of the upgrade request. In Loomio, that resolves the user from the session cookie and checks permission on the record. Messages for a socket run in order on a small thread pool (`serial_queue.rb`), because authentication touches the database.
- **Connection** and **Document** (`connection.rb`, `document.rb`). Handle the y-protocols sync and awareness messages for one document.

### Documents without a CRDT

A Node Hocuspocus server keeps a full Yjs document for every open document. This server does not. It works on the encoded Yjs update format instead, using the operations Yjs itself provides for that format:

- `Yjs.merge_updates` combines updates into one.
- `Yjs.diff_update` extracts the part of a document that a client is missing, given the client's state vector.
- `Yjs.encode_state_vector_from_update` derives a state vector.

These are ported line by line from `yjs/src/utils/updates.js`. Their output matches Yjs byte for byte. Content the server never needs to split stays as raw bytes. Strings are measured in UTF-16 code units, as JavaScript measures them.

A `Document` holds a list of updates. It also records the clock ranges of every struct and deletion it has seen. Those ranges answer two questions without merging anything:

- Does an incoming update add anything? Only updates that do are stored and broadcast. This matches a Y.Doc, which emits nothing for content it already has.
- What is the document's state vector?

Updates are merged into one when a client joins and needs a diff. Otherwise they are merged only after they reach four times the size of the merged state plus 256 KB, which bounds memory.

### Awareness

Awareness carries presence: cursors and user names. `awareness.rb` follows the rules of `y-protocols/awareness`, keeping each client's latest state and clock. States are kept as the JSON strings the clients sent. When a socket closes, its clients' states are removed and the removal is broadcast. States that are not renewed within 30 seconds expire.

### Several processes

Each Puma worker holds its own documents. Two people editing the same record may be connected to different workers, or different servers. Each process therefore subscribes to an Action Cable pub/sub channel for each document it has open. It publishes new updates and awareness changes there and applies what other processes publish.

Pub/sub only delivers to subscriptions that are already active, and they activate some time after a process subscribes. So once its subscription is active, a process publishes its whole state with a greeting. Every peer that hears it merges that state and replies with its own. Whichever process subscribes last therefore exchanges state with all the others, including edits made while subscriptions were starting. If a publish fails, for example during a Redis or database outage, the process greets again with its whole state every few seconds until a greeting succeeds. That way processes catch up once pub/sub recovers. Yjs merges are commutative and idempotent, so duplicate or reordered messages between processes are harmless. Loomio's Action Cable adapter is solid_cable, or Redis when it is configured.

### Protocol coverage

The server speaks the protocol of `@hocuspocus/server` 4.x.

Supported:

- Auth: the reply is always `read-write` or `permission-denied`.
- Sync: SyncStep1, SyncStep2, Update and SyncReply.
- SyncStatus acknowledgements.
- Awareness and QueryAwareness.
- Close, from either side.
- Several documents on one socket.
- The idle timeout.

Not supported, because Loomio does not use them:

- Read-only connections.
- Session-aware document names, the provider's `sessionAwareness` option.
- Stateless messages, which are ignored.
- Token refresh.
- Server-side load and store hooks.
- Redis-style cross-server stateless broadcasts.

## Configuration

Loomio configures the server in `config/initializers/collab_server.rb`, and `config/routes.rb` mounts `CollabServer.server` at `/collab_server`. The settings are in `configuration.rb`:

- `authenticate` decides access.
- `allowed_origin` checks the upgrade request's `Origin` header. Browsers send cookies with WebSocket requests from any site, so this check stops other sites from connecting as the visitor.
- `wrapper` runs `authenticate` inside the Rails executor.
- `error_handler` reports errors to `Rails.error`.
- `pubsub` is Action Cable's adapter.
- `timeout`, `threads` and `message_size_max` have defaults suited to Loomio.

`CollabServer.server.stop` disconnects everyone and refuses connections until `start`. The E2E specs use it, through dev-only routes, to test clients while the server is away.

## Tests

There are three layers:

- **Yjs vectors** (`test/lib/collab_server/yjs_test.rb`). `generate_yjs_vectors.mjs` uses real Yjs to make random multi-client edits: text with emoji, formatting, maps, arrays, XML and deletions. It records Yjs's own merges, diffs and state vectors. The Ruby port must reproduce them byte for byte, including merges of shuffled and partial update sets. The vectors are not committed. The tests generate them into `tmp/collab_server/yjs_vectors.json` with the Yjs version in `vue/node_modules`, and regenerate them when that version or the generator changes. They need Node and `npm ci` in `vue/`. To regenerate by hand, run `node test/lib/collab_server/generate_yjs_vectors.mjs`.
- **Unit tests** (`document_test.rb`, `awareness_test.rb`, `server_test.rb`). Cover the document, awareness and protocol handling with a fake socket. This includes origin checks, timeouts, stop and start, and two servers sharing a pub/sub adapter.
- **Provider compatibility** (`provider_compat.test.mjs`). Runs the real `@hocuspocus/provider` and Yjs from `vue/node_modules` against the server under Puma. It covers auth, denial, cookie identification, convergence of concurrent edits, late joiners, acknowledgements, awareness, several documents on one socket, reopening a document, recovery after the server restarts, large documents and stateless messages.

The compatibility suite runs in CI with `node --test test/lib/collab_server/provider_compat.test.mjs`, so a provider upgrade is tested against this server. Setting `COLLAB_SERVER_COMPAT_URL` runs the same tests against any other server. They pass against the Node `@hocuspocus/server` 4.8.0, which shows they describe Hocuspocus behaviour and not just this implementation.

`CollabDocumentAuthService` and its tests cover Loomio's access rules.

## Performance

### Method

The benchmark compares this server with `@hocuspocus/server` 4.8.0, configured as Loomio ran it, with the same workload against each.

- **Setup.** Each server ran as a single process on an Apple M4 with 10 cores: Node 26.12, or Ruby 4.0.9 under Puma 8 with YJIT off.
- **Load generator.** `bench/bench.mjs` runs real provider clients on the same machine. Each client has its own WebSocket, as a browser tab would.
- **Measurements.** It samples the server process's CPU time and resident memory with `ps`. Latency is the time from an edit in one client to its arrival in another.

The scenarios are:

- **Typing:** 50 documents with 4 editors each, every editor typing 10 characters a second for 30 seconds.
- **Joining:** 300 clients join one document holding 40 KB of text at once.
- **Holding:** 500 documents of about 10 KB, with 2 clients each.

### Results

| Scenario | Measure | Node | Ruby |
| --- | --- | --- | --- |
| Typing (1,650 edits a second) | latency p50 / p95 / p99 | 15 / 23 / 27 ms | 17 / 27 / 35 ms |
| | server CPU | 20% of a core | 22% of a core |
| | peak memory | 188 MB | 68 MB |
| Joining (300 clients, 40 KB) | time until all are synced | 115 ms | 119 ms |
| | server CPU time | 0.15 s | 0.09 s |
| Holding (500 documents) | memory | 265 MB | 88 MB |
| Idle | memory | 72 MB | 46 MB |

CPU use and latency are close to Node's. The Ruby server uses about a third of the memory, because it keeps encoded updates rather than integrated Yjs documents.

Inside Loomio the server shares Puma's memory, so only the growth above Puma's baseline counts. In the holding scenario that was 42 MB in Ruby and 192 MB in Node, for 500 documents and 1,000 sockets.

### What profiling found

CPU profiles (`STACKPROF=path`) and allocation counts found five problems, each now fixed:

- **Nagle's algorithm.** Small frames waited for the previous frame's acknowledgement. Setting `TCP_NODELAY` fixed it; Node's `ws` does the same.
- **Merging on the hot path.** Regular compaction re-merged whole documents while people typed, stalling other messages. In the benchmark the documents grew in step, so their merges coincided and pushed p99 latency near one second. Merging now happens when a client joins, or once pending updates far outweigh the merged state.
- **Writes and wake-ups.** Each frame was a system call made while holding the document lock. Frames are now buffered and flushed by the reactor, and the reactor is woken once per turn rather than once per frame.
- **Read buffers.** A fresh 16 KB read buffer per read made garbage collection the largest cost. One buffer is now reused.
- **Large strings.** Measuring a string's UTF-16 length in a Ruby loop dominated joins on large documents. Strings are now counted in C, and valid UTF-8 is no longer transcoded.

After these fixes, handling one keystroke update takes about 40 µs and allocates about 225 objects, including relaying it to three peers. Merging costs about 3.5 µs per struct, so a 5 KB document with 364 structs merges in 1.4 ms. The remaining tail latency comes mostly from garbage collection pauses.

### Running the benchmark

Install the Node server outside the repository:

```sh
mkdir -p /tmp/hp && npm --prefix /tmp/hp install @hocuspocus/server@4.8.0
NODE_PATH=/tmp/hp/node_modules node lib/collab_server/bench/node_server.mjs 4600 &
bundle exec puma -q -t 5:5 -b tcp://127.0.0.1:4601 lib/collab_server/bench/ruby_server.ru &

node lib/collab_server/bench/bench.mjs ws://127.0.0.1:4600 "$(lsof -ti tcp:4600 -sTCP:LISTEN)" typing
node lib/collab_server/bench/bench.mjs ws://127.0.0.1:4601 "$(lsof -ti tcp:4601 -sTCP:LISTEN)" typing
```

The scenarios are `typing`, `storm` and `memory`. Restart each server between scenarios so memory figures start from idle. Set `TIMELINE=1` to see p95 latency for each two-second window. Set `STACKPROF=/tmp/profile.dump` on the Ruby server to write a CPU profile when Puma stops, then read it with `bundle exec stackprof /tmp/profile.dump`.

## Limits

- Merge time grows with document size. A client joining a very large document waits for a merge in Ruby. Loomio's documents are comment and description drafts, so this stays small.
- Ruby runs one thread at a time per process. A long merge or a garbage collection pause delays every socket in that process.
- The server cannot read or change documents itself, for example to render HTML from a draft. That would need a full Yjs implementation, such as [y-rb](https://github.com/y-crdt/yrb).

## Licence

Parts of this library are ported from yjs, lib0, y-protocols and @hocuspocus/server, all MIT-licensed. `LICENSE-THIRD-PARTY` holds their notices.
