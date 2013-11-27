describe 'addComment directive', ->
  $scope = {}
  element = {}
  form = {}
  fakeInput = {}
  realInput = {}

  beforeEach module 'loomioApp'

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope
    element = $compile('<add_comment></add_comment>')($rootScope)
    $rootScope.$digest()

  describe 'by default', ->
    it 'has an input field for collapsed mode', ->
      expect(element.find('.fake input').length).toBe(1)

    it 'has a textarea for expanded mode', ->
      expect(element.find('.real textarea').length).toBe(1)

    it 'is not expanded by default', ->
      expect($scope.isExpanded).toBe(false)

    it 'starts with the textarea hidden', ->
      expect(element.find('.real')).toHaveClass('ng-hide')

    it 'starts with the fake input showing', ->
      expect(element.find('.fake')).not.toHaveClass('ng-hide')

  describe 'collapseIfEmpty()', ->
    beforeEach ->
      $scope.isExpanded = true

    describe 'when there is text in the real textarea', ->
      beforeEach ->
        element.find('.real textarea').val('hi im some text')

      it 'does not collapse', ->
        $scope.collapseIfEmpty()
        expect($scope.isExpanded).toBe(true)

    describe 'when the comment textarea is empty', ->
      beforeEach ->
        $scope.collapseIfEmpty()

      it 'collapses', ->
        expect($scope.isExpanded).toBe(false)

describe 'AddComment Controller', ->
  $scope = null
  controller = null

  mockAddCommentService =
    add: (comment) ->
      true

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()
    controller = $controller 'AddCommentController',
      $scope: $scope
      addCommentService: mockAddCommentService

  it 'should start collapsed', ->
    expect($scope.isExpanded).toBe(false)

  it 'adds a comment via add comment service', ->
    # add comment service should receive a message when we add comment
    comment =
      discussion_id: 1,
      body: 'hello'

    discussion =
      events: []

    $scope.comment = comment
    $scope.discussion = discussion

    spyOn(mockAddCommentService, 'add').andReturn(true)
    $scope.processForm()
    expect(mockAddCommentService.add).toHaveBeenCalledWith(comment, discussion)

describe 'AddCommentService', ->
  service = null
  httpBackend = null

  comment =
    body: 'hi'
    discussion_id: 1

  discussion =
    events: []

  eventResponse =
    id: 1
    sequence_id: 1
    comment:
      author:
        id: 1
        name: 'jimmy'
      body: 'hi'
      discussion_id: 1

  beforeEach module 'loomioApp'

  beforeEach ->
    inject ($httpBackend, addCommentService) ->
      service = addCommentService
      httpBackend = $httpBackend

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'add', ->
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

