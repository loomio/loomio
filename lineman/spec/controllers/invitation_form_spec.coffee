describe 'InvitationFormController', ->
  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend, $routeParams) ->
    $httpBackend.whenGET(/api\/v1\/contacts/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/users\/invitables\//).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/discussions\/inbox/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/memberships\/my_memberships/).respond(200, {})

  beforeEach ->
    @currentUser = @factory.create 'users'
    @group       = @factory.create 'groups', name: 'whoopdeedoo'
    @membership  = @factory.create 'memberships', userId: @currentUser.id, groupId: @group.id, admin: true

    inject (AppConfig) ->
      AppConfig.currentUserId = @currentUser.id

  beforeEach inject (InvitationForm, $rootScope, Records, CurrentUser, AbilityService, LoadingService) ->
    @scope = $rootScope.$new()
    @controller = InvitationForm.controller(@scope, $rootScope, @group, Records, CurrentUser, AbilityService, LoadingService)
    @scope.fragmentIsValidEmail = -> false

  describe 'basics', ->
    it 'starts with no invitations', ->
      expect(@scope.invitations.length).toBe(0)
      expect(@scope.hasInvitations()).toBe(false)

    it 'tracks whether there are invitations or not', ->
      @scope.invitations.push { name: 'invite me!', subtitle: 'Pllleeeease!', count: 1 }
      expect(@scope.hasInvitations()).toBe(true)

    it 'tracks the invitation count', ->
      @scope.invitations.push { count: 1 }
      @scope.invitations.push { count: 5 }
      expect(@scope.invitationsCount()).toBe(6)

    it 'displays a maximum of 5 options at a time', ->
      @factory.create 'contacts', user_id: @currentUser.id for i in [0..13]
      expect(@scope.invitables().length).toBe(5)

  describe 'contacts', ->
    beforeEach ->
      @contact = @factory.create 'contacts', name: 'RickDazo', email: 'dick@razo.com', source: 'gmail', user_id: @currentUser.id

    it 'can find a contact with no search query', ->
      expect(@scope.invitables().length).toBe(1)
      expect(@scope.invitables()[0].name).toBe 'RickDazo'

    it 'displays a contact as an invitable if it matches the search query by name', ->
      @scope.fragment = 'dazo'
      expect(@scope.invitables().length).toBe(1)
      expect(@scope.invitables()[0].name).toBe 'RickDazo'

    it 'displays a contact as an invitable if it matches the search query by email', ->
      @scope.fragment = 'dick'
      expect(@scope.invitables().length).toBe(1)
      expect(@scope.invitables()[0].subtitle).toBe '<dick@razo.com> (gmail)'

    it 'does not display a contact as an invitable if it does not match the search query', ->
      @scope.fragment = 'rizzo'
      expect(@scope.invitables().length).toBe(0)

    it 'counts a contact as 1 invitation', ->
      @scope.addInvitation(@scope.invitables()[0])
      expect(@scope.invitationsCount()).toBe(1)

    it 'cannot double add a contact', ->
      @scope.addInvitation(@scope.invitables()[0])
      expect(@scope.invitables().length).toBe(0)

  describe 'users', ->
    beforeEach ->
      @user = @factory.create 'users', name: 'RickDazo', username: 'dazzricko'
      @someOtherGroup = @factory.create 'groups'
      @factory.create 'memberships', groupId: @someOtherGroup.id, userId: @user.id
      @factory.create 'memberships', groupId: @someOtherGroup.id, userId: @currentUser.id

    it 'can find a user with no search query', ->
      expect(_.pluck(@scope.invitables(), 'name')).toContain('RickDazo')

    it 'displays a user as an invitable if it matches the search query by name', ->
      @scope.fragment = 'dazo'
      expect(@scope.invitables().length).toBe(1)
      expect(@scope.invitables()[0].name).toBe 'RickDazo'

    it 'displays a user as an invitable if it matches the search query by email', ->
      @scope.fragment = 'dazz'
      expect(@scope.invitables().length).toBe(1)
      expect(@scope.invitables()[0].subtitle).toBe '@dazzricko'

    it 'does not display a user as an invitable if it does not match the search query', ->
      @scope.fragment = 'rizzo'
      expect(@scope.invitables().length).toBe(0)

    it 'counts a user as 1 invitation', ->
      @scope.invitableGroups = -> []
      @scope.addInvitation(@scope.invitables()[0])
      expect(@scope.invitationsCount()).toBe(1)

    it 'cannot double add a user', ->
      @scope.invitableGroups = -> []
      @scope.addInvitation(@scope.invitables()[0])
      @scope.fragment = 'rick'
      expect(_.pluck(@scope.invitables(), 'name')).not.toContain('RickDazo')

  describe 'groups', ->
    beforeEach ->
      @user = @factory.create 'users', name: 'RickDazo', username: 'dazzricko'
      @anotherUser = @factory.create 'users', name: 'DazRicko', username: 'rizzdacko'
      @someOtherGroup = @factory.create 'groups', name: 'An Extraordinary Carrot!', membershipsCount: 3
      @factory.create 'memberships', groupId: @someOtherGroup.id, userId: @user.id
      @factory.create 'memberships', groupId: @someOtherGroup.id, userId: @anotherUser.id
      @factory.create 'memberships', groupId: @someOtherGroup.id, userId: @currentUser.id

    it 'can find a group with no search query', ->
      expect(_.pluck(@scope.invitables(), 'name')).toContain('An Extraordinary Carrot!')

    it 'displays a group as an invitable if it matches the search query by name', ->
      @scope.fragment = 'carrot'
      expect(@scope.invitables().length).toBe(1)
      expect(@scope.invitables()[0].name).toBe 'An Extraordinary Carrot!'

    it 'does not display a group as an invitable if it does not match the search query', ->
      @scope.fragment = 'cabbage'
      expect(@scope.invitables().length).toBe(0)

    it 'counts group invitations as number of members', ->
      @scope.fragment = 'carrot'
      @scope.addInvitation(@scope.invitables()[0])
      expect(@scope.invitationsCount()).toBe(@someOtherGroup.membershipsCount)

    it 'cannot double add a group', ->
      @scope.addInvitation(@scope.invitables()[0])
      expect(_.pluck(@scope.invitables(), 'name')).not.toContain('An Extraordinary Carrot')

  describe 'email', ->
    it 'cannot double add an email', ->
      @scope.fragment = 'rickdazo@gmail.com'
      @scope.addInvitation(@scope.invitables()[0])
      @scope.fragment = 'rickdazo@gmail.com'
      expect(@scope.invitables().length).toBe(0)

  describe 'flash message', ->
    it 'displays a count of invitations sent', ->
      @scope.invitations.push { type: 'email' }
      @scope.invitations.push  { type: 'contact' }
      @scope.submit()
      expect(@scope.emailCount()).toBe(2)
      expect(@scope.successMessage()).toBe('invitation.messages.emails_sent')

    it 'displays a count of the members added', ->
      @scope.invitations.push { type: 'user' }
      @scope.invitations.push  { type: 'group', count: 3 }
      @scope.submit()
      expect(@scope.memberCount()).toBe(4)
      expect(@scope.successMessage()).toBe('invitation.messages.members_added')

    it 'displays a count of invitations sent and members added', ->
      @scope.invitations.push { type: 'email' }
      @scope.invitations.push  { type: 'user' }
      @scope.submit()
      expect(@scope.memberCount()).toBe(1)
      expect(@scope.emailCount()).toBe(1)
      expect(@scope.successMessage()).toBe('invitation.messages.members_added_and_emails_sent')
