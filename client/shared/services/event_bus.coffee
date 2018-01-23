ImplementationService = require 'shared/services/implementation_service.coffee'

module.exports = class EventBus
  ImplementationService.requireMethod @, 'emit',      'setEmitMethod'
  ImplementationService.requireMethod @, 'broadcast', 'setBroadcastMethod'
  ImplementationService.requireMethod @, 'listen',    'setListenMethod'

  # NB: I don't really want to support '$watch' going forward; we can find better ways I think
  ImplementationService.allowMethod   @, 'watch',     'setWatchMethod'
