angular.module('loomioApp').factory 'GroupCollection', (BaseCollection) ->
  class GroupCollection extends BaseCollection
    collectionName: 'groups'
    indexes: ['primaryId', 'parentId']

