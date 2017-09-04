angular.module('loomioApp').directive 'reactionsDisplay', (Session, Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/reactions/display/reactions_display.html'
  replace: true
  controller: ($scope) ->
    $scope.diameter = 16
    $scope.current = 'all'
    $scope.sanitize = (reaction) ->
      return 'all' unless reaction
      reaction.reaction.replace(/:/g, '')

    $scope.reactionHash = ->
      Records.reactions.find(
        reactableType: _.capitalize($scope.model.constructor.singular)
        reactableId:   $scope.model.id
      ).reduce (hash, reaction) ->
        hash[reaction.reaction] = hash[reaction.reaction] or []
        hash[reaction.reaction].push  reaction.userId
        hash.all.push reaction.userId
        hash
      , { all: [] }

    $scope.reactions = ->
      _.difference _.keys($scope.reactionHash()), ['all']

    $scope.setCurrent = (reaction) ->
      $scope.current = reaction or 'all'

    $scope.isInactive = (reaction) ->
      $scope.current != 'all' and $scope.current != reaction

    $scope.maxNamesCount = 5
    $scope.namesFor = (reaction) ->
      _.pluck Records.users.find($scope.reactionHash()[reaction]), 'name'

    $scope.countFor = (reaction) ->
      $scope.namesFor(reaction).length - $scope.maxNamesCount

    Records.reactions.fetch(params:
      reactable_type: _.capitalize($scope.model.constructor.singular)
      reactable_id: $scope.model.id
    ).finally -> $scope.loaded = true
