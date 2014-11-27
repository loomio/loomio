#describe 'ProposalFormController', ->
  #parentScope = null
  #$scope = null
  #controller = null
  #proposal = {id: 1, name: 'hello'}
  #discussion = {id: 1, title: 'yeh'}

  #mockProposalService =
    #saveVote: ->
      #true
  #mockModalInstance = {}

  #beforeEach module 'loomioApp'

  #beforeEach inject ($rootScope, $controller) ->
    #parentScope = $rootScope
    #$rootScope.proposal = proposal
    #$rootScope.discussion = discussion
    #$scope = $rootScope.$new()
    #controller = $controller 'ProposalFormController',
      #$scope: $scope
      #proposal: proposal
      #ProposalService: mockProposalService
      #$modalInstance: mockModalInstance

  #describe 'submit', ->
    #it 'disables the form'
    #it 'calls ProposalService.create'
