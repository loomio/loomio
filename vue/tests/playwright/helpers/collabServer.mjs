// Takes the collaboration server away and brings it back empty, to test
// clients while it is unavailable and after a restart. The server runs inside
// the Rails app; dev routes stop and start it in the Puma worker that serves
// the request, so E2E runs use one worker.
import { baseUrl } from './server.mjs';

async function request(action) {
  const response = await fetch(`${baseUrl}/dev/collab_server_${action}`);
  if (!response.ok) throw new Error(`collab_server_${action} returned ${response.status}`);
}

export const stopCollabServer = () => request('stop');
export const startCollabServer = () => request('start');
