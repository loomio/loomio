angular.module('loomioApp').factory 'MembershipModel', (BaseModel) ->
  class MembershipModel extends BaseModel
    @singular: 'membership'
    @plural: 'memberships'
    @indices: ['id', 'userId', 'groupId']
    @searchableFields: ['userName', 'userUsername']

    group: ->
      @recordStore.groups.find(@groupId)

    user: ->
      @recordStore.users.find(@userId)

    userName: ->
      @user().name

    userUsername: ->
      @user().username

    inviter: ->
      @recordStore.users.find(@inviterId)

