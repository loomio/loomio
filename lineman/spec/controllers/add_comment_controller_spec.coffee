describe 'AddComment Controller', ->
  parentScope = null
  $scope = null
  controller = null

  mockCommentService =
    add: (comment) ->
      true

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    parentScope = $rootScope
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

    $scope.newComment = comment
    $scope.discussion = discussion

    spyOn(mockCommentService, 'add').andReturn(true)
    $scope.processForm()
    expect(mockCommentService.add).toHaveBeenCalledWith(comment, discussion)

  describe 'startCommentReply is broadcast', ->
    beforeEach ->
      $scope.newComment = {}
      parentScope.$broadcast('showReplyToCommentForm', originalComment)

    originalComment =
      id: 1
      body: 'gidday there'
      created_at: new Date()
      author:
        name: 'Reggy'
        id: '3'

    it 'sets the parent_id on the comment model', ->
      expect($scope.newComment.parent_id).toBe(originalComment.id)

    it 'expands the comment form', ->
      expect($scope.isExpanded).toBe(true)
