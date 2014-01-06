describe 'ProposalController', ->
  parentScope = null
  $scope = null
  controller = null
  proposal = {id: 1, name: 'hello'}

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    parentScope = $rootScope
    $rootScope.proposal = proposal
    $scope = $rootScope.$new()
    controller = $controller 'ProposalController',
      $scope: $scope
