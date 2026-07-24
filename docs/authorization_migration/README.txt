This directory is the source of truth for the CanCan to Pundit migration.
Chat history is not required to resume the work.

START OR RESUME

1. git switch pundit
2. bin/pundit-migration-status --check
3. Read decisions.txt and unresolved entries in findings.txt.
4. Open the tracker named first under "Next".
5. Resume a partially migrated action before starting an inventoried action.
6. Run that action's existing focused tests before editing it.

The status command deliberately exits 1 while valid migration or review work
remains. Exit 2 means the route snapshot or tracker is inconsistent and must be
fixed before migrating an action.

BEFORE STOPPING

1. Record the action's real current status in its controller tracker.
2. Record open questions and incomplete tests in the action's notes.
3. Add newly discovered security problems to findings.txt.
4. Run bin/pundit-migration-status --update.
5. Run the focused tests for the current action.
6. Leave an action at its actual intermediate status; never mark it complete
   merely to make the count move.

COMMANDS

  bin/pundit-migration-status
    Fast status from the committed route snapshot. Does not boot Rails.

  bin/pundit-migration-status --remaining
    Machine-readable ordered list of unfinished actions. Partially migrated
    actions appear before untouched actions.

  bin/pundit-migration-status --check
    Boots Rails and compares live routes with routes.tsv. Use in CI and before
    committing.

  bin/pundit-migration-status --update
    Regenerates routes.tsv and coverage.txt, creates missing action trackers,
    and preserves existing tracker evidence.

FILES

  ../../PUNDIT_MIGRATION_PLAN.md
    Architecture, invariants, migration phases, test matrices, and completion
    criteria.

  routes.tsv
    Generated route snapshot. Do not edit it by hand.

  coverage.txt
    Generated status at the last --update.

  controllers/*.txt
    Durable action-by-action state and evidence. These are the primary work
    records.

  decisions.txt
    Architecture and deliberate behaviour decisions that future actions must
    preserve.

  findings.txt
    Security defects discovered while characterizing actions.

  exceptions.txt
    Reviewed dispositions for generated, mounted, and development-only actions.
    These reviews must be complete before CanCan is removed.

TRACKER RULE

An action and its tracker change together. "complete" requires policy, request,
negative, and composition evidence, a reviewed decision-difference entry, a
verification date, and a commit reference. Use "this commit" while preparing
the action's own commit.
