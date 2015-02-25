describe 'DiscussionReaderModel', ->
  discussion = null
  reader = null
  recordStore = null
  item = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    discussion = recordStore.discussions.initialize(id: 1, title: 'Hi')
    reader = recordStore.discussionReaders.initialize(discussion_id: 1)
    item = recordStore.events.initialize(id:1, discussion_id: 1, createdAt: 'yesterday', sequenceId: 1)

  describe 'markItemAsRead', ->
    beforeEach ->
      reader.markItemAsRead(item)

    it "it sets lastReadAt to item.createdAt", ->
      expect(reader.lastReadAt).toBe(item.createdAt)

    it "it sets lastReadSequenceId to item.sequenceId", ->
      expect(reader.lastReadSequenceId).toBe(item.sequenceId)
