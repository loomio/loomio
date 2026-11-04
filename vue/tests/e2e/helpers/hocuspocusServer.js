// Takes the collaboration server away and brings it back empty, to test
// clients while it is unavailable and after a restart. The server runs inside
// the Rails app; dev routes stop and start it.
const { execSync } = require('child_process')

const appPort = process.env.E2E_PORT || '3001'
const request = action => execSync(`curl -sf http://localhost:${appPort}/dev/hocuspocus_${action}`, { stdio: 'ignore' })

module.exports = {
  stop() { request('stop') },
  start() { request('start') },
}
