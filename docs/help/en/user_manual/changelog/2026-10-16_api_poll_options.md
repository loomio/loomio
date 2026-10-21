# Create polls with all their options through the API

JSON requests to the User API could lose poll options and the group ID, creating a direct poll instead of a poll in the intended group. Creating or editing a poll with JSON now preserves all supplied options and the group ID, with the same permissions as creating or editing the poll in Loomio.

The [User API documentation](/en/user_manual/integrations/api/user-api#create-a-draft-poll-with-many-options) includes cURL and JSON examples for creating draft polls with simple option names or detailed options with meanings and reason prompts. A poll without a closing date has voting disabled and remains visible to people who can read its thread.
