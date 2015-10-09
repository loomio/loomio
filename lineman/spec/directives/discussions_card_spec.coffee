describe 'Discussions Card Component', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend) ->
    $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/discussions/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/memberships/).respond(200, {})
    @currentUser = @factory.create 'users'
    useCurrentUser @currentUser
    @group       = @factory.create 'groups'
    @membership  = @factory.create 'memberships', userId: @currentUser.id, groupId: @group.id, admin: true

  it 'passes the group', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', name: 'groupadoop'
    expect(@$scope.group.name).toBe('groupadoop')

  it 'displays no discussions if there are none', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: false
    expect(@$scope.whyImEmpty()).toBe('no_discussions_in_group')

  it 'displays no discussions if all discussions are private', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: true, discussion_privacy_options: 'private_only'
    expect(@$scope.whyImEmpty()).toBe('discussions_are_private')

  it 'displays no discussions if there are no public discussions', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: true, discussion_privacy_options: 'public_or_private'
    expect(@$scope.whyImEmpty()).toBe('no_public_discussions')

  it 'does not display how to gain access if there are no discussions', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: false, discussion_privacy_options: 'private_only'
    expect(@$scope.howToGainAccess()).toBe(null)

  it 'displays a link to join the group if membership is by approval', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: true, membership_granted_upon: 'approval'
    expect(@$scope.howToGainAccess()).toBe('request_membership')

  it 'displays a membership message if joining the group is by invitation and members can invite other members', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: true, membership_granted_upon: 'invitation', members_can_add_members: true
    expect(@$scope.howToGainAccess()).toBe('membership_is_invitation_only')

  it 'displays a membership message if joining the group is by invitation and members can invite other members', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @factory.create 'groups', has_discussions: true, membership_granted_upon: 'invitation', members_can_add_members: false
    expect(@$scope.howToGainAccess()).toBe('membership_is_invitation_by_admin_only')

  it 'displays a placeholder when there are no threads', ->
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showThreadsPlaceholder()).toBe(true)

  it 'displays a placeholder when there is only one thread', ->
    @factory.create 'discussions', groupId: @group.id
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showThreadsPlaceholder()).toBe(true)

  it 'does not display a placeholder when there are multiple threads', ->
    @factory.createMany 'discussions', { groupId: @group.id }, 2
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showThreadsPlaceholder()).toBe(false)

  it 'does not display a placeholder when the CurrentUser is not a coordinator', ->
    @membership.update admin: false
    prepareDirective @, 'discussions_card', { group: 'group' }, (parent) =>
      parent.group = @group
    expect(@$scope.showThreadsPlaceholder()).toBe(false)
