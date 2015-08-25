describe 'ProposalModel', ->
  recordStore = null
  group = null
  discussion = null
  proposal = null
  voter1 = null
  voter2 = null
  vote1 = null
  vote2 = null
  undecidedMember = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    group = recordStore.groups.importJSON(id: 1, name: 'group')
    discussion = recordStore.discussions.importJSON(id: 1, group_id: group.id, title: 'discussion')
    proposal = recordStore.proposals.importJSON(id: 1, discussion_id: discussion.id, name: 'proposal')
    voter1 = recordStore.users.importJSON(id: 1, name: 'sam')
    voter2 = recordStore.users.importJSON(id: 2, name: 'han')
    undecidedMember =  recordStore.users.importJSON(id: 3, name: 'jam')
    recordStore.memberships.import(id: 1, userId: 1, groupId: 1)
    recordStore.memberships.import(id: 2, userId: 2, groupId: 1)
    recordStore.memberships.import(id: 3, userId: 3, groupId: 1)
    vote1 = recordStore.votes.importJSON(id: 1, proposal_id: proposal.id, author_id: voter1.id)
    vote2 = recordStore.votes.importJSON(id: 2, proposal_id: proposal.id, author_id: voter1.id)

  describe 'votes()', ->
    it 'returns votes', ->
      expect(proposal.votes()).toContain(vote1, vote2)

  describe 'voters()', ->
    it 'returns voters', ->
      expect(proposal.voters()).toContain(voter1, voter2)

  describe 'undecidedMembers()', ->
    it 'returns undecided members', ->
      expect(proposal.undecidedMembers()).toContain(undecidedMember)

    it 'does not return voters', ->
      expect(proposal.undecidedMembers()).not.toContain(voter1, voter2)

  describe 'isActive', ->
    it 'is true when closedAt', ->
      proposal.closedAt = "2014-11-18T00:49:39.046Z"
      expect(proposal.isActive()).toBe(false)

    it 'is true when closedAt', ->
      proposal.closedAt = null
      expect(proposal.isActive()).toBe(true)

  describe 'userHasVoted', ->
    # okokok
    it 'is false when the user has not voted', ->
      expect(proposal.userHasVoted({id: 2})).toBe(false)

    it 'is true when the user has voted', ->
      expect(proposal.userHasVoted({id: 1})).toBe(true)

  describe 'lastVoteByUser', ->
    it 'returns the most recent vote by the user', ->
      expect(proposal.lastVoteByUser(voter1)).toBe(vote2)

  describe 'uniqueVotes', ->
    it 'only returns one vote per user', ->
      expect(proposal.uniqueVotes().length).toEqual(1)
