describe 'RecordStoreService', ->
  service = null
  cacheFactory = null
  thing = null
  otherthing = null

  class ThingModel
    constructor: (data = {}) ->
      @title = data.title
      @id = data.id
      @key = data.key
    plural: 'things'
    meaningOfLife: ->
      42

  beforeEach ->
    module 'loomioApp'
    inject ($angularCacheFactory, RecordStoreService) ->
      cacheFactory = $angularCacheFactory
      service = RecordStoreService

  describe 'registerModel', ->
    it "adds the model to @models with plural key", ->
      service.registerModel(ThingModel)
      expect(service.collectionNames()).toContain('things')


  describe 'get', ->
    beforeEach ->
      thing = new ThingModel({id: 1, key: 'a'})
      otherthing = new ThingModel({id: 2, key: 'b'})
      service.put thing
      service.put otherthing

    it 'returns a whole collection', ->
      expect(service.get('things')).toEqual([thing, otherthing])

    it 'looks up item by id', ->
      expect(service.get('things', 1)).toEqual(thing)

    it 'looks up item by key', ->
      expect(service.get('things', 'a')).toEqual(thing)

    it 'looks up items by ids', ->
      expect(service.get('things', [1, 2])).toEqual([thing, otherthing])

    it 'looks up items by keys', ->
      expect(service.get('things', ['a', 'b'])).toEqual([thing, otherthing])

    it 'looks up items by function', ->
      expect(service.get('things', (thing) -> thing.id == 1 )).toEqual([thing])

  describe 'remove', ->
    beforeEach ->
      thing = new ThingModel({id: 1, key: 'a'})

    it 'removes the object from the store', ->
      service.put thing
      expect(service.get('things', thing.id)).toEqual(thing)
      service.remove(thing)
      expect(service.get('things', thing.id)).toBe(undefined)

  describe 'importRecords', ->
    beforeEach ->
      service.registerModel ThingModel

    it 'consumes new objects from registered models', ->
      thing_data = {id: 1, title: 'I am bart simpson'}
      service.importRecords({things: [thing_data]})
      thing = service.get('things', 1)
      expect(thing.meaningOfLife()).toBe(42)
      expect(thing.title).toBe('I am bart simpson')

    it 'updates existing records', ->
      # put new record in
      thing_data = {id: 1, title: 'I am bart simpson'}
      service.importRecords({things: [thing_data]})

      #retrieve the record
      thing = service.get('things', 1)

      #import updated record data
      thing_data = {id: 1, title: 'I am marge simpson'}
      service.importRecords({things: [thing_data]})

      # note we use existing thing reference
      expect(thing.meaningOfLife()).toBe(42)
      expect(thing.title).toBe('I am marge simpson')

