describe 'RecordCacheService', ->
  service = null
  cacheFactory = null
  thing = {hi: 'hi'}

  beforeEach ->
    module 'loomioApp'
    inject ($angularCacheFactory, RecordCacheService) ->
      cacheFactory = $angularCacheFactory
      service = RecordCacheService

  describe 'get', ->
    context 'nonexistant key', ->
      it "returns undefined?", ->
        expect(service.get('nothing', 1)).toBe(undefined)

    context 'existant key', ->
      beforeEach ->
        service.put('thing', 1, thing)

      it "returns object", ->
        expect(service.get('thing', 1)).toBe(thing)

  describe 'consumeSideLoadedRecords', ->
    it 'consumes objects from known keys', ->
      discussion = {id: 1, title: 'I am bart simpson'}
      service.consumeSideLoadedRecords({discussions: [discussion]})
      expect(service.get('discussions', 1)).toBe(discussion)


  describe 'hydrateRelationshipsOn', ->
    it "puts author into discussion via author_id", ->
      author = {id: 1, name: 'jim'}
      discussion =
        id: 1
        title: 'cool'
        author_id: '1'
        relationships:
          author:
            foreign_key: 'author_id'
            collection: 'authors'
      rootNode = {discussions: [discussion], authors: [author]}
      service.consumeSideLoadedRecords(rootNode)
      service.hydrateRelationshipsOn(discussion)
      expect(discussion.author).toBe(author)

    it 'puts event into events via event_ids', ->
      event = {id: 1, kind: 'new_comment'}

      discussion =
        id: 1
        event_ids: [1]
        relationships:
          events:
            foreign_key: 'event_ids'
            collection: 'events'
            type: 'list'
      rootNode = {discussions: [discussion], events: [event]}
      service.consumeSideLoadedRecords(rootNode)
      service.hydrateRelationshipsOn(discussion)
      expect(discussion.events[0]).toBe(event)

