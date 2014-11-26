angular.module('loomioApp').factory 'UserCollection', (BaseCollection) ->
  class UserCollection extends BaseCollection
    collectionName: 'users'
    indexes: ['primaryId']

