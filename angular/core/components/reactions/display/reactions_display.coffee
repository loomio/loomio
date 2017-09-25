angular.module('loomioApp').directive 'reactionsDisplay', (Session, Records, EmojiService) ->
  scope: {model: '=', load: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/reactions/display/reactions_display.html'
  replace: true
  controller: ($scope) ->
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


    $scope.translate = (reaction) ->
      EmojiService.translate(reaction)

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
