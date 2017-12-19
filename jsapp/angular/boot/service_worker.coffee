if document.location.protocol.match(/https/) && navigator.serviceWorker?
  navigator.serviceWorker.register(document.location.origin + '/service-worker.js', scope: './')
