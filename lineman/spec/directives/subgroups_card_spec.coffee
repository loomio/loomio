describe 'Subgroups Card Component', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend) ->
    $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/groups\/\d+\/subgroups/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/discussions/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/memberships/).respond(200, {})
    @currentUser = @factory.create 'users'
    @group       = @factory.create 'groups', name: 'whoopdeedoo'
    @membership  = @factory.create 'memberships', userId: @currentUser.id, groupId: @group.id, admin: true
    window.useCurrentUser @currentUser

  it 'passes the group', ->
    prepareDirective @, 'subgroups_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.group.name).toBe('whoopdeedoo')
