describe 'Subgroups Card Component', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend) ->
    $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/groups\/\d+\/subgroups/).respond(200, {})
    @currentUser = @factory.create 'users'
    @group       = @factory.create 'groups', name: 'whoopdeedoo'
    @membership  = @factory.create 'memberships', userId: @currentUser.id, groupId: @group.id, admin: true
    window.useCurrentUser @currentUser

  it 'passes the group', ->
    prepareDirective @, 'subgroups_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.group.name).toBe('whoopdeedoo')

  it 'displays a placeholder when there are no subgroups', ->
    prepareDirective @, 'subgroups_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showSubgroupsPlaceholder()).toBe(true)

  it 'does not display a placeholder when there are subgroups', ->
    @factory.create 'groups', parentId: @group.id
    prepareDirective @, 'subgroups_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showSubgroupsPlaceholder()).toBe(false)

  it 'does not display a placeholder when the CurrentUser is not a coordinator', ->
    @membership.update admin: false
    @factory.create 'groups', parentId: @group.id
    prepareDirective @, 'subgroups_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showSubgroupsPlaceholder()).toBe(false)
