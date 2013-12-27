describe 'AddComment Controller', ->
  $scope = null
  controller = null

  mockCommentService =
    add: (comment) ->
      true

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()
    controller = $controller 'AddCommentController',
      $scope: $scope
      CommentService: mockCommentService

  it 'should start collapsed', ->
    expect($scope.isExpanded).toBe(false)

  it 'adds a comment via add comment service', ->
    # add comment service should receive a message when we add comment
    comment =
      discussion_id: 1,
      body: 'hello'

    discussion =
      events: []

    $scope.new_comment = comment
    $scope.discussion = discussion

    spyOn(mockCommentService, 'add').andReturn(true)
    $scope.processForm()
    expect(mockCommentService.add).toHaveBeenCalledWith(comment, discussion)

