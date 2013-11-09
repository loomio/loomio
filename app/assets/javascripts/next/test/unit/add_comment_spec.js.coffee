describe 'add_comment directive', ->
  $scope = {}
  element = {}
  form = {}
  beforeEach module 'LoomioApp'

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope
    element = $compile('<add-comment></add-comment>')($scope)
    $scope.digest()
    form = ->
      $.find 'form'

  it 'has an input field for collapsed mode', ->
    expect($(form).find('input').length).toBe(1)

  #it 'has a textarea for expanded mode', ->
    #expect(form.find('textarea').length).toBe(1)

  #it 'calls expand when input is focused'

  #it 'calls collapse when textarea is blurred'

  #describe 'expand', ->
    #it 'shows the textarea'
    #it 'focuses the textarea'
    #it 'hides the input field'

  #describe 'collapse', ->
    #it 'hides the textarea'
    #it 'shows the input'

