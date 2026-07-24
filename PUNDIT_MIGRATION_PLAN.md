# CanCan to Pundit migration

This is the durable handoff document for migrating Loomio from CanCan to
Pundit. It is intended to make the work safe to stop and resume. Progress must
be recorded in the migration tracker described below; chat history is not a
source of truth.

For a short operational handoff, begin with
`docs/authorization_migration/README.txt`, then run
`bin/pundit-migration-status`.

The migration branch is `pundit`.

## Current checkpoint

As of 2026-07-24:

- the `pundit` branch is active;
- the route inventory and action tracker foundation exists;
- 761 routed controller entries map to 280 unique first-party production
  actions;
- 279 first-party actions are currently `inventoried`;
- `api/v1/boot#version` is `complete` as the first explicit-public pilot;
- 313 generated, mounted, or development-only actions await an explicit review;
- Pundit is installed beside CanCan;
- `AuthorizationContext` and a deny-by-default `ApplicationPolicy` exist; and
- no resource-bearing controller action has switched from CanCan yet.

Run `bin/pundit-migration-status` for the durable current count. Run
`bin/pundit-migration-status --check` to compare the tracker with the live Rails
route table.

## Objective

Migrate every first-party controller action from CanCan to Pundit, one action at
a time, while preserving or deliberately correcting its authorization
behaviour.

The migration is complete only when:

- every Rails route has a tracked action or a reviewed exemption;
- every first-party production action has reached `complete`;
- every returned resource, collection, field, export, or derived response has
  authorization evidence;
- no first-party request path relies on CanCan;
- no Pundit policy delegates back to CanCan;
- focused authorization tests and the full test suites pass; and
- CanCan and its supporting code have been removed.

Installing Pundit and calling `authorize` is not sufficient. Pundit's
`verify_authorized` and `verify_policy_scoped` callbacks only establish that a
call occurred. They do not prove that the records or fields in the response
were covered by that call. Loomio therefore needs its own response-boundary
verification.

Reference: <https://github.com/varvet/pundit>

## Non-negotiable invariants

1. Authorization defaults to deny.
2. Every routed action has exactly one declared authorization mode.
3. A collection begins with a policy scope. It is never loaded globally and
   filtered for visibility later.
4. A member record is found through its policy scope and then explicitly
   authorized.
5. A nested record is loaded through the authorized parent relationship.
6. Creating a record requires authorization of the proposed, unsaved record.
7. The controller authorizes a mutation before invoking its service. Important
   service checks may remain as defence in depth.
8. An action cannot render, redirect, stream, or download until it has recorded
   authorization evidence covering its response.
9. Public access is an explicit policy decision, not a skipped check.
10. Authorization policies do not call `.ability`, `.can?`, `authorize!`, or
    any other CanCan API.
11. New routes added during the migration use Pundit immediately and must be
    present in the tracker.
12. A migrated action and its tracker entry change together.

## Authorization context

`pundit_user` should return an `AuthorizationContext`, rather than only a
`User`. The context should contain:

- the user or `LoggedOutUser`;
- authentication mechanism: session, B2 API key, B3 instance key, topic-reader
  token, or signed-out;
- impersonation state, including the operator and impersonated user; and
- request credentials that legitimately affect access.

Policies may delegate ordinary user methods through this context, but
authentication mechanism and impersonation must remain visible when they
matter.

Call `pundit_reset!` whenever login, logout, impersonation, or another operation
changes the current authorization context during a request.

## Authorization modes

Every tracked action declares exactly one mode:

| Mode | Required evidence |
| --- | --- |
| `resource` | An exact record was found through a scope and authorized |
| `collection` | The returned relation originated from the applicable policy scope |
| `resource_and_collection` | Both resource and collection evidence |
| `public` | An explicit headless public policy and a reviewed reason |
| `authentication_only` | An explicit authentication policy |
| `engine_reviewed` | A recorded review of the mounted/generated controller boundary |

Raw `skip_authorization` and `skip_policy_scope` are prohibited in first-party
code. An exceptional endpoint must use one of the explicit modes above.

## Policy scopes and query objects

