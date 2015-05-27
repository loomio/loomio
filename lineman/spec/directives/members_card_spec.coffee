describe 'Members Card Component', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend) ->
    $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/memberships/).respond(200, {})
    @currentUser = @factory.create 'users'
    @group       = @factory.create 'groups', name: 'whoopdeedoo'
    @membership  = @factory.create 'memberships', userId: @currentUser.id, groupId: @group.id, admin: true
    window.useCurrentUser @currentUser

  it 'passes the group', ->
    prepareDirective @, 'members_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.group.name).toBe('whoopdeedoo')

  it 'displays a placeholder when there are no other memberships', ->
    prepareDirective @, 'members_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showMembersPlaceholder()).toBe(true)

  it 'does not display a placeholder when there are other memberships', ->
    @factory.create 'memberships', userId: @factory.create('users').id, groupId: @group.id
    prepareDirective @, 'members_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showMembersPlaceholder()).toBe(false)

  it 'does not display a placeholder when the CurrentUser is not a coordinator', ->
    @membership.updateFromJSON admin: false
    prepareDirective @, 'members_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showMembersPlaceholder()).toBe(false)
