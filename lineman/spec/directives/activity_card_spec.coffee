describe 'Activity Card Component', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  beforeEach inject ($httpBackend) ->
    $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
    $httpBackend.whenGET(/api\/v1\/events/).respond(200, {})
    $httpBackend.whenPATCH(/api\/v1\/discussion_readers\/\d+\/mark_as_read/).respond(200, {})

  it 'passes the discussion', ->
    prepareDirective @, 'activity_card', (parent) =>
      parent.discussion = @factory.create 'discussions', title: 'hi mom'
    expect(@$scope.discussion.title).toBe('hi mom')

  it 'scrolls to unread when the discussion is unread', ->
    prepareDirective @, 'activity_card', (parent) =>
      parent.discussion = @factory.create 'discussions', last_sequence_id: 50, salient_items_count: 50
      @factory.create 'discussion_readers', discussion_id: parent.discussion.id, last_read_sequence_id: 40, read_salient_items_count: 40
    expect(@$scope.initialLoaded).toBe(38) # last read sequence id, minus 2 post rollback
    expect(@$scope.initialFocused).toBe(40) # last read

  it 'scrolls to the end when the discussion is read', ->
    prepareDirective @, 'activity_card', (parent) =>
      parent.discussion = @factory.create 'discussions', last_sequence_id: 50
      @factory.create 'discussion_readers', discussion_id: parent.discussion.id, last_read_sequence_id: 50
    expect(@$scope.initialLoaded).toBe(21) # one page back
    expect(@$scope.initialFocused).toBe(48) # end of discussion, minus 2 post rollback   

  it 'loads all thread items when under page size and read', ->
    prepareDirective @, 'activity_card', (parent) =>
      parent.discussion = @factory.create 'discussions', last_sequence_id: 20
      @factory.create 'discussion_readers', discussion_id: parent.discussion.id, last_read_sequence_id: 20
    expect(@$scope.initialLoaded).toBe(0) # beginning of thread
    expect(@$scope.initialFocused).toBe(18) # end of discussion, minus 2 post rollback   

  it 'loads a specified location in thread when location hash specifies it', ->
    inject ($location) -> $location.hash('15')
    prepareDirective @, 'activity_card', (parent) =>
      parent.discussion = @factory.create 'discussions', last_sequence_id: 20
      @factory.create 'discussion_readers', discussion_id: parent.discussion.id, last_read_sequence_id: 20
    expect(@$scope.initialLoaded).toBe(13) # target post, minus 2 post rollback
    expect(@$scope.initialFocused).toBe(15) # target post   
