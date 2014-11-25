describe 'CommentStore', ->
  beforeEach ->
    module 'loomioApp'
    inject () ->

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
