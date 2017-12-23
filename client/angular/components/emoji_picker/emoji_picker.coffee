# TODO: emojione = require 'emojione' here
AppConfig = require 'shared/services/app_config.coffee'

{ translateEmoji } = require 'angular/helpers/emoji.coffee'

angular.module('loomioApp').directive 'emojiPicker', ($translate, $timeout, KeyEventService)->
  scope: {reaction: '='}
  restrict: 'E'
  templateUrl: 'generated/components/emoji_picker/emoji_picker.html'
  controller: ($scope) ->
    $scope.render = emojione.shortnameToImage

    $scope.translate = translateEmoji

    $scope.imgSrcFor = ->
      unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length-1];
      "#{emojione.imagePathPNG}#{unicode}.png#{emojione.cacheBustParam}"

    $scope.search = (term) ->
      $scope.hovered = {}
      $scope.source = if term
        _.take _.filter(emojione.shortnames.split("|"), (emoji) -> emoji.match(///^:#{term}///i)), 20
      else
        AppConfig.emojis.defaults
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
