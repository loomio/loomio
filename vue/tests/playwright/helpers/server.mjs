// The Rails test server that bin/e2e starts.
export const port = process.env.E2E_PORT || (process.env.RAILS_ENV === 'test' ? '3001' : '8080');
export const baseUrl = `http://localhost:${port}`;
