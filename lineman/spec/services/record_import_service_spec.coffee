describe 'RecordImporter', ->
  #service = null

  #beforeEach ->
    #module 'loomioApp'
    #inject (RecordImportService) ->
      #service = RecordImportService

  #describe 'registerModel', ->
    #it "adds the model to @models with plural key", ->
      #service.registerModel(ThingModel)
      #expect(service.collectionNames()).toContain('things')
  #beforeEach ->
    #service.registerModel ThingModel

  #it 'consumes new objects from registered models', ->
    #thing_data = {id: 1, title: 'I am bart simpson'}
    #service.importRecords({things: [thing_data]})
    #thing = service.get('things', 1)
    #expect(thing.meaningOfLife()).toBe(42)
    #expect(thing.title).toBe('I am bart simpson')

  #it 'updates existing records', ->
    ## put new record in
    #thing_data = {id: 1, title: 'I am bart simpson'}
    #service.importRecords({things: [thing_data]})

    ##retrieve the record
    #thing = service.get('things', 1)

    ##import updated record data
    #thing_data = {id: 1, title: 'I am marge simpson'}
    #service.importRecords({things: [thing_data]})

    ## note we use existing thing reference
    #expect(thing.meaningOfLife()).toBe(42)
    #expect(thing.title).toBe('I am marge simpson')

