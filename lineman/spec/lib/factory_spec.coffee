describe 'Model Factory', ->

  beforeEach module 'loomioApp'
  beforeEach useFactory

  it 'creates a discussion with defaults', ->
    discussion = @factory.create 'discussions'
    expect(discussion).toBeTruthy()
    expect(discussion.title).toBeTruthy()

  it 'creates a discussion with passed attrs', ->
    discussion = @factory.create 'discussions', { title: 'hi mom' }
    expect(discussion.title).toBe('hi mom')

  it 'creates a user with defaults', ->
    user = @factory.create 'users'
    expect(user).toBeTruthy()
    expect(user.name).toBeTruthy()

  it 'creates a user with passed attrs', ->
    user = @factory.create 'users', { name: 'Uncle Ben' }
    expect(user.name).toBe('Uncle Ben')

  it 'creates a comment with defaults', ->
    comment = @factory.create 'comments'
    expect(comment).toBeTruthy()
    expect(comment.body).toBeTruthy()

  it 'creates a user with passed attrs', ->
    comment = @factory.create 'comments', { body: 'Mostly Harmless' }
    expect(comment.body).toBe('Mostly Harmless')
