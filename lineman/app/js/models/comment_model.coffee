angular.module('loomioApp').factory 'CommentModel', (RecordStoreService) ->
  class CommentModel
    constructor: (data = {}) ->
      @id = data.id
      @author_id = data.author_id
      @parent_id = data.parent_id
      @body = data.body
      @liker_ids = data.liker_ids

    plural: 'comments'

    liker_names: ->
      _.map @likers(), (user) ->
        user.name

    likers: ->
      RecordStoreService.getAll('users', @liker_ids)

    author: ->
      RecordStoreService.get('users', @author_id)

    parent: ->
      RecordStoreService.get('comments', @parent_id)

    discussion: ->
      RecordStoreService.get('discussions', @discussion_id)

    author_name: ->
      @author().name

    author_avatar: ->
      @author().avatar_url
