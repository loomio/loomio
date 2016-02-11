angular.module('loomioApp').directive 'emojiPicker', ->
  scope: {targetSelector: '@'}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/emoji_picker/emoji_picker.html'
  controller: ($scope, $timeout, EmojiService, KeyEventService) ->
    $scope.render = EmojiService.render

    $scope.search = (term) ->
      $scope.hovered = {}
      $scope.source = if term
        _.take _.filter(EmojiService.source, (emoji) -> emoji.match term), 15
      else
        EmojiService.defaults
    $scope.search()

    $scope.toggleMenu = ->
      $scope.showMenu = !$scope.showMenu
      $scope.search()
      $timeout ->
        $scope.target().focus() if $scope.target()?

    $scope.target = ->
      if $scope.showMenu
        document.querySelector('.emoji-picker__search')
      else
        document.querySelector($scope.targetSelector)

    $scope.hideMenu = ->
      return unless $scope.showMenu
      $scope.hovered = {}
      $scope.term = ''
      $scope.toggleMenu()
    KeyEventService.registerKeyEvent $scope, 'pressedEsc', $scope.toggleMenu, -> $scope.showMenu

    $scope.hover = (emoji) ->
      $scope.hovered =
        name: emoji
        image: $scope.render(emoji)

    $scope.select = (emoji) ->
      $scope.$emit 'emojiSelected', emoji
      $scope.hideMenu()

    $scope.noEmojisFound = ->
      $scope.source.length == 0
