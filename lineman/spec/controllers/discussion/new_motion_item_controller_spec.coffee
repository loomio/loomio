describe 'Discussion/NewMotionItemController', ->
  parentScope = null
  $scope = null
  controller = null
  discussion = {id: 1}

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    $scope = $rootScope.$new()
    $scope.event = {proposal: -> {hi:'hi'}}
    controller = $controller 'NewProposalItemController',
      $scope: $scope

  it 'should assign motion', ->
    expect($scope.proposal).toBeDefined()
