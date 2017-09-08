angular.module('loomioApp').directive 'reactionsDisplay', (Session, Records, EmojiService) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/reactions/display/reactions_display.html'
  replace: true
  controller: ($scope) ->
    $scope.diameter = 16
    $scope.current = 'all'

    $scope.reactions = ->
      Records.reactions.find
        reactableType: _.capitalize($scope.model.constructor.singular)
        reactableId:   $scope.model.id

    $scope.reactionNames = ->
      _.difference _.keys($scope.reactionHash()), ['all']

    $scope.reactionHash = ->
      $scope.reactions().reduce (hash, reaction) ->
        name = reaction.user().name
        hash[reaction.reaction] = hash[reaction.reaction] or []
        hash[reaction.reaction].push name
        hash.all.push name
        hash
      , { all: [] }

    $scope.translate = (reaction) ->
      EmojiService.translate(reaction)

    $scope.setCurrent = (reaction) ->
      $scope.current = reaction or 'all'

    $scope.isInactive = (reaction) ->
      $scope.current != 'all' and $scope.current != reaction

    $scope.maxNamesCount = 10

    $scope.countFor = (reaction) ->
      $scope.reactionHash()[reaction].length - $scope.maxNamesCount

    Records.reactions.fetch(params:
      reactable_type: _.capitalize($scope.model.constructor.singular)
      reactable_id: $scope.model.id
    ).finally -> $scope.loaded = true
