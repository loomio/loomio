describe 'Activity Card Component', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend) ->
    $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/events/).respond(200, {})
    $httpBackend.whenPATCH(/api\/v1\/discussion_readers\/\d+\/mark_as_read/).respond(200, {})

  beforeEach ->
    prepareDirective @, 'activity_card', =>
      @$scope.discussion = @factory.create 'discussions', title: 'hi mom'

  it 'passes the discussion', ->
    expect(@$scope.discussion.title).toBe('hi mom')
