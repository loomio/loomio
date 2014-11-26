describe 'DiscussionModel', ->
  discussion = null
  author = null
  recordStore = null
  proposal = null
  group = null
  event = null
  otherEvent = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    group = recordStore.groups.new(id: 1, name: 'group')
    discussion = recordStore.discussions.new(id: 1, group_id: group.id, title: 'Hi')
    author = recordStore.users.new(id: 1, name: 'Sam')
    event = recordStore.events.new(id: 1, sequence_id: 1, discussion_id: 1)
    otherEvent = recordStore.events.new(id: 1, sequence_id: 1, discussion_id: 2)

  describe 'author()', ->
    it 'returns the discussion author', ->
      discussion.authorId = author.id
      expect(discussion.author()).toBe(author)

  describe 'proposals()', ->
    beforeEach ->
      proposal = recordStore.proposals.new(discussion_id: discussion.id)

    it 'returns proposals', ->
      expect(discussion.proposals()).toContain(proposal)

  describe 'group()', ->
    it 'returns its group', ->
      expect(discussion.group()).toBe(group)

  describe 'events()', ->
    it 'returns events for the discussion', ->
      expect(discussion.events()).toContain(event)

    it 'does not return events for another discussion', ->
      expect(discussion.events()).not.toContain(otherEvent)
