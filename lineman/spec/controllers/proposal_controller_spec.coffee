describe 'ProposalController', ->
  parentScope = null
  $scope = null
  controller = null
  proposal = {id: 1, name: 'hello'}

  mockProposalService = 
    saveVote: ->
      true

  beforeEach module 'loomioApp'

  beforeEach inject ($rootScope, $controller) ->
    parentScope = $rootScope
    $rootScope.proposal = proposal
    $scope = $rootScope.$new()
    controller = $controller 'ProposalController',
      $scope: $scope
      ProposalService: mockProposalService

  describe 'default state', ->
    it 'voteForm is not disabled', ->
      expect($scope.voteFormIsDisabled).toBe(false)

    it 'voteForm is not expanded', ->
      expect($scope.voteFormIsExpanded).toBe(false)

    it 'has null for newVote.position', ->
      expect($scope.newVote.position).toBe(null)

    it 'has null for newVote.statement', ->
      expect($scope.newVote.statement).toBe(null)

  describe 'selectPosition(position)', ->
    beforeEach ->
      $scope.selectPosition('yes')

    it 'sets newVote.position', ->
      expect($scope.newVote.position).toBe('yes')

    it 'expands the statement form', ->
      expect($scope.voteFormIsExpanded).toBe(true)

  describe 'submitVote', ->
    context 'position is selected', ->
      beforeEach ->
        $scope.selectPosition('yes')

      it 'disables the voting form', ->
        $scope.submitVote()
        expect($scope.voteFormIsDisabled).toBe(true)

      it 'calls ProposalService.saveVote with vote and callbacks', ->
        spyOn(mockProposalService, 'saveVote')
        $scope.submitVote()
        expect(mockProposalService.saveVote).toHaveBeenCalledWith($scope.newVote, $scope.saveVoteSuccess, $scope.saveVoteError)

  describe 'saveVoteSuccess', ->
    vote = null
    event = null
    beforeEach ->
      vote = {position: 'yes', statement: 'y not'}
      event = {eventable: vote}
      $scope.discussion = {events: []}
      $scope.saveVoteSuccess(event)

    it 'enables the voteForm', ->
      expect($scope.voteFormIsDisabled).toBe(false)

    it 'collapses the voteForm', ->
      expect($scope.voteFormIsExpanded).toBe(false)

    it 'sets currentUserVote', ->
      expect($scope.currentUserVote).toBe(vote)

    it 'pushes the event into discussion.events', ->
      spyOn($scope.discussion.events, 'push')
      $scope.saveVoteSuccess(event)
      expect($scope.discussion.events.push).toHaveBeenCalledWith(event)

  describe 'saveVoteError', ->
    errors = null
    beforeEach ->
      errors = ['no bananas today']
      $scope.saveVoteError(errors)

    it 'enables the voteForm', ->
      expect($scope.voteFormIsDisabled).toBe(false)

    it 'sets the voteErrorMessages', ->
      expect($scope.voteErrorMessages).toBe(errors)

