describe 'CommentService', ->
  service = null
  httpBackend = null

  comment =
    id: 1
    body: 'hi'
    discussion_id: 1
    liker_ids_and_names: {}

  discussion =
    events: []

  beforeEach module 'loomioApp'

  beforeEach ->
    inject ($httpBackend, CommentService) ->
      service = CommentService
      httpBackend = $httpBackend

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'add', ->
    eventResponse =
      id: 1
      sequence_id: 1
      comment:
        author:
          id: 1
          name: 'jimmy'
        body: 'hi'
        discussion_id: 1

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

  describe 'like', ->
    likeResponse =
      id: 1
      name: 'Bill Withers'

    it 'posts like to the server', ->
      httpBackend.expectPOST("/api/comments/#{comment.id}/like").respond(200, likeResponse)
      service.like(comment)
      httpBackend.flush()

    it 'updates comment.liker_ids_and_names', ->
      httpBackend.expectPOST("/api/comments/#{comment.id}/like").respond(200, likeResponse)
      service.like(comment)
      httpBackend.flush()
      expect(comment.liker_ids_and_names[1]).toBe('Bill Withers')


