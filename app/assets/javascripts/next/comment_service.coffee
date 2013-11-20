angular.module('loomioApp').factory 'Comment', ($resource) ->
  class Comment
    constructor: (discussionId) ->
      @service = $resource '/api/discussions/:discussion_id/comments/:id',
        {discussion_id: discussionId, id: '@id'}

    create: (attrs) ->
      new @service(comment: attrs).$save (comment) ->
        attrs.id = comment.id
      attrs

    all: ->
      @service.query()
