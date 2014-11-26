angular.module('loomioApp').factory 'DiscussionCollection', (BaseCollection) ->
  class DiscussionCollection extends BaseCollection
    collectionName: 'discussions'
    indexes: ['primaryId', 'groupId']

