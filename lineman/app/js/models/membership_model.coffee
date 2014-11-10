angular.module('loomioApp').factory 'MembershipModel', (RecordStoreService) ->
  class MembershipModel
    constructor: (data = {}) ->
      @id = data.id
      @groupId = data.group_id
      @userId = data.user_id

    plural: 'memberships'

    group: ->
      RecordStoreService.get('groups', @groupId)

    user: ->
      RecordStoreService.get('user', @userId)
