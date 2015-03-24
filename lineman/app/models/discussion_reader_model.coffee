angular.module('loomioApp').factory 'DiscussionReaderModel', (BaseModel) ->
  class DiscussionReaderModel extends BaseModel
    @singular: 'discussionReader'
    @plural: 'discussionReaders'
    @indices: 'discussionId'

    initialize: (data) ->
      @readItemsCount = 0
      @readSalientItemsCount = 0
      @readCommentsCount = 0
      @lastReadAt = null
      @volume = null
      @lastReadSequenceId = -1 # 0 means context is read, neg 1 means never seen discussion
      if data.discussion_id?
        @id = data.discussion_id
        _.extend data,
          id:       @discussion().id
          group_id: @discussion().groupId
      @updateFromJSON(data)

    serialize: ->
      data = @baseSerialize()
      data.discussion_id = @id
      data

    discussion: ->
      @recordStore.discussions.find(@id)

    changeVolume: (volume) ->
      @volume = volume
      @save()

    markAsRead: (sequenceId) ->
      sequenceId = @discussion().lastSequenceId if isNaN(sequenceId)
      if @lastReadSequenceId < sequenceId
        @restfulClient.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
