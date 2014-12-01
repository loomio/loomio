angular.module('loomioApp').factory 'MembershipModel', (BaseModel) ->
  class MembershipModel extends BaseModel
    @singular: 'membership'
    @plural: 'memberships'
    @indexes: ['userId', 'groupId']

    initialize: (data) ->
      @id = data.id
      @groupId = data.group_id
      @userId = data.user_id
      @followingByDefault = data.following_by_default
      @admin = data.admin

    serialize: ->
      membership:
        group_id: @groupId
        following_by_default: @followingByDefault

    group: ->
      @recordStore.groups.get(@groupId)

    user: ->
      @recordStore.users.get(@userId)
