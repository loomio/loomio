angular.module('loomioApp').service 'EventService',
  class EventService
    constructor: (@RecordStoreService) ->

    subscribeTo: (eventSubscription, onEvent) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consumeEventFromResponseData(data)
        onEvent(event)

    consumeEventFromResponseData: (data) ->
      event = data.event
      stored_event = @RecordCacheService.get('events', event.id)
      unless stored_event?
        @RecordCacheService.consumeSideLoadedRecords(data)
        @RecordCacheService.hydrateRelationshipsOn(event)
        @RecordCacheService.put('events', event.id, event)
        @play(event)

    play: (event) ->
      switch event.kind
        when 'new_comment'
          discussion = @RecordCacheService.get('discussions', event.discussion_id)
          discussion.events = [] unless discussion.events?
          discussion.events.push event
          discussion.last_comment_at = event.comment.created_at
        when 'new_motion'
          discussion = @RecordCacheService.get('discussions', event.discussion_id)
          discussion.events = [] unless discussion.events?
          discussion.events.push event
          discussion.active_proposal = event.proposal
          discussion.proposals = [] unless discussion.proposals?
          discussion.proposals.push(event.proposal)
        when 'new_vote'
          proposal = @RecordCacheService.get('proposals', event.proposal_id)
          proposal.votes = [] unless proposal.votes?
          proposal.votes.push event.vote
          proposal.recountVotes()

