describe 'Comment Controller', ->
  $scope = null
  controller = null

  mockCommentService =
    like: (comment_id) ->
      true

    unlike: (comment_id) ->
      true

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()
    $scope.event =
      comment:
        id: 1
        body: 'hi there'
        created_at: new Date()
        liker_ids_and_names: {}

    $scope.currentUser = {id: 1, name: 'Bill Withers'}

    controller = $controller 'CommentController',
      $scope: $scope
      CommentService: mockCommentService

  it 'knows its comment id', ->
    expect($scope.comment.id).toBeDefined()

  it 'likes a comment', ->
    spyOn(mockCommentService, 'like').andReturn(true)
    $scope.like()
    expect(mockCommentService.like).toHaveBeenCalledWith($scope.comment)

  it 'unlikes a comment', ->
    spyOn(mockCommentService, 'unlike').andReturn(true)
    $scope.unlike()
    expect(mockCommentService.unlike).toHaveBeenCalledWith($scope.comment)

  describe 'currentUserLikesIt', ->
    describe 'and the current user does indeed like the comment', ->
      beforeEach ->
        $scope.comment.liker_ids_and_names = {1: 'Bill Withers'}

      it 'returns true', ->
        expect($scope.currentUserLikesIt()).toBe(true)

    describe 'and the current user does not like it', ->
      it 'returns false', ->
        expect($scope.currentUserLikesIt()).toBe(false)

  describe 'anybodyLikesIt', ->
    context 'but nobody likes it', ->
      it 'is false', ->
        expect($scope.anybodyLikesIt()).toBe(false)

    context 'somebody likes it', ->
      beforeEach ->
        $scope.comment.liker_ids_and_names = {1: 'jim jam'}

      it 'is true', ->
        expect($scope.anybodyLikesIt()).toBe(true)

