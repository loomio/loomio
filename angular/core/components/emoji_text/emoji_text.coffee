angular.module('loomioApp').directive 'emojiText', ->
  restrict: 'A'
  templateUrl: 'generated/components/emoji_text/emoji_text.html'
  scope:
    emojiText: '=emojiText'
  controller: ($scope, EmojiService, $sanitize) ->
    $scope.html = ->
      $sanitize EmojiService.render($scope.emojiText)
