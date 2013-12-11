describe 'CommentService', ->
  service = null
  httpBackend = null

  comment =
    body: 'hi'
    discussion_id: 1

  discussion =
    events: []

  eventResponse =
    id: 1
    sequence_id: 1
    comment:
      author:
        id: 1
        name: 'jimmy'
      body: 'hi'
      discussion_id: 1

  beforeEach module 'loomioApp'

  beforeEach ->
    inject ($httpBackend, CommentService) ->
      service = CommentService
      httpBackend = $httpBackend

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'add', ->
    it 'posts the comment to the server', ->
      httpBackend.expectPOST('/api/comments', comment).respond(200, eventResponse)
      service.add(comment, discussion)
      httpBackend.flush()

    it 'pushes the returned event onto the discussion', ->
      httpBackend.whenPOST('/api/comments', comment).respond(200, eventResponse)
      spyOn(discussion.events, 'push')
      service.add(comment, discussion)
      httpBackend.flush()
      expect(discussion.events.push).toHaveBeenCalledWith(eventResponse)

