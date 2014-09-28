#describe 'startProposal directive', ->
  #$scope = {}
  #element = {}
  #form = {}
  #fakeInput = {}
  #realInput = {}
  #discussion = {id: 1}

  #beforeEach module 'loomioApp'

  #beforeEach inject ($compile, $rootScope) ->
    #$scope = $rootScope
    #$rootScope.discussion = discussion
    #element = $compile('<start_proposal discussion="discussion"></start_proposal>')($rootScope)
    #$rootScope.$digest()

  #describe 'by default', ->
    #it 'starts with the form hidden', ->
      #expect(element.find('.form')).toHaveClass('ng-hide')

    #it 'starts with the cover showing', ->
      #expect(element.find('.cover')).not.toHaveClass('ng-hide')
