angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordCacheService) ->

    consumeEventFromResponseData: (data) ->
      event = data.event
      @RecordCacheService.consumeSideLoadedRecords(data)
      @RecordCacheService.hydrateRelationshipsOn(event)
      @RecordCacheService.put('events', event.id, event)
      @play(event)

    play: (event) ->
      switch event.kind
        when 'new_comment'
          console.log event
          discussion = @RecordCacheService.get('discussions', event.discussion_id)
          console.log discussion
          discussion.events.push event
          discussion.last_comment_at = event.comment.created_at
        when 'new_motion'
          discussion = @RecordCacheService.get('discussions', event.discussion_id)
          discussion.events.push event
          discussion.active_proposal = event.proposal
          discussion.proposals = [] unless discussion.proposals?
          discussion.proposals.push(event.proposal)

