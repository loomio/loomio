describe 'addComment directive', ->
  $scope = {}
  element = {}
  form = {}
  fakeInput = {}
  realInput = {}

  beforeEach module 'loomioApp'

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope
    element = $compile('<add_comment></add_comment>')($rootScope)
    $rootScope.$digest()

  describe 'by default', ->
    it 'has an input field for collapsed mode', ->
      expect(element.find('.fake input').length).toBe(1)

    it 'has a textarea for expanded mode', ->
      expect(element.find('.real textarea').length).toBe(1)

    it 'is not expanded by default', ->
      expect($scope.isExpanded).toBe(false)

    it 'starts with the textarea hidden', ->
      expect(element.find('.real')).toHaveClass('ng-hide')

    it 'starts with the fake input showing', ->
      expect(element.find('.fake')).not.toHaveClass('ng-hide')

  describe 'collapseIfEmpty()', ->
    beforeEach ->
      $scope.isExpanded = true

    describe 'when there is text in the real textarea', ->
      beforeEach ->
        element.find('.real textarea').val('hi im some text')

      it 'does not collapse', ->
        $scope.collapseIfEmpty()
        expect($scope.isExpanded).toBe(true)

    describe 'when the comment textarea is empty', ->
      beforeEach ->
        $scope.collapseIfEmpty()

      it 'collapses', ->
        expect($scope.isExpanded).toBe(false)

