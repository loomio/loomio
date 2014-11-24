angular.module('loomioApp').factory 'MembershipModel', (RecordStoreService, BaseModel) ->
  class MembershipModel extends BaseModel
    constructor: (data = {}) ->
      @id = data.id
      @groupId = data.group_id
      @userId = data.user_id
      @followingByDefault = data.following_by_default

    params: ->
      membership:
        following_by_default: @followingByDefault

    plural: 'memberships'

    group: ->
      RecordStoreService.get('groups', @groupId)

    user: ->
      RecordStoreService.get('user', @userId)
