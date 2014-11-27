#describe 'Discussion Controller', ->
  #beforeEach module 'loomioApp'

  #$scope = null
  #controller = null

  #mockDiscussion = null

  #mockEventService =
    #subscribeTo: (subscription, onNewEvent) ->
    #fetch: ->
      #true

  #mockEventSubscription =
    #channel: '/events'

  #mockCurentUser =
    #id: 1

  #beforeEach inject ($rootScope, $controller, DiscussionModel) ->
    #mockDiscussion = new DiscussionModel
      #id: 1
      #title: 'title text'
      #description: 'description text'
      #author: ->
        #id: 2
        #name: 'hurbert'
      #events: -> [
        #id: 1000
        #sequence_id: 1
        #kind: 'new_comment'
        #eventable: comment
      #]
    #spyOn(mockEventService, 'subscribeTo')

    #$scope = $rootScope.$new()

    #controller = $controller 'DiscussionController',
      #$scope: $scope
      #discussion: mockDiscussion
      #eventSubscription: mockEventSubscription
      #EventService: mockEventService

  #describe "initialization", ->
    #it "assigns $scope.discussion", ->
      #expect($scope.discussion).toBe(mockDiscussion)

  #describe 'a replyToCommentClicked event occurs', ->
    #it 'broadcasts startCommentReply', ->
      #subscope = $scope.$new()
      #spyOn($scope, '$broadcast')
      #comment = {thing: 'ok'}
      #subscope.$emit 'replyToCommentClicked', comment
      #expect($scope.$broadcast).toHaveBeenCalledWith 'showReplyToCommentForm', comment