Policy scopes own visibility. Query objects own non-security filtering,
searching, sorting, pagination, and eager loading.

For example, the current `PollQuery` has two responsibilities:

- `visible_to` and `relevant_to` decide which polls an actor can see. This logic
  moves into `PollPolicy::Scope`.
- `filter` applies requested group, discussion, tag, author, type, status, and
  text-search filters. This may remain in a renamed filter/query object, but it
  must receive an already-scoped relation.

The intended shape is:

```ruby
authorized_polls = policy_scope(Poll)
filtered_polls = PollQuery.filter(chain: authorized_polls, params: params)
```

`PollQuery.filter` must not broaden its input relation or perform a second,
different visibility calculation. If filtering needs a related record such as
a group or discussion, that related record must also be scoped or otherwise
authorized before it influences the result.

Apply the same separation to other query objects:

- access, tenancy, membership, topic-reader-token, and privacy predicates move
  into policy scopes;
- presentation filters and ordering remain composable queries;
- scopes may call small shared authorization predicates, but not controller
  code or CanCan;
- serializers do not independently reconstruct visibility rules.

## Response-boundary verification

Add application helpers that return evidence-bearing resources rather than
setting an unverified boolean. The exact API should be settled during the
foundation phase, but it should support forms equivalent to:

```ruby
self.resource = authorized_resource(Topic, :show?) do |scope|
  scope.find(params[:id])
end

self.collection = authorized_collection(Membership) do |scope|
  MembershipQuery.filter(chain: scope, params: params)
end

authorize_public_response!(
  :boot_version,
  reason: "The application version is public"
)
```

`respond_with_resource`, `respond_with_collection`, raw `render`, `redirect_to`,
`send_data`, streaming responses, and empty/head responses must refuse to
complete without evidence matching the action's declared mode.

When an action authorizes one record and returns another object, it must declare
the relationship:

```ruby
response_derived_from!(poll, covers: events)
```

This is necessary for service methods that return events after mutating a poll,
discussion, stance, membership, or other domain resource.

Aggregates, reports, counts, searches, exports, and downloads require both an
explicit policy decision and evidence for their source scopes.

Sensitive field disclosure should be policy-bound. Avoid generic serializer
flags such as `include_email: true`. Prefer resource-specific policy methods or
explicit disclosure sets which cannot accidentally apply to unrelated records.

## Migration tracker

Create the following committed text files during the foundation phase:

```text
docs/authorization_migration/
  README.txt
  routes.tsv
  coverage.txt
  exceptions.txt
  decisions.txt
  findings.txt
  controllers/
    api_v1_polls_controller.txt
    api_v1_topics_controller.txt
    ...
  policies/
    poll_policy.txt
    topic_policy.txt
    ...
```

`routes.tsv` is generated from the Rails route table and must not be edited by
hand. It contains, at minimum:

```text
action_id
verb
path
controller
action
environment
owner
disposition
status
tracker_file
```

The stable `action_id` is the controller path and action, for example
`api/v1/polls#index`. Multiple route aliases may point to the same action and
must all be retained in `routes.tsv`.

Routes are classified as:

- `first_party_production`;
- `active_admin_generated`;
- `mounted_engine`;
- `development_only`; or
- `unknown`.

`unknown` is always a failure. Generated and mounted routes are not silently
ignored; they receive an entry in `exceptions.txt` documenting where their
authorization is enforced and who reviewed it.

### Action tracker format

Each controller file contains one block per action:

```text
[action index]
action_id = api/v1/polls#index
routes = GET /api/v1/polls
status = inventoried
risk = high
authorization_mode = collection

current_loader =
current_cancan =
target_policy = PollPolicy
target_query = index?
base_scope = PollPolicy::Scope
parent_constraint =

response_type = collection
response_records = Poll
sensitive_fields = anonymous ballots, result visibility, attachments
response_proof = policy_scope

actors = signed_out, member, guest_reader, revoked_member, coordinator, instance_admin
dimensions = public, private, direct, active, closed, anonymous, identified

baseline_tests =
policy_tests =
request_tests =
negative_tests =
composition_tests =

decision_differences = none
review = pending
commit =
verified_at =
notes =
```

The allowed statuses are:

