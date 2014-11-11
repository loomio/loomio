#describe 'CommentService', ->
  #service = null
  #httpBackend = null
  #response = null

  #callbacks =
    #saveSuccess: (event) ->
      #{}

    #saveError: (error) ->
      #{error_messages: []}

  #comment = new CommentModel
    #id: 1
    #body: 'hi'
    #discussion_id: 1

  #discussion = new DiscussionModel

  #mockEventService =

  #beforeEach module 'loomioApp'

  #beforeEach ->
    #module ($provide) ->
      #$provide.value('EventService', mockEventService)
      #return

    #inject ($httpBackend, CommentService) ->
      #service = CommentService
      #httpBackend = $httpBackend

  #afterEach ->
    #httpBackend.verifyNoOutstandingExpectation()
    #httpBackend.verifyNoOutstandingRequest()

  #describe 'create', ->
    #beforeEach ->
      #response =
        #event:
          #id: 1
          #sequence_id: 1
          #comment:
            #body: 'hi'
            #discussion_id: 1

    #it 'posts the comment to the server', ->
      #httpBackend.expectPOST('/api/v1/comments', comment).respond(200, response)
      #service.create(comment, callbacks.saveSuccess, callbacks.saveError)
      #httpBackend.flush()

    #it 'calls saveSuccess with the event in the response', ->
      #httpBackend.whenPOST('/api/comments', comment).respond(200, response)
      #spyOn(callbacks, 'saveSuccess')
      #service.add(comment, callbacks.saveSuccess, callbacks.saveError)
      #httpBackend.flush()
      #expect(callbacks.saveSuccess).toHaveBeenCalledWith(response.event)

  #describe 'like', ->
    #likeResponse =
      #id: 1
      #name: 'Bill Withers'

    #it 'posts like to the server', ->
      #httpBackend.expectPOST("/api/comments/#{comment.id}/like").respond(200, likeResponse)
      #service.like(comment)
      #httpBackend.flush()

    #it 'updates comment.liker_ids_and_names', ->
      #httpBackend.expectPOST("/api/comments/#{comment.id}/like").respond(200, likeResponse)
      #service.like(comment)
      #httpBackend.flush()
      #expect(comment.liker_ids_and_names[1]).toBe('Bill Withers')


