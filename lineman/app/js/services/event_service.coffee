angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordCacheService) ->

    subscribeTo: (eventSubscription, onEvent) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consumeEventFromResponseData(data)
        onEvent(event)

    consumeEventFromResponseData: (data) ->
      event = data.event
      @RecordCacheService.consumeSideLoadedRecords(data)
      @RecordCacheService.hydrateRelationshipsOn(event)
      @RecordCacheService.put('events', event.id, event)
      @play(event)
      event

    play: (event) ->
      switch event.kind
        when 'new_comment'
          discussion = @RecordCacheService.get('discussions', event.discussion_id)
          discussion.events.push event
          console.log "EventService pushed event onto discussion:",  event
          discussion.last_comment_at = event.comment.created_at
        when 'new_motion'
          discussion = @RecordCacheService.get('discussions', event.discussion_id)
          discussion.events.push event
          discussion.active_proposal = event.proposal
          discussion.proposals = [] unless discussion.proposals?
          discussion.proposals.push(event.proposal)

