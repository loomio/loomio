angular.module('loomioApp').factory 'DiscussionReaderModel', (BaseModel) ->
  class DiscussionReaderModel extends BaseModel
    @singular: 'discussionReader'
    @plural: 'discussionReaders'
    @indices: 'discussionId'

    initialize: (data) ->
      @readItemsCount = 0
      @readCommentsCount = 0
      @lastReadAt = null
      @following = null
      @lastReadSequenceId = -1 # 0 means context is read, neg 1 means never seen discussion
      data.id = data.discussion_id if data.discussion_id?
      @updateFromJSON(data)

    serialize: ->
      data = @baseSerialize()
      data.discussion_id = @id
      data
