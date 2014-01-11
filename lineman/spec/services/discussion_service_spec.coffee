describe 'DiscussionService', ->
  service = null
  httpBackend = null
  mockCacheService = null

  response_data =
    discussion:
      id: 1

  beforeEach ->
    module 'loomioApp'

    module ($provide) ->
      mockCacheService =
        consumeSideLoadedRecords: (response_data) ->
        hydrateRelationshipsOn: (record) ->

      $provide.value('RecordCacheService', mockCacheService)
      return

    inject ($httpBackend, DiscussionService, RecordCacheService) ->
      httpBackend = $httpBackend
      service = DiscussionService

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  # get will always use http to get the discussion
  describe 'remoteGet', ->
    it 'gets the discussion', ->
      httpBackend.expectGET('/api/discussions/1').respond(200, response_data)
      service.remoteGet(1)
      httpBackend.flush()

    it 'updates caches of sideloaded records', ->
      spyOn(mockCacheService, 'consumeSideLoadedRecords')
      httpBackend.expectGET('/api/discussions/1').respond(200, response_data)
      service.remoteGet(1)
      httpBackend.flush()
      expect(mockCacheService.consumeSideLoadedRecords).toHaveBeenCalledWith(response_data)

    it 'hydrates the associated records', ->
      httpBackend.expectGET('/api/discussions/1').respond(200, response_data)
      spyOn(mockCacheService, 'hydrateRelationshipsOn')
      service.remoteGet(1)
      httpBackend.flush()
      expect(mockCacheService.hydrateRelationshipsOn).toHaveBeenCalledWith({id: 1})

  #describe 'localGet', ->
    #it 'pulls the discussion from the RecordCache'
