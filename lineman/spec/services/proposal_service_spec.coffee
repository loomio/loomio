#describe 'ProposalService', ->
  #service = null
  #httpBackend = null
  #discussion = null
  #event = null
  #callbacks = null
  #error = null

  #mockEventService =
    #consumeEventFromResponseData: ->
    #play: ->


  #beforeEach module 'loomioApp'

  #beforeEach ->
    #callbacks =
      #success: (response) -> true
      #error: (response) -> true

    #module ($provide) ->
      #$provide.value('EventService', mockEventService)
      #return

    #inject ($httpBackend, ProposalService) ->
      #httpBackend = $httpBackend
      #service = ProposalService


  #afterEach ->
    #httpBackend.verifyNoOutstandingExpectation()
    #httpBackend.verifyNoOutstandingRequest()

  #describe 'create', ->
    #proposal = null
    #beforeEach ->
      #proposal = {title: 'lets go crazy'}
      #discussion = {events: []}
      #event = {proposal: proposal}
      #error =
        #messages: ['no hats selected']

    #it 'posts the comment to the server', ->
      #httpBackend.expectPOST('/api/motions', proposal).respond(200, {event: event})
      #service.create(proposal, callbacks.success, callbacks.error)
      #httpBackend.flush()

    #context 'proposal was successfully created', ->
      #it 'calls the onSuccess callback with the event', ->
        #spyOn(callbacks, 'success')
        #httpBackend.expectPOST('/api/motions', proposal).respond(200, {event: event})
        #service.create(proposal, callbacks.success, callbacks.error)
        #httpBackend.flush()
        #expect(callbacks.success).toHaveBeenCalledWith(event)

    #context 'proposal failed to save', ->
      #it 'calls the onFailure callback with the errors', ->
        #spyOn(callbacks, 'error')
        #httpBackend.expectPOST('/api/motions', proposal).respond(400, {error: error})
        #service.create(proposal, callbacks.success, callbacks.error)
        #httpBackend.flush()
        #expect(callbacks.error).toHaveBeenCalledWith(error)

  #describe 'saveVote', ->
    #vote = null
    #beforeEach ->
      #vote = {proposal_id: 1, position: 'yes', statement: 'y not'}
      #discussion = {events: []}
      #event = {vote: vote}

    #it 'posts the comment to the server', ->
      #httpBackend.expectPOST("/api/motions/1/vote", vote).respond(200, {event: event})
      #service.saveVote(vote, callbacks.success, callbacks.error)
      #httpBackend.flush()

    #context 'proposal was successfully created', ->
      #it 'calls the onSuccess callback with the event', ->
        #spyOn(callbacks, 'success')
        #httpBackend.expectPOST('/api/motions/1/vote', vote).respond(200, {event: event})
        #service.saveVote(vote, callbacks.success, callbacks.error)
        #httpBackend.flush()
        #expect(callbacks.success).toHaveBeenCalledWith(event)

    #context 'proposal failed to save', ->
      #it 'calls the onFailure callback with the errors', ->
        #spyOn(callbacks, 'error')
        #httpBackend.expectPOST('/api/motions/1/vote', vote).respond(400, {error: error})
        #service.saveVote(vote, callbacks.success, callbacks.error)
        #httpBackend.flush()
        #expect(callbacks.error).toHaveBeenCalledWith(error)

