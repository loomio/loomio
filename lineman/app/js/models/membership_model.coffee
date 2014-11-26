angular.module('loomioApp').factory 'MembershipModel', (BaseModel) ->
  class MembershipModel extends BaseModel
    plural: 'memberships'

    hydrate: (data) ->
      @groupId = data.group_id
      @userId = data.user_id
      @followingByDefault = data.following_by_default

    params: ->
      membership:
        following_by_default: @followingByDefault

    group: ->
      @recordStore.groups.get(@groupId)

    user: ->
      @recordStore.users.get(@userId)
