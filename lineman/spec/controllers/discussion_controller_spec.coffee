describe 'Discussion Controller', ->
  beforeEach module 'loomioApp'

  $scope = null
  controller = null

  comment =
    body: 'I am a comment'
    id: 1
    created_at: new Date()
    liker_ids_and_names: []
    author:
      id: 3
      name: 'Gilbert'

  discussion =
    id: 1
    title: 'title text'
    description: 'description text'
    current_user:
      id: 1
      name: 'Bill Withers'
    author:
      id: 2
      name: 'hurbert'
    events: [
      id: 1000
      sequence_id: 1
      kind: 'new_comment'
      eventable: comment
    ]

  beforeEach inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()

    controller = $controller 'DiscussionController',
      $scope: $scope
      discussion: discussion

  describe 'a replyToCommentClicked event occurs', ->
    it 'broadcasts startCommentReply', ->
      subscope = $scope.$new()
      spyOn($scope, '$broadcast')
      subscope.$emit 'replyToCommentClicked', comment
      expect($scope.$broadcast).toHaveBeenCalledWith 'showReplyToCommentForm', comment

