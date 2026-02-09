# STV (Single Transferable Vote) Implementation Plan

## Context

DSA/YDSA groups in NYC and across the US currently use OpaVote for multi-winner STV elections but want to consolidate into Loomio. They need true STV with four method combinations: {Scottish, Meek} x {Droop, Hare}. Loomio's existing `ranked_choice` poll type is simple score aggregation with no elimination rounds or vote transfers — it cannot serve this use case.

This plan adds a new `stv` poll type with a dedicated counting engine, round-by-round results, and multi-winner semantics.

---

## Implementation Status

### COMPLETED

All steps below are implemented and working. 19 backend tests pass, 0 regressions on full suite.

**Design decisions made:**
- Results computed **on close only** (not live during voting)
- STV config stored in **dedicated columns** (stv_seats, stv_method, stv_quota) via migration
- Round-by-round results stored in **custom_fields['stv_results']** (JSON)
- New `stv` poll type (separate from `ranked_choice`)

---

## All Files Created

| File | Purpose |
|------|---------|
| `db/migrate/20260209103119_add_stv_fields_to_polls.rb` | Adds stv_seats (integer), stv_method (string), stv_quota (string) columns to polls |
| `app/services/stv_count_service.rb` | Module entry point: dispatches to ScottishCounter or MeekCounter, extracts ballots from stances |
| `app/services/stv_count_service/scottish_counter.rb` | WIGM algorithm: fixed quota, fractional surplus transfer (transfer_value = surplus/total), full-weight elimination transfer |
| `app/services/stv_count_service/meek_counter.rb` | Iterative method: keep_values per candidate, recomputes quota each iteration, converges to OMEGA=1e-7 |
| `app/services/stv_count_service/quota_calculator.rb` | Droop: floor(votes/(seats+1))+1, Hare: votes/seats |
| `vue/src/components/poll/stv/vote_form.vue` | Drag-drop ranked ballot for all candidates (no minimum, no "none of the above") |
| `vue/src/components/poll/stv/chart_panel.vue` | Round-by-round results table with elected (green), eliminated (red/strikethrough), inactive (faded) styling |
| `test/services/stv_count_service_test.rb` | 19 tests: quota calculator, scottish (6 tests), meek (4 tests), edge cases (3 tests), integration (2 tests) |
| `../loomio-docs/en/src/user_manual/polls/stv/index.md` | Full user documentation |
| `app/views/event_mailer/poll/results/stv.rb` | Email STV results: winners table, method/quota info, round-by-round table with green/red/faded styling, quota footer |
| `app/views/chatbot/matrix/stv.rb` | Matrix chatbot STV results: winners table, round-by-round table with checkmark/cross markers, method/quota info, link to full results |

## All Files Modified

