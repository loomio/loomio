angular.module('loomioApp').factory 'MembershipModel', (BaseModel) ->
  class MembershipModel extends BaseModel
    @singular: 'membership'
    @plural: 'memberships'
    @indices: ['id', 'userId', 'groupId']
    @searchableFields: ['userName', 'userUsername']

    relationships: ->
      @belongsTo 'group'
      @belongsTo 'user'
      @belongsTo 'inviter', from: 'users'

    userName: ->
      @user().name

    userUsername: ->
      @user().username
