# describe 'DashboardPageController', ->
#   parentScope = null
#   $scope = null
#   controller = null

#   beforeEach module 'loomioApp'
#   beforeEach useFactory

#   beforeEach inject ($httpBackend, $routeParams) ->
#     $httpBackend.whenGET(/api\/v1\/translations/).respond(200, {})
#     $httpBackend.whenGET(/api\/v1\/discussions\/dashboard\//).respond(200, {})

#   beforeEach prepareController @, 'DashboardPageController'

#   it 'reloads the filter on homePageClicked event', ->
#     inject ($rootScope) ->
#       @$scope.filter = 'show_starred'
#       $rootScope.$broadCast 'homePageClicked'
#       expect(@$scope.filter).toBe('show_all')
