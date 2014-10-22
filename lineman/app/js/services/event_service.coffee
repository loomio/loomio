angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordStoreService, @EventModel) ->

    subscribeTo: (eventSubscription, callback) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consume(data, callback) if data.event?

    consume: (data, onConsumed) ->
      event = new @EventModel(data.event)
      @RecordStoreService.put(event)
      @RecordStoreService.importRecords(data)
      onConsumed()
