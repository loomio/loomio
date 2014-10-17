angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordStoreService, @EventModel) ->

    subscribeTo: (eventSubscription, onEvent) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        if data.event?
          @consume(data)
          onEvent(data.event)

    consume: (data) ->
      event = new @EventModel(data.event)

      event.discussion().eventIds.push event.id
      @RecordStoreService.put(event)
      @RecordStoreService.importRecords(data)
