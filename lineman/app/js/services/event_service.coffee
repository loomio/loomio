angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordStoreService, @EventModel) ->

    subscribeTo: (eventSubscription) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consume(data) if data.event?

    consume: (data) ->
      event = new @EventModel(data.event)

      switch event.kind
        when 'new_comment' then event.discussion().eventIds.push event.id
        when 'new_motion'  then event.discussion().activeProposalId = event.proposalId

      @RecordStoreService.put(event)
      @RecordStoreService.importRecords(data)
