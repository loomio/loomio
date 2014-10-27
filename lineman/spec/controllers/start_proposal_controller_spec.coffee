#describe 'StartProposalController', ->
  #parentScope = null
  #$scope = null
  #controller = null
  #discussion = null
  #proposal = null
  #errors = null

  #mockProposalService =
    #create: (proposal) ->
      #true

  #beforeEach module 'loomioApp'

  #beforeEach inject ($rootScope, $controller) ->
    #parentScope = $rootScope
    #$rootScope.discussion = discussion
    #$scope = $rootScope.$new()
    #discussion = {id: 1, events: [], proposal: null}
    #$scope.discussion = discussion
    #controller = $controller 'StartProposalController',
      #$scope: $scope
      #ProposalService: mockProposalService

  #context 'by default', ->
    #it 'should start collapsed', ->
      #expect($scope.isExpanded).toBe(false)

    #it 'should not be hidden', ->
      #expect($scope.isHidden).toBe(false)

    #it 'should not be disabled', ->
      #expect($scope.isDisabled).toBe(false)

    #it 'has 0 errors', ->
      #expect($scope.errorMessages.length).toBe(0)

    #context 'discussion has a voting proposal', ->
      #beforeEach ->
        #$scope.discussion.proposal = {name: 'hi'}

      ##it 'starts hidden', ->
        ##console.log($scope.discussion.proposal)
        ##expect($scope.isHidden).toBe(true)

  #it 'expands on showForm()', ->
    #$scope.showForm()
    #expect($scope.isExpanded).toBe(true)

  #describe '#submitProposal', ->
    #beforeEach ->
      #proposal =
        #title: 'Lets do something'
        #discussion_id: 1
      #$scope.proposal = proposal

    #it 'calls ProposalService.create with the model', ->
      #spyOn(mockProposalService, 'create')
      #$scope.submitProposal()
      #expect(mockProposalService.create).toHaveBeenCalledWith(proposal, $scope.saveSuccess, $scope.saveError)

    #it 'disables the form', ->
      #$scope.submitProposal()
      #expect($scope.isDisabled).toBe(true)

  #describe 'closeForm', ->
    #beforeEach ->
      #$scope.isExpanded = true

    #it 'sets isExpanded to false', ->
      #$scope.closeForm()
      #expect($scope.isExpanded).toBe(false)

  #describe '#saveSuccess(event)', ->
    #event = {proposal: {}}
    #errors = ['bad times']
    #it 'hides the start proposal widget', ->
      #$scope.saveSuccess(event)
      #expect($scope.isHidden).toBe(true)

    #it 'pushes the event onto the discussion events', ->
      #spyOn($scope.discussion.events, 'push')
      #$scope.saveSuccess(event)
      #expect(discussion.events.push).toHaveBeenCalledWith(event)

    #it 'sets the discussion.proposal', ->
      #$scope.saveSuccess(event)
      #expect(discussion.active_proposal).toBe(event.proposal)

    #it 'reenables the form', ->
      #$scope.saveError(errors)
      #expect($scope.isDisabled).toBe(false)

  #describe '#saveError(errors)', ->
    #beforeEach ->
      #errors = 
        #error_messages: ['bad motivator unit']

    #it 'reenables the form', ->
      #$scope.saveError(errors)
      #expect($scope.isDisabled).toBe(false)

    #it 'displays the errors', ->
      #$scope.saveError(errors)
      #expect($scope.errorMessages).toBe(errors.error_messages)

