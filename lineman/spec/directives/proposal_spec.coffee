describe 'Proposal directive', ->
  $scope = {}
  element = {}
  proposal = {name: 'shall we?'}

  beforeEach module 'loomioApp'

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope
    $rootScope.proposal = proposal
    element = $compile('<proposal proposal="proposal"></proposal>')($rootScope)
    $rootScope.$digest()
