describe 'DiscussionReaderModel', ->
  discussion = null
  reader = null
  recordStore = null
  item = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    discussion = recordStore.discussions.import(id: 1, title: 'Hi')
    reader = recordStore.discussionReaders.import(id: 1, discussion_id: 1, last_read_at: moment())
    item = recordStore.events.import(id:1, discussion_id: 1, createdAt: 'yesterday', sequenceId: 1)

  describe 'markItemAsRead', ->
    beforeEach ->

    it "it sets lastReadSequenceId to the passed value", ->
      expect(reader.lastReadSequenceId).toBe(-1)
      reader.markAsRead(0)
      expect(reader.lastReadSequenceId).toBe(0)

    it "it does not lower the last read sequenceId", ->
      reader.lastReadAt = 1
      reader.lastReadSequenceId = 2
      reader.markAsRead(0)
      expect(reader.lastReadSequenceId).toBe(2)