| File | What changed |
|------|-------------|
| `config/poll_types.yml` | Added `stv` type definition (vote_method: ranked_choice, min_options: 2, no none_of_the_above) |
| `config/poll_templates.yml` | Added `stv` template entry (process_name, subtitle, introduction, title, details i18n keys) |
| `app/models/poll.rb` | Added `result_columns` case for 'stv' → `%w[chart name stv_status voter_count]`, `stv_results`/`stv_results=` accessors on custom_fields |
| `app/models/permitted_params.rb` | Added `:stv_seats, :stv_method, :stv_quota` to poll_attributes |
| `app/models/group.rb` | Added `'stv' => 9` to poll_template_positions, bumped meeting to 10 |
| `app/models/stance_choice.rb` | Extended `rank` method to handle `stv` poll type: `poll_options.count - score + 1` |
| `app/serializers/poll_serializer.rb` | Added `stv_seats, stv_method, stv_quota, stv_results` to attributes; `stv_results` method with `include_stv_results?` guard (requires closed + show_results) |
| `app/services/poll_service.rb` | `do_closing_work`: runs StvCountService.count and stores in custom_fields before setting closed_at. `reopen`: clears stv_results. `calculate_results`: early return to `calculate_stv_results` for STV. New `calculate_stv_results` class method returns per-candidate results with stv_status (elected/not_elected/pending) |
| `app/views/discussions/stance_body.rb` | Added `render_stv` method (delegates to `render_ranked_choice`) for STV stance display in discussion threads |
| `app/views/event_mailer/poll/results_panel.rb` | Routes `poll_type == "stv"` to dedicated `Results::Stv` view |
| `app/views/event_mailer/poll/results/simple.rb` | Added `stv_status` column handling (header + data cell with green/grey styling) as fallback |
| `app/views/event_mailer/poll/stance_choices.rb` | Added `stv` case for ranking display: `rank = poll_options.count - score + 1` |
| `app/views/event_mailer/poll/poll_option.rb` | Added `stv` case to `render_icon`: shows `#rank` numbers like ranked_choice but using `poll_options.count - score + 1` |
| `app/views/chatbot/matrix/results.rb` | Routes `poll_type == "stv"` to dedicated `Matrix::Stv` view |
| `app/views/chatbot/matrix/simple.rb` | Added `stv_status` column handling (header + data cell) as fallback |
| `app/views/chatbot/markdown/concerns.rb` | Added `render_stv_table` method: winners Terminal::Table, round-by-round Terminal::Table with checkmark/cross markers, quota footer, method/quota info, link to full results. Added `stv_format_number` helper. Routes STV in `render_results`. Added `stv_status` to `simple_heading_for`/`simple_cell_for`. |
| `app/views/chatbot/slack/concerns.rb` | Routes `poll_type == "stv"` to `render_stv_table` in `render_slack_results` |
| `app/helpers/dev/fake_data_helper.rb` | Added `stv: options` to `option_names`. Added STV config to `fake_poll` (stv_seats: 2, stv_method: 'scottish', stv_quota: 'droop', minimum_stance_choices: 1). Added `'stv'` to `fake_score` (same as ranked_choice: `index + 1`). |
| `app/helpers/dev/scenarios_helper.rb` | `poll_outcome_created_scenario` and `poll_outcome_review_due_scenario`: manually compute STV results after creating stances (since pre-closed polls skip `do_closing_work`) |
| `app/controllers/dev/polls_controller.rb` | `create_activity_items`: added `stv: %w[alice bob carol dave]` options, STV-specific attrs (stv_seats/method/quota) on both poll creations, hash-style vote choices with scores for ranked/stv/score/dot_vote polls |
| `app/views/dev/main/index.html.haml` | Added `stv` to `poll_types` array so STV scenarios appear on the dev index page |
| `vue/src/components.js` | Registered `PollStvVoteForm: 'poll/stv/vote_form'` |
| `vue/src/components/poll/common/directive.vue` | Imported and locally registered `PollStvVoteForm` as `'poll-stv-vote-form'` (CRITICAL: without this, falls back to multi-choice form) |
| `vue/src/components/poll/common/form.vue` | Added STV config section: seats number input, method select (scottish/meek), quota select (droop/hare). Added `stvMethodItems` and `stvQuotaItems` arrays. |
| `vue/src/components/poll/common/chart/panel.vue` | Imported `PollStvChartPanel`, renders it when `poll.pollType == 'stv'` instead of generic chart table |
| `vue/src/components/poll/common/choose_template.vue` | Added `'stv'` to the poll category filter: `{$in: ['score', 'poll', 'ranked_choice', 'dot_vote', 'stv']}` |
| `vue/src/shared/models/poll_model.js` | Added defaults: `stvSeats: 1, stvMethod: 'scottish', stvQuota: 'droop', stvResults: null` |
| `config/locales/client.en.yml` | Added: `poll_types.stv`, `decision_tools_card.stv_title`, `poll_common.status`, `poll_common_form.voting_methods.stv/stv_hint`, `poll_stv_vote_form.*`, `poll_stv_form.*` (settings), `poll_stv_results.*` (results panel including `candidate`, `view_full_results`) |
| `config/locales/server.en.yml` | Added `poll_templates.stv.*` (process_subtitle, process_introduction, title, details) |
| `../loomio-docs/en/src/SUMMARY.md` | Added `[STV Elections](user_manual/polls/stv/index.md)` nav entry |

---

## Key Architecture Notes

### Ballot extraction (StvCountService.extract_ballots)
- Reads `poll.stances.latest.decided` with `includes(:stance_choices)`
- Sorts stance_choices by `-score` (highest score = 1st preference, matching ranked_choice convention)
- Returns array of arrays: `[[option_id_1st, option_id_2nd, ...], ...]`

