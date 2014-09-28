#describe 'AddComment Controller', ->
  #parentScope = null
  #$scope = null
  #controller = null

  #discussion =
    #events: []

  #mockCommentService =
    #add: (comment) ->
      #true

  #beforeEach module 'loomioApp'

  #beforeEach inject ($rootScope, $controller) ->
    #parentScope = $rootScope
    #$scope = $rootScope.$new()
    #$scope.discussion = discussion
    #controller = $controller 'AddCommentController',
      #$scope: $scope
      #CommentService: mockCommentService

  #it 'defines a newComment', ->
    #expect($scope.newComment).toBeDefined()

  #describe 'collapseIfEmpty()', ->
    #beforeEach ->
      #$scope.isExpanded = true

    #context 'text in the real textarea', ->
      #it 'does not collapse', ->
        #$scope.newComment.body = 'hi there'
        #$scope.collapseIfEmpty()
        #expect($scope.isExpanded).toBe(true)

    #context 'textarea is empty', ->
      #beforeEach ->
        #$scope.collapseIfEmpty()

      #it 'collapses', ->
        #expect($scope.isExpanded).toBe(false)

  #it 'should start collapsed', ->
    #expect($scope.isExpanded).toBe(false)

  #it 'adds a comment via add comment service', ->
    ## add comment service should receive a message when we add comment
    #comment =
      #discussion_id: 1,
      #body: 'hello'

    #$scope.newComment = comment

    #spyOn(mockCommentService, 'add').andReturn(true)
    #$scope.processForm()
    #expect(mockCommentService.add).toHaveBeenCalledWith(comment, $scope.saveSuccess, $scope.saveError)

  #describe 'startCommentReply is broadcast', ->
    #beforeEach ->
      #$scope.newComment = {}
      #parentScope.$broadcast('showReplyToCommentForm', originalComment)

    #originalComment =
      #id: 1
      #body: 'gidday there'
      #created_at: new Date()
      #author:
        #name: 'Reggy'
        #id: '3'

    #it 'sets the parent_id on the comment model', ->
      #expect($scope.newComment.parent_id).toBe(originalComment.id)

    #it 'expands the comment form', ->
      #expect($scope.isExpanded).toBe(true)
