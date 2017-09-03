angular.module('loomioApp').directive 'reactionsDisplay', ($translate, Session, Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/reactions/display/reactions_display.html'
  replace: true
  controller: ($scope) ->
    $scope.current = 'all'
    $scope.sanitize = (reaction) ->
      return 'all' unless reaction
      reaction.reaction.replace(/:/g, '')

    $scope.reactionHash = ->
      Records.reactions.find(
        reactableType: _.capitalize($scope.model.constructor.singular)
        reactableId:   $scope.model.id
      ).reduce (hash, reaction) ->
        r = $scope.sanitize reaction
        hash[r] = hash[r] or []
        hash[r].push  reaction.userId
        hash.all.push reaction.userId
        hash
      , { all: [] }

    $scope.setCurrent = (reaction) ->
      $scope.current = $scope.sanitize(reaction)

    $scope.isInactive = (reaction) ->
      $scope.current != 'all' and $scope.current != $scope.sanitize(reaction)

    $scope.reactionSentence = ->
      users = Records.users.find($scope.reactionHash()[$scope.current]).sort (a,b) ->
        -1 if a == Session.user()
      return unless users.length

      names = _.map users, (user) ->
        if user == Session.user()
          $translate.instant('common.you')
        else
          user.name

      translation = switch names.length
        when 1 then 'reactions_display.one_reaction'
        when 2 then 'reactions_display.two_reactions'
        else        'reactions_display.many_reactions'

      $translate.instant translation,
        first:  names[0]
        second: names[1]
        count:  names.length - 2

    Records.reactions.fetch(params:
      reactable_type: _.capitalize($scope.model.constructor.singular)
      reactable_id: $scope.model.id
    ).finally -> $scope.loaded = true
