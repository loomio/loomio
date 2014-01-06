describe 'ProposalService', ->
  service = null
  httpBackend = null
  proposal = null
  discussion = null
  event = null
  callbacks = null
  errors = null


  beforeEach module 'loomioApp'

  beforeEach ->
    inject ($httpBackend, ProposalService) ->
      service = ProposalService
      httpBackend = $httpBackend

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'create', ->
    beforeEach ->
      callbacks =
        success: (response) ->
          true

        error: (response) ->
          true

      proposal =
        title: 'lets go crazy'

      discussion =
        title: 'what shall we do?'
        events: []

      event =
        id: 1
        sequence_id: 1
        eventable: proposal
        kind: 'new_motion'

      errors = ['no hats selected']

    it 'posts the comment to the server', ->
      httpBackend.expectPOST('/api/motions', proposal).respond(200, {event: event})
      service.create(proposal, callbacks.success, callbacks.error)
      httpBackend.flush()

    context 'proposal was successfully created', ->
      it 'calls the onSuccess callback with the event', ->
        spyOn(callbacks, 'success')
        httpBackend.expectPOST('/api/motions', proposal).respond(200, {event: event})
        service.create(proposal, callbacks.success, callbacks.error)
        httpBackend.flush()
        expect(callbacks.success).toHaveBeenCalledWith(event)

    context 'proposal failed to save', ->
      it 'calls the onFailure callback with the errors', ->
        spyOn(callbacks, 'error')
        httpBackend.expectPOST('/api/motions', proposal).respond(400, {errors: errors})
        service.create(proposal, callbacks.success, callbacks.error)
        httpBackend.flush()
        expect(callbacks.error).toHaveBeenCalledWith(errors)

