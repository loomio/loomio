# Server API requires Bearer authentication

The server API (`/api/b3`) now accepts its `B3_API_KEY` only in the `Authorization: Bearer` header. API keys supplied in query strings or request bodies are rejected.

Server operators should update all server API integrations to use the Bearer header before upgrading.
