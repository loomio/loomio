Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'

{ emojiTitle } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'reactionsDisplay', ->
  scope: {model: '=', load: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/reactions/display/reactions_display.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.diameter = 16

    reactionParams = ->
      reactableType: _.capitalize($scope.model.constructor.singular)
      reactableId:   $scope.model.id

    $scope.removeMine = (reaction) ->
      mine = Records.reactions.find(_.merge(reactionParams(),
        userId:   Session.user().id
        reaction: reaction
      ))[0]
      mine.destroy() if mine

    $scope.myReaction = ->
      return unless AbilityService.isLoggedIn()
      Records.reactions.find(_.merge(reactionParams(), userId: Session.user().id))[0]

    $scope.otherReaction = ->
      Records.reactions.find(_.merge(reactionParams(), {userId: {'$ne': Session.user().id}}))[0]

    $scope.reactionTypes = ->
      _.difference _.keys($scope.reactionHash()), ['all']

    $scope.reactionHash = _.throttle ->
      Records.reactions.find(reactionParams()).reduce (hash, reaction) ->
        name = reaction.user().name
        hash[reaction.reaction] = hash[reaction.reaction] or []
        hash[reaction.reaction].push name
        hash.all.push name
        hash
      , { all: [] }
    , 250
    , {leading: true}

    $scope.translate = (shortname) ->
      title = emojiTitle(shortname)
      if _.startsWith(title, "reactions.") then shortname else title

    $scope.reactionTypes = ->
      _.difference _.keys($scope.reactionHash()), ['all']

    $scope.maxNamesCount = 10

    $scope.countFor = (reaction) ->
      $scope.reactionHash()[reaction].length - $scope.maxNamesCount

    if $scope.load
      Records.reactions.fetch(params:
        reactable_type: _.capitalize($scope.model.constructor.singular)
        reactable_id:   $scope.model.id
      ).finally ->
        $scope.loaded = true
    else
      $scope.loaded = true
  ]
