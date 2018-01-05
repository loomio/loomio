ImplementationService = require 'shared/services/implementation_service.coffee'

module.exports = class EventBus
  ImplementationService.requireMethod @, 'emit',      'setEmitMethod'
  ImplementationService.requireMethod @, 'broadcast', 'setBroadcastMethod'
  ImplementationService.requireMethod @, 'listen',    'setListenMethod'
