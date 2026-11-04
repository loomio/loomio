## Pagination for User API groups, webhooks, and thread items

Integrations can now retrieve groups, webhooks, and thread items in pages using `limit` and `offset`. These endpoints previously returned every matching record in one response. They now return up to 50 primary records by default, with a maximum page size of 500 and the full matching count in `meta.total`.

Existing integrations that read larger collections must fetch subsequent pages to retrieve all records. Group and webhook pages use ascending ID order; thread items use ascending sequence order. The complete thread Markdown endpoint continues to return the entire visible document in one response.

Access follows the API-key user's permissions: group discovery lists their memberships, webhook management requires group-administrator permission, and thread items require access to the thread. Search remains limited to 20 results, and participation reports return the complete requested report without pagination. See the [User API documentation](/en/user_manual/integrations/api/user-api#pagination) for the endpoint details.
