angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordStoreService, @EventModel) ->

    subscribeTo: (eventSubscription, callback) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consume(data, callback) if data.event?

    consume: (data, callback) ->
      event = new @EventModel(data.event)

      event.discussion().eventIds.push event.id
      @RecordStoreService.put(event)
      @RecordStoreService.importRecords(data)

      callback()
