angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    removeFromThread: (event) ->
      @remote.patchMember(event.id, 'remove_from_thread').then -> event.remove()

    fetchByDiscussion: (discussionKey, options = {}) ->
      options['discussion_key'] = discussionKey
      @fetch
        params: options

    findByDiscussionAndSequenceId: (discussion, sequenceId) ->
      @collection.chain()
                 .find(discussionId: discussion.id)
                 .find(sequenceId: sequenceId)
                 .data()[0] # so, turns out finding by multiple parameters doesn't actually work..
