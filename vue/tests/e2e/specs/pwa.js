pageHelper = require('../helpers/pageHelper')

module.exports = {
  'registers_the_push_worker_and_serves_home_screen_metadata': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_group')
    page.expectElement('.group-page')

    test.executeAsync((done) => {
      const manifestLink = document.querySelector('link[rel="manifest"]')
      Promise.all([
        fetch(manifestLink.href).then(async (response) => {
          const manifest = await response.json()
          const maskableIcon = manifest.icons.find((icon) => icon.purpose === 'maskable')
          const iconResponse = await fetch(maskableIcon.src)
          return { manifest, maskableIconAvailable: iconResponse.ok }
        }),
        navigator.serviceWorker.register('/service-worker.js').then(() => navigator.serviceWorker.ready)
      ]).then(([manifestResult, registration]) => done({
        manifestHref: manifestLink.getAttribute('href'),
        manifest: manifestResult.manifest,
        maskableIconAvailable: manifestResult.maskableIconAvailable,
        workerScriptUrl: registration.active && registration.active.scriptURL
      })).catch((error) => done({ error: error.message }))
    }, [], ({ value }) => {
      test.assert.equal(value.error, undefined)
      test.assert.equal(value.manifestHref, '/manifest')
      test.assert.equal(value.manifest.id, '/')
      test.assert.equal(value.manifest.scope, '/')
      test.assert.equal(value.manifest.display, 'standalone')
      test.assert.ok(value.manifest.icons.some((icon) => icon.purpose === 'maskable'))
      test.assert.equal(value.maskableIconAvailable, true)
      test.assert.ok(value.workerScriptUrl.endsWith('/service-worker.js'))
    })
  }
}
