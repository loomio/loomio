angular.module('loomioApp').directive 'emojiPicker', ($translate, $timeout, EmojiService, KeyEventService)->
  scope: {reaction: '='}
  restrict: 'E'
  templateUrl: 'generated/components/emoji_picker/emoji_picker.html'
  controller: ($scope) ->
    $scope.translate = EmojiService.translate
    $scope.render = EmojiService.render
    $scope.imgSrcFor = EmojiService.imgSrcFor

    $scope.search = (term) ->
      $scope.hovered = {}
      $scope.source = if term
        _.take _.filter(EmojiService.source, (emoji) -> emoji.match(///^:#{term}///i)), 20
      else
        EmojiService.defaults
    $scope.search()

    $scope.toggleMenu = ($mdMenu, $event)->
      $mdMenu.open($event);
      $scope.search()
      if !$scope.reaction
        $timeout -> document.querySelector('.emoji-picker__search').focus()

    $scope.select = (emoji) ->
      $scope.$emit 'emojiSelected', emoji

    $scope.noEmojisFound = ->
      $scope.source.length == 0
