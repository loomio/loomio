# describe 'ThreadPageController', ->

#   beforeEach module 'loomioApp'
#   beforeEach useFactory

#   beforeEach inject ($httpBackend, $routeParams) ->
#     discussion = @factory.create 'discussions', title: 'hi mom'
#     $routeParams.key = 'QWERTY'
#     $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
#     $httpBackend.whenGET(/api\/v1\/discussions\/QWERTY/).respond(200, discussion)

#   it 'passes the discussion', ->
#     prepareController @, 'ThreadPageController', ->
#     expect(@$controller.discussion.title).toBe('hi mom')
