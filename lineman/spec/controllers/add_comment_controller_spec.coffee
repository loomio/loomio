describe 'AddComment Controller', ->
  parentScope = null
  $scope = null
  controller = null

  discussion =
    events: []

  mockCommentService =
    create: (comment) ->
      true

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    parentScope = $rootScope
    $scope = $rootScope.$new()
    $scope.discussion = discussion
    controller = $controller 'AddCommentController',
      $scope: $scope
      CommentService: mockCommentService

  it 'defines a newComment', ->
    expect($scope.comment).toBeDefined()

  describe 'collapseIfEmpty()', ->
    beforeEach ->
      $scope.isExpanded = true

    context 'text in the real textarea', ->
      it 'does not collapse', ->
        $scope.comment.body = 'hi there'
        $scope.collapseIfEmpty()
        expect($scope.isExpanded).toBe(true)

    context 'textarea is empty', ->
      beforeEach ->
        $scope.collapseIfEmpty()

      it 'collapses', ->
        expect($scope.isExpanded).toBe(false)

  it 'should start collapsed', ->
    expect($scope.isExpanded).toBe(false)

  it 'adds a comment via add comment service', ->
    # add comment service should receive a message when we add comment
    comment =
      discussionId: 1,
      body: 'hello'

    $scope.comment = comment

    spyOn(mockCommentService, 'create').andReturn(true)
    $scope.submit()
    expect(mockCommentService.create).toHaveBeenCalledWith(comment, $scope.success, $scope.error)

  describe 'startCommentReply is broadcast', ->
    beforeEach ->
      parentScope.$broadcast('showReplyToCommentForm', originalComment)

    originalComment =
      id: 1
      body: 'gidday there'
      createdAt: new Date()
      author: ->
        name: 'Reggy'
        id: '3'

    it 'sets the parent_id on the comment model', ->
      expect($scope.comment.parentId).toBe(originalComment.id)

    it 'expands the comment form', ->
      expect($scope.isExpanded).toBe(true)
