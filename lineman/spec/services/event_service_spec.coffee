#describe 'EventService', ->
  #service = null
  #event = {id: 1, discussion_id: 1}
  #data = {event: event}
  #events = [events]
  #discussion = {events: events}
  #comment = {created_at: 'just now'}
  #gettedValue = null

  #mockRecordService = null

  #beforeEach module 'loomioApp'

  #beforeEach ->
    #mockRecordService =
      #consumeSideLoadedRecords: (data) ->
      #hydrateRelationshipsOn: (record) ->
      #put: (collectionName, id, record) ->
      #get: (collectionName, id) ->
        #gettedValue

    #module ($provide) ->
      #$provide.value('RecordCacheService', mockRecordService)
      #return

    #inject ($httpBackend, EventService) ->
      #service = EventService
      #httpBackend = $httpBackend

  #describe 'subscribeTo', ->
    #it "uses the subscription to PrivatePub.sign"
    #it "PrivatePub.subscribes to the channel"

  #describe 'consumeEventFromResponseData', ->
    #beforeEach ->
      #spyOn(mockRecordService, 'consumeSideLoadedRecords')
      #spyOn(mockRecordService, 'hydrateRelationshipsOn')
      #spyOn(mockRecordService, 'put')
      #spyOn(service, 'play')
      #service.consumeEventFromResponseData(data)

    #context 'new event', ->
      #beforeEach ->
        #gettedValue = undefined

      #it "uses RecordCache to consumeSideLoadedRecords", ->
        #expect(mockRecordService.consumeSideLoadedRecords).toHaveBeenCalledWith(data)

      #it "uses RecordCache to hydrateRelationshipsOn event", ->
        #expect(mockRecordService.hydrateRelationshipsOn).toHaveBeenCalledWith(event)

      #it "stores the event in RecordCache", ->
        #expect(mockRecordService.put).toHaveBeenCalledWith('events', event.id, event)

      #it "plays the event", ->
        #expect(service.play).toHaveBeenCalledWith(event)

  #describe 'play', ->
    #beforeEach ->
      #spyOn(mockRecordService, 'get').andCallThrough()

    #context 'new_comment event', ->
      #beforeEach ->
        #gettedValue = discussion
        #event.kind = 'new_comment'
        #event.comment = comment

      #it 'pushes the event onto the discussion', ->
        #service.play(event)
        #expect(mockRecordService.get).toHaveBeenCalledWith('discussions', 1)
        #expect(discussion.events).toContain(event)

      #it 'updates last_comment_at on the discussion', ->
        #service.play(event)
        #expect(discussion.last_comment_at).toEqual(event.comment.created_at)

    #context 'new_motion event', ->
      #beforeEach ->
        #event.kind = 'new_motion'
        #event.proposal = {title: 'i propose'}

      #it "pushes the event onto the discussion", ->
        #service.play(event)
        #expect(mockRecordService.get).toHaveBeenCalledWith('discussions', 1)
        #expect(discussion.events).toContain(event)

      #it 'sets the active_proposal on the discussion', ->
        #service.play(event)
        #expect(discussion.active_proposal).toBe(event.proposal)

      #it "pushes the proposal into discussion.proposals", ->
        #service.play(event)
        #expect(discussion.proposals).toContain(event.proposal)

