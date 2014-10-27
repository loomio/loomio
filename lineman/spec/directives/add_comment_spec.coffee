#describe 'addComment directive', ->
  #$scope = {}
  #element = {}
  #discussion = {id: 1}

  #beforeEach module 'loomioApp'

  #beforeEach inject ($compile, $rootScope) ->
    #$scope = $rootScope
    #$rootScope.discussion = discussion
    #element = $compile('<add_comment discussion="discussion"></add_comment>')($rootScope)
    #$rootScope.$digest()

  #describe 'by default', ->
    #it 'has an input field for collapsed mode', ->
      #expect(element.find('.fake input').length).toBe(1)

    #it 'has a textarea for expanded mode', ->
      #expect(element.find('.real textarea').length).toBe(1)

    #it 'starts with the textarea hidden', ->
      #expect(element.find('.real')).toHaveClass('ng-hide')

    #it 'starts with the fake input showing', ->
      #expect(element.find('.fake')).not.toHaveClass('ng-hide')

