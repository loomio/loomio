angular.module('loomioApp').factory 'CommentStore', (BaseStore) ->
  new class CommentStore extends BaseStore