### Scottish counter (WIGM)
- Fixed quota calculated once from ballot count
- Tracks ballots as `{ prefs: [...], weight: Float }`
- `top_sitting_with(prefs, target_cid)` finds which candidate a ballot currently "sits with"
- Surplus transfer: `ballot.weight *= transfer_value` where `transfer_value = surplus / total_votes`
- Elimination: ballots naturally flow to next continuing pref on re-tally (weight unchanged)
- Tie-break: lowest id eliminated (deterministic)

### Meek counter
- Keep values per candidate (start 1.0, reduced on election, set to 0 on elimination)
- `distribute_votes`: each ballot's weight=1.0 flows through prefs, multiplied by keep_value at each step
- Iterates until convergence (`change < OMEGA` for all keep values)
- Quota recomputed from total active vote weight each iteration

### Results JSON structure (custom_fields['stv_results'])
```json
{
  "quota": 26, "seats": 3, "method": "scottish", "quota_type": "droop",
  "elected": [{ "poll_option_id": 5, "name": "Alice", "round_elected": 1 }],
  "rounds": [{
    "round": 1,
    "tallies": { "5": 30.0, "8": 20.0 },
    "elected": [5], "eliminated": [],
    "transfers": { "5": { "8": 1.5 } },
    "quota": 26
  }]
}
```

### Frontend component routing
- `directive.vue` must have STV vote form **locally imported and registered** — global registration in `components.js` alone is NOT sufficient because `this.$options.components` only checks local registrations.

### Stance ranking for STV
- `StanceChoice#rank` handles STV: `poll_options.count - score + 1` (different from ranked_choice which uses `minimum_stance_choices - score + 1`)
- STV vote form assigns score = numOptions - index (highest score = 1st preference)
- Email `poll_option.rb` and `stance_choices.rb` both use the same formula for rendering rank icons

### Dev scenarios
- `fake_poll` sets STV defaults: `stv_seats: 2, stv_method: 'scottish', stv_quota: 'droop', minimum_stance_choices: 1`
- `minimum_stance_choices: 1` is required so `fake_stance` doesn't generate empty choice sets (which fail `min_score` validation since STV has `validate_min_score: true, min_score: 1`)
- `create_activity_items` uses hash-style choices with scores for STV/ranked_choice/score/dot_vote (bare string choices default to score 0, failing min_score validation)
- Pre-closed scenarios (`poll_outcome_created`, `poll_outcome_review_due`) manually compute STV results since `do_closing_work` skips when `closed_at` is already set

### Email/chatbot views dispatch
- `discussions/stance_body.rb` uses `send(:"render_#{poll_type}")` — needs explicit `render_stv` method
- `event_mailer/poll/results_panel.rb` routes: meeting → Meeting, stv → Stv, else → Simple
- `chatbot/matrix/results.rb` routes: meeting → Meeting, stv → Stv, else → Simple
- `chatbot/markdown/concerns.rb` routes: meeting → `render_meeting_table`, stv → `render_stv_table`, else → `render_simple_table`
- `chatbot/slack/concerns.rb` routes: same pattern as markdown
- `stv_status` column handled in all simple/fallback views (email, matrix, markdown) for robustness

---

## Known Issues / Not Yet Done

- Pre-existing test errors (5) in MessageChannelService unrelated to STV
- Meek counter's quota calculation uses active vote total (may differ slightly from some reference implementations that use total ballots)
- Screenshots not yet added to documentation

## Testing

Run STV tests: `bin/rails test test/services/stv_count_service_test.rb`
Run full suite: `bin/rails test` (expect 0 failures, 5 pre-existing errors)

Dev scenario URLs:
- `http://localhost:3000/dev/polls/test_poll_scenario?poll_type=stv&scenario=poll_closed&format=compare`
- `http://localhost:3000/dev/polls/test_poll_scenario?poll_type=stv&scenario=poll_outcome_created&format=compare`
- `http://localhost:3000/dev/polls/test_poll_scenario?poll_type=stv&scenario=poll_created&format=email`
- All STV scenarios visible at `http://localhost:3000/dev/`
