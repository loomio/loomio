// The Rails test server that bin/e2e starts. Tests never target a
// development server, because dev scenarios reset and seed data.
export const port = process.env.E2E_PORT || '3001';
export const baseUrl = `http://localhost:${port}`;
