angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    fetchAllNew: ->
      @fetchNew(per: 30).then (data) =>
        @fetchAllNew() if data.events.length >= 30

    fetchNew: (options) ->
      lastEvent = @recordStore.events.collection.chain().simplesort('id', true).limit(1).data()[0] || {id: 0}
      @fetch
        params: _.assign(options, {event_id_gt: lastEvent.id})

    fetchByDiscussion: (discussionKey, options = {}) ->
      options['discussion_key'] = discussionKey
      @fetch
        params: options

    findByDiscussionAndSequenceId: (discussion, sequenceId) ->
      @collection.chain()
                 .find(discussionId: discussion.id)
                 .find(sequenceId: sequenceId)
                 .data()[0] # so, turns out finding by multiple parameters doesn't actually work..
