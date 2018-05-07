emojione = require 'emojione'

AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'
I18n      = require 'shared/services/i18n'

{ emojiTitle } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'emojiPicker', ['$timeout', ($timeout)->
  scope: {reaction: '='}
  restrict: 'E'
  templateUrl: 'generated/components/emoji_picker/emoji_picker.html'
  controller: ['$scope', ($scope) ->
    $scope.render = emojione.shortnameToImage

    $scope.translate = (shortname) ->
      title = I18n.t emojiTitle(shortname)
      if _.startsWith(title, "reactions.") then shortname else title

    $scope.imgSrcFor = (emoji) ->
      unicode = emojione.emojioneList[emoji].unicode[emojione.emojioneList[emoji].unicode.length-1];
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
      EventBus.emit $scope, 'emojiSelected', emoji

    $scope.noEmojisFound = ->
      $scope.source.length == 0
  ]
]
