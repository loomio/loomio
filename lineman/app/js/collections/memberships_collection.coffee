angular.module('loomioApp').factory 'MembershipCollection', (BaseCollection) ->
  class MembershipCollection extends BaseCollection
    collectionName: 'memberships'
    indexes: ['primaryId', 'userId', 'groupId']
