describe 'DiscussionModel', ->
  discussion = null
  discussionReader = null
  author = null
  recordStore = null
  proposal = null
  group = null
  event = null
  otherEvent = null
  comment = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    group = recordStore.groups.initialize(id: 1, name: 'group')
    discussion = recordStore.discussions.initialize(id: 1, group_id: group.id, title: 'Hi', created_at: "2015-01-01T00:00:00Z" )

    author = recordStore.users.initialize(id: 1, name: 'Sam')
    event = recordStore.events.initialize(id: 1, sequence_id: 1, discussion_id: 1)
    otherEvent = recordStore.events.initialize(id: 2, sequence_id: 2, discussion_id: 2)
    discussionReader = recordStore.discussionReaders.initialize(discussion_id: 1)

  describe 'author()', ->
    it 'returns the discussion author', ->
      discussion.authorId = author.id
      expect(discussion.author()).toBe(author)

  describe 'comments()', ->
    beforeEach ->
      comment = recordStore.comments.initialize(id:5, discussion_id: discussion.id)

    it 'returns comments', ->
      expect(discussion.comments()).toContain(comment)

  describe 'proposals()', ->
    beforeEach ->
      proposal = recordStore.proposals.initialize(id:7, discussion_id: discussion.id)
      #proposal = recordStore.proposals.initialize(id:7, discussion_id: discussion.id)
      #proposal = recordStore.proposals.initialize(id:7, discussion_id: discussion.id)
      #console.log proposal
      #console.log _.map(discussion.proposals(), (p) -> p.id)

    it 'returns proposals', ->
      expect(discussion.proposals()).toContain(proposal)
      expect(discussion.proposals().length).toBe(1)

  describe 'group()', ->
    it 'returns its group', ->
      expect(discussion.group()).toBe(group)

  describe 'events()', ->
    it 'returns events for the discussion', ->
      expect(discussion.events()).toContain(event)

    it 'does not return events for another discussion', ->
      expect(discussion.events()).not.toContain(otherEvent)

  describe 'reader', ->
    it "returns the discussion reader associated with this discussion", ->
      expect(discussion.reader()).toBe(discussionReader)
