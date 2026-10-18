# Code style and domain invariants

## Code style

- Take selective lessons from [TigerStyle](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md), especially naming:
  - Put the most significant word first, then qualifiers/units in descending significance. Prefer names like `comment_length_max` over `max_comment_length`, so related names group together.
  - Choose related names with the same length where practical, especially pairs like `min` and `max`, so code lines up and comparisons are easier to scan.
  - Name state markers for what they mean: use past-tense names such as `was_imported` when a boolean records historical origin, rather than implying it is the current mode. Name event predicates in past tense, such as `did_close_legacy_anonymous_voting?`, when they detect a completed change.
- **Fix invariants at the shared method, not at each call site.** If several callers guard a shared method the same way (e.g. `TagService.authorize_create_tag_names!(discussion.group, ...)` from `discussion_service.rb`, `poll_service.rb`, and `topic_service.rb` all need to no-op for group-less/direct records), add the guard inside the shared method (`return if group.blank?`) instead of repeating it at every call site. Only reach for a call-site guard when the condition is truly specific to that one caller.
- **Prefer coercion over presence guards when the callee already handles the empty case.** If a method already treats `nil`/`[]` as a no-op, call it unconditionally with `Array(value)` rather than wrapping the call in `if params.key?(:x)`. Only add a conditional when the callee can't safely handle the absent/empty case itself.
- **Trust contracts we own.** When Loomio controls both the producer and consumer of a value, express the established contract directly rather than adding speculative optional chaining, fallbacks, coercions, or race handling for unsupported shapes and states. If a contract violation needs diagnostics, check and report each known invariant separately so the code identifies what failed instead of collapsing unrelated possibilities into one defensive expression.
- **Keep model service operations atomic.** When a service operation changes domain records and creates a corresponding event, wrap the model changes, dependent records, derived database state, and event creation in one database transaction. Publish realtime messages and perform other non-database side effects only after the transaction commits, so failed event creation cannot leave partial records or broadcast rolled-back state.
- **Document complex methods that are more than framework boilerplate.** Add a concise high-level comment explaining the problem, important invariants, and non-obvious decisions or phases. Comment decision points where the reason is not evident from the code. Do not narrate straightforward Ruby or Rails operations line by line.
- **Page with `limit` and `offset`.** The `from` and `per` parameters are deprecated: keep supporting them where they are already established, but use `limit` and `offset` in all new API endpoints and client code. In API controllers, page new endpoints with `page_collection_bounded`, which reads only `limit` and `offset` and caps the page size. Order paged queries by a unique tiebreak (such as `id`) so rows do not repeat or disappear between pages.

## Phlex / Mailers

- Write new Rails views and mailer views as Phlex components under `app/views`, not ERB templates.
- Do not add separate text templates for mailers; the plain-text version is generated automatically from the HTML email.

## Null objects

- When adding a method to `User` or `Group`, also add the corresponding method to the null object (`LoggedOutUser` or `NullGroup`) so logged-out and nil-group paths do not raise `NoMethodError`.
- Treat `Topic#group` as a total interface: it returns either a `Group` or `NullGroup`. Call the shared group API directly; do not add `&.`, `respond_to?`, truthiness checks, or fallback objects around `topic.group`. Use `topic.group_id`, `group.present?`, or `group.blank?` only when behavior genuinely differs between group and direct topics.
- Created discussions, polls, and topic readers must have a topic. Trust that invariant on persisted and normal service-built records so missing topics fail visibly. Guard a missing topic only where the code explicitly handles raw unsaved/invalid records, optional controller inputs, or legacy/orphan recovery.
- Give null-object predicates boolean results, collection methods empty relations or collections of the expected type, and lookup methods the same signature as the real object. Prefer an explicit method when its contract is important or not obvious from the generated null-method lists.
- Do not add silent no-op mutation methods to a null object merely to make an invalid call succeed. Branch explicitly when an operation only makes sense for a real user or group.
- Test both the real-object and null-object behavior when extending their shared interface, including the direct-topic path for `NullGroup` changes.
