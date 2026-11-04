# Group deletion and account-merge safeguards

Restoring a group cancels its previously scheduled deletion, even if the group is archived again later. Group deletion permissions are unchanged.

If an account merge fails, memberships, direct-topic access, and sign-in credentials are restored with the rest of the account changes. Cleanup also preserves comments with missing timeline entries when their parent content still exists.

Accounts with no durable ownership, content, membership, access, identity, or notification references are deleted after 60 days without activity. Instance administrator accounts are excluded from automatic deletion.