```text
inventoried
characterized
policy_written
dual_running
enforced
verified
complete
```

Status meanings:

- `inventoried`: route and action are recorded.
- `characterized`: current loads, responses, actors, and behaviour are covered
  by baseline tests.
- `policy_written`: policy and scope exist with focused tests.
- `dual_running`: CanCan and Pundit decisions are compared for this action.
- `enforced`: the action uses Pundit and response verification.
- `verified`: negative, request, and composition tests pass.
- `complete`: CanCan dependency is removed and all tracker evidence is present.

The status checker validates required fields for every transition. It must not
trust the status word alone.

## Progress command

The foundation phase must add:

```text
bin/pundit-migration-status
```

Running it with no arguments should regenerate or validate the route inventory
and print:

```text
Pundit migration
  routed actions:       241
  complete:              18
  remaining:            223
  untracked routes:       0
  stale tracked routes:   0
  invalid exemptions:     0

Next:
  api/v1/polls#receipts             characterized  high
  api/v1/polls#index                inventoried     high
```

The numbers above are examples, not a current inventory.

Exit status is:

- `0` only when all tracked first-party production actions are complete and all
  other routes have valid reviewed dispositions;
- `1` while valid tracked work remains;
- `2` when the tracker is inconsistent, routes are untracked, exemptions are
  invalid, or required evidence is missing.

Useful options:

```text
bin/pundit-migration-status --remaining
bin/pundit-migration-status --controller api/v1/polls
bin/pundit-migration-status --risk high
bin/pundit-migration-status --check
bin/pundit-migration-status --json
```

`--check` is used in CI. It fails immediately for an untracked route, a route
whose controller/action no longer exists, a duplicate action block, an unknown
classification, an expired exception, or an invalid status transition.

The route inventory boots the normal development environment and uses
`DATABASE_URL` from the initialized login shell. In this checkout that URL
selects the `loomio_development` copy of `loomio_production`. Development-only
routes are classified explicitly and are not counted as first-party production
migration work, so dynamically generated development routes do not distort the
production progress count.

## Static and runtime enforcement

During the dual-stack period, a registry determines whether an action is
CanCan-backed or Pundit-enforced.

For Pundit-enforced actions, CI prohibits:

- `load_and_authorize`;
- unscoped shared `load_resource`;
- `.ability`, `.can?`, `authorize!`, and CanCan constants;
- `skip_authorization` and `skip_policy_scope`;
- policies or scopes delegating to CanCan; and
- response calls without response evidence.

The response verifier runs as a hard failure in test and development. It should
be observable in production and become a production hard failure for an action
before that action can reach `complete`.

New routes must be added to the tracker and use Pundit from their first commit.

## Per-action workflow

Migrate one routed action at a time:

1. Record every route alias and parameter path for the action.
2. Identify all records loaded, changed, or returned.
3. Trace nested serializers, event/timeline records, broadcasts, search
   documents, notifications, mailers, exports, backups, and background jobs.
4. Add baseline request tests for current allowed and denied behaviour.
5. Fill in the actor/resource decision matrix.
6. Write the policy query and scope from the intended invariant. Do not
   mechanically translate the CanCan rule.
7. Compare Pundit and CanCan decisions for the recorded matrix.
8. Document and test every intentional decision difference.
9. Replace loading with policy-scoped loading.
10. Authorize the operation before invoking the service.
11. Bind all response paths to authorization evidence.
12. Add negative tests for foreign IDs, cross-parent substitution, revoked
    access, broadened collections, and sensitive fields.
13. Add composition tests where another endpoint, timestamp, stable ID,
    ordering, actor, event, or export could reveal protected information.
14. Enable Pundit enforcement for this action.
15. Remove its CanCan dependency.
16. Mark the tracker entry `complete` in the same commit.

If a vulnerability is discovered, stop the action at `characterized`, record it
in `findings.txt`, fix it with a focused regression test, and then resume the
migration.

## Required actor and state coverage

The baseline actor matrix is:

- signed-out/public user;
- authenticated ordinary user;
- guest or topic reader;
- revoked or former member;
- group coordinator/administrator;
- instance administrator;
- deactivated or spam user;
- impersonated user; and
- API-key identity where applicable.

