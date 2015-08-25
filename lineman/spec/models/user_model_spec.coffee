describe 'UserModel', ->
  recordStore = null
  group = null
  membership = null
  user = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    user = recordStore.users.import(id: 1, name: 'sam')
    group = recordStore.groups.import(id: 1, name: 'pals')
    membership = recordStore.memberships.import(id:1, groupId: 1, userId: 1)

  describe 'memberships', ->
    it 'lists users memberships', ->
      expect(user.memberships()).toContain(membership)

  describe 'membershipFor', ->
    it 'returns the membership of the user and group', ->
      expect(user.membershipFor(group)).toBe(membership)

  describe 'groups', ->
    it 'returns groups the user belongs to', ->
      expect(user.groups()).toContain(group)
      expect(user.groups().length).toBe 1

