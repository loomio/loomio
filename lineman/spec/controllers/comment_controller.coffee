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
    $scope.event = {comment: {id: 1, body: 'hi there', created_at: new Date()}}
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


