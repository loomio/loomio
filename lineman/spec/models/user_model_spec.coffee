describe 'UserModel', ->
  recordStore = null
  group = null
  membership = null
  user = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    user = recordStore.users.initialize(id: 1, name: 'sam')
    group = recordStore.groups.initialize(id: 1, name: 'pals')
    membership = recordStore.memberships.initialize(id:1, group_id: 1, user_id: 1)

  describe 'memberships', ->
    it 'lists users memberships', ->
      expect(user.memberships()).toContain(membership)

  describe 'groups', ->
    it 'returns groups the user belongs to', ->
      console.log 'groups', user.groups()
      expect(user.groups()).toContain(group)
      expect(user.groups().length).toBe 1

