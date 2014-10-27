angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordStoreService, @EventModel) ->

    subscribeTo: (eventSubscription) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consume(data) if data.event?

    consume: (data) ->
      event = new @EventModel(data.event)
      @RecordStoreService.put(event)
      @RecordStoreService.importRecords(data)
