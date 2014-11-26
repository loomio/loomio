#describe 'Discussion/NewCommentItemController', ->
  #$scope = null
  #rootScope = null
  #controller = null
  #users = [
    #{ id: 1, name: 'BillWithers' },
    #{ id: 2, name: 'JamesWithers' },
    #{ id: 3, name: 'RobWithers' },
    #{ id: 4, name: 'MixWithers' }
  #]

  #mockUserAuthService =
    #currentUser: {id: 1, name: 'Bill Withers'}

  #mockCommentService =
    #like: (comment_id) ->
      #true

    #unlike: (comment_id) ->
      #true

  #beforeEach module 'loomioApp'


  #beforeEach inject ($rootScope, $controller, CommentModel) ->
    #comment = new CommentModel
      #id: 1
      #body: 'hi there'
      #created_at: new Date()
      #liker_ids: []
      #likers: -> []

    #rootScope = $rootScope
    #$scope = $rootScope.$new()
    #$scope.event =
      #comment: -> comment

    #controller = $controller 'NewCommentItemController',
      #$scope: $scope
      #CommentService: mockCommentService
      #UserAuthService: mockUserAuthService


  #describe 'like()', ->
   #it 'likes a comment', ->
     #spyOn(mockCommentService, 'like').andReturn(true)
     #$scope.like()
     #expect(mockCommentService.like).toHaveBeenCalled()

  #describe 'unlike()', ->
   #it 'unlikes a comment', ->
     #spyOn(mockCommentService, 'unlike').andReturn(true)
     #$scope.unlike()
     #expect(mockCommentService.unlike).toHaveBeenCalled()

  #describe 'currentUserLikesIt', ->
    #describe 'and the current user does indeed like the comment', ->
      #beforeEach ->
        #$scope.comment.likerIds = [1]

      #it 'returns true', ->
        #expect($scope.currentUserLikesIt()).toBe(true)

    #describe 'and the current user does not like it', ->
      #it 'returns false', ->
        #expect($scope.currentUserLikesIt()).toBe(false)

    #describe 'anybodyLikesIt', ->
      #context 'but nobody likes it', ->
        #it 'is false', ->
          #expect($scope.anybodyLikesIt()).toBe(false)

      #context 'somebody likes it', ->
        #beforeEach ->
          #$scope.comment.likerIds = [1]

        #it 'is true', ->
          #expect($scope.anybodyLikesIt()).toBe(true)

  #describe 'reply()', ->
    #it 'emits the replyToCommentClicked signal', ->
      #spyOn($scope, '$emit')
      #$scope.reply()
      #expect($scope.$emit).toHaveBeenCalledWith('replyToCommentClicked', $scope.comment)

