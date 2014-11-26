angular.module('loomioApp').factory 'CommentCollection', (BaseCollection) ->
  class CommentCollection extends BaseCollection
    collectionName: 'comments'
    indexes: ['discussionId', 'authorId']
