describe 'ProposalService', ->
  service = null
  httpBackend = null
  discussion = null
  event = null
  callbacks = null
  errors = null


  beforeEach module 'loomioApp'

  beforeEach ->
    inject ($httpBackend, ProposalService) ->
      service = ProposalService
      httpBackend = $httpBackend

  beforeEach ->
    callbacks =
      success: (response) -> true
      error: (response) -> true

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'create', ->
    proposal = null
    beforeEach ->
      proposal = {title: 'lets go crazy'}
      discussion = {events: []}
      event = {proposal: proposal}
      errors = ['no hats selected']

    it 'posts the comment to the server', ->
      httpBackend.expectPOST('/api/motions', proposal).respond(200, {new_motion: event})
      service.create(proposal, callbacks.success, callbacks.error)
      httpBackend.flush()

    context 'proposal was successfully created', ->
      it 'calls the onSuccess callback with the event', ->
        spyOn(callbacks, 'success')
        httpBackend.expectPOST('/api/motions', proposal).respond(200, {new_motion: event})
        service.create(proposal, callbacks.success, callbacks.error)
        httpBackend.flush()
        expect(callbacks.success).toHaveBeenCalledWith(event)

    context 'proposal failed to save', ->
      it 'calls the onFailure callback with the errors', ->
        spyOn(callbacks, 'error')
        httpBackend.expectPOST('/api/motions', proposal).respond(400, {new_motion: errors})
        service.create(proposal, callbacks.success, callbacks.error)
        httpBackend.flush()
        expect(callbacks.error).toHaveBeenCalledWith(errors)

  describe 'vote', ->
    vote = null
    beforeEach ->
      vote = {proposal_id: 1, position: 'yes', statement: 'y not'}
      discussion = {events: []}
      event = {vote: vote}
      errors = ['no hats selected']

    it 'posts the comment to the server', ->
      httpBackend.expectPOST("/api/motions/1/vote", vote).respond(200, {new_vote: event})
      service.saveVote(vote, callbacks.success, callbacks.error)
      httpBackend.flush()

    context 'proposal was successfully created', ->
      it 'calls the onSuccess callback with the event', ->
        spyOn(callbacks, 'success')
        httpBackend.expectPOST('/api/motions/1/vote', vote).respond(200, {new_vote: event})
        service.saveVote(vote, callbacks.success, callbacks.error)
        httpBackend.flush()
        expect(callbacks.success).toHaveBeenCalledWith(event)

    context 'proposal failed to save', ->
      it 'calls the onFailure callback with the errors', ->
        spyOn(callbacks, 'error')]
        httpBackend.expectPOST('/api/motions/1/vote', vote).respond(400, {invalid_model: {error_messages: errors}})
        service.saveVote(vote, callbacks.success, callbacks.error)
        httpBackend.flush()
        expect(callbacks.error).toHaveBeenCalledWith(errors)

