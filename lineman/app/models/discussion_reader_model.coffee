angular.module('loomioApp').factory 'DiscussionReaderModel', (BaseModel) ->
  class DiscussionReaderModel extends BaseModel
    @singular: 'discussionReader'
    @plural: 'discussionReaders'
    @indices: ['id', 'discussionId']

    defaultValues: ->
      readItemsCount:  0
      readSalientItemsCount: 0
      readCommentsCount:  0
      lastReadAt: null
      volume: null
      lastReadSequenceId: -1

    initialize: (data) ->
      @baseInitialize(data)

      if data.discussion_id
        @id = data.discussion_id

    serialize: ->
      data = @baseSerialize()
      data.discussion_id = @id
      data

    discussion: ->
      @recordStore.discussions.find(@id)

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
        @restfulClient.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
        @lastReadSequenceId = sequenceId
