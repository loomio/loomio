describe 'ProposalModel', ->
  recordStore = null
  group = null
  discussion = null
  proposal = null
  voter1 = null
  voter2 = null
  vote1 = null
  vote2 = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    group = recordStore.groups.import(id: 1, name: 'group')
    discussion = recordStore.discussions.import(id: 1, group_id: group.id, title: 'discussion')
    proposal = recordStore.proposals.import(id: 1, discussion_id: discussion.id, name: 'proposal')
    voter1 = recordStore.users.import(id: 1, name: 'sam')
    voter2 = recordStore.users.import(id: 2, name: 'han')
    vote1 = recordStore.votes.import(id: 1, proposal_id: proposal.id, author_id: voter1.id)
    vote2 = recordStore.votes.import(id: 2, proposal_id: proposal.id, author_id: voter1.id)

  describe 'votes()', ->
    it 'returns votes', ->
      expect(proposal.votes()).toContain(vote1, vote2)

  describe 'isActive', ->
    it 'is true when closedAt', ->
      proposal.closedAt = "2014-11-18T00:49:39.046Z"
      expect(proposal.isActive()).toBe(false)

    it 'is true when closedAt', ->
      proposal.closedAt = null
      expect(proposal.isActive()).toBe(true)

  describe 'userHasVoted', ->
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
