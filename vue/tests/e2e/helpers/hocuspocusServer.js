// Stops and restarts the hocuspocus server that bin/e2e started, to test
// clients while it is unavailable and after it returns with no documents.
// bin/e2e kills whatever listens on the port when the run ends.
const { execSync, spawn } = require('child_process')
const path = require('path')

const port = process.env.HOCUSPOCUS_PORT || '4445'
const appPort = process.env.E2E_PORT || '3001'
const serverPath = path.resolve(__dirname, '../../../../hocuspocus/server.mjs')

const listening = () => {
  try {
    execSync(`nc -z localhost ${port}`, { stdio: 'ignore' })
    return true
  } catch (_) {
    return false
  }
}

const waitFor = (condition, description) => {
  const deadline = Date.now() + 10000
  while (!condition()) {
    if (Date.now() > deadline) throw new Error(`hocuspocus did not ${description} within 10 seconds`)
    execSync('sleep 0.2')
  }
}

module.exports = {
  stop() {
    const pids = execSync(`lsof -ti tcp:${port} -sTCP:LISTEN || true`).toString().trim().split('\n').filter(Boolean)
    pids.forEach(pid => process.kill(Number(pid)))
    waitFor(() => !listening(), 'stop')
  },

  start() {
    if (listening()) return
    spawn('node', [serverPath], {
      env: { ...process.env, APP_URL: `http://localhost:${appPort}`, HOCUSPOCUS_PORT: port },
      detached: true,
      stdio: 'ignore',
    }).unref()
    waitFor(listening, 'start')
  },
}
