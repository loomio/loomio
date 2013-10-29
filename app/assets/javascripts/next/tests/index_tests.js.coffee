describe 'DiscussionController',  ->
  scope = {}

  beforeEach angular.mock.module 'LoomioApp'

  beforeEach angular.mock.inject ($rootScope, $controller) ->
    #create an empty scope
    scope = $rootScope.$new();
    $controller 'DiscussionController', $scope: scope

  it 'should have an array of comments', ->
    expect(scope.discussion.comments).toContain({author_name: 'bill', body: 'hi there', created_at: new Date('2001-01-01 01:01:01')})