High-risk poll, stance, event, and result actions also cover:

- public, private, and direct topics;
- active and closed polls;
- anonymous and identified polls;
- every `hide_results` mode;
- quorum behaviour;
- revoked access;
- feature flags; and
- correlation through timestamps, stable IDs, ordering, actors, invitation
  metadata, revisions, events, and exports.

`until_vote` is treated as a user-experience restriction rather than a strong
security boundary, but its intended behaviour still receives regression tests.

Authentication and session actions additionally cover session creation,
rotation, expiry, revocation, logout, impersonation, CSRF, token scope, cookie
flags, and cleanup of dependent session records.

## Migration phases

### Phase 0: foundation

- Add Pundit beside CanCan.
- Add `AuthorizationContext`.
- Add fail-closed `ApplicationPolicy` and base `Scope`.
- Add response-boundary evidence and verification.
- Add the dual-stack action registry.
- Generate the initial route and controller trackers.
- Add `bin/pundit-migration-status` and its tests.
- Add CI validation.

This phase must not deliberately change user-visible authorization behaviour.

### Phase 1: pilot all response patterns

Migrate one example of each pattern before scaling:

- explicit public/headless action;
- member resource action;
- collection action; and
- service-backed mutation returning a derived resource.

The pilots validate the framework, tracker, status command, failure handling,
and test helpers.

### Phase 2: shared domain policies

Introduce shared policies and scopes as their first actions require them:

- User;
- Group;
- Topic;
- Discussion;
- Poll;
- Stance;
- Membership; and
- Event.

Do not mark a whole policy migrated merely because the class exists. Completion
is tracked by controller action.

### Phase 3: highest-risk actions

Prioritize:

- login, sessions, identities, registrations, and impersonation;
- polls, stances, results, receipts, voters, and exports;
- topics, discussions, events, comments, and topic readers;
- attachments and translations;
- memberships, invitations, announcements, groups, and reports; and
- search and any cross-resource aggregation.

### Phase 4: remaining API v1 actions

Proceed controller by controller, but continue committing and tracking one
action at a time.

### Phase 5: B2 and B3 APIs

Use namespaced or context-aware policies where API authentication grants
different capabilities. Do not make API keys look like browser sessions.

### Phase 6: remaining first-party and generated surfaces

- HTML controllers;
- mail/action endpoints;
- ActiveAdmin-generated actions;
- mounted engines; and
- development-only controllers.

Generated and mounted surfaces may receive reviewed dispositions rather than
first-party Pundit policies, but they cannot disappear from the inventory.

### Phase 7: remove CanCan

Before removal:

- `bin/pundit-migration-status --check` reports complete;
- repository searches find no first-party CanCan calls;
- `LoadAndAuthorize` and CanCan exception handling are unused;
- the authorization regression suite passes;
- Rails and E2E suites run sequentially and pass;
- security-sensitive serializer, export, and background-job tests pass; and
- dependency and static security checks pass.

Then remove CanCan, its ability classes, compatibility helpers, and the gem.

## Stop and resume procedure

Before stopping:

1. Run `bin/pundit-migration-status`.
2. Update the current action block, including incomplete tests or open
   questions.
3. Record discovered security issues in `findings.txt`.
4. Ensure `Next` from the status command identifies a valid next action.
5. Do not mark an action complete merely because its controller code was
   changed.

When resuming:

1. Confirm the branch is `pundit`.
2. Run `bin/pundit-migration-status --check`.
3. Read `decisions.txt` and unresolved entries in `findings.txt`.
4. Run `bin/pundit-migration-status --remaining`.
5. Resume the first in-progress action; otherwise take the highest-risk
   remaining action.
6. Re-run that action's focused tests before modifying it.

## Commit boundary

After the foundation commit, prefer one controller action per commit. A commit
contains:

- the policy/scope changes required by that action;
- controller and service changes;
- policy, request, negative, and composition tests;
- its tracker update; and
- any query-object extraction required for that action.

Shared infrastructure may use a separate focused commit when it is independently
testable. Do not combine unrelated controller actions merely because they share
a policy class.
