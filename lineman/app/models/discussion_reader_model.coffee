angular.module('loomioApp').factory 'DiscussionReaderModel', (BaseModel) ->
  class DiscussionReaderModel extends BaseModel
    @singular: 'discussionReader'
    @plural: 'discussionReaders'
    @indices: ['id', 'discussionId']
    @serializableAttributes: window.Loomio.permittedParams.discussion_reader

    defaultValues: ->
      readItemsCount:  0
      readSalientItemsCount: 0
      readCommentsCount:  0
      lastReadAt: null
      volume: null
      lastReadSequenceId: -1

    relationships: ->
      @belongsTo 'discussion', by: 'id'

    changeVolume: (volume) ->
      @volume = volume
      @save()

    toggleStar: ->
      @starred = !@starred
      @save()

    markAsRead: (sequenceId) ->
      if isNaN(sequenceId)
        sequenceId = @discussion().lastSequenceId

      if _.isNull(@lastReadAt) or @lastReadSequenceId < sequenceId
        @remote.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
        @lastReadSequenceId = sequenceId
