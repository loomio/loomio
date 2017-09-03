angular.module('loomioApp').directive 'reactionsDisplay', ($translate, Session, Records) ->
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

    $scope.$on 'emojiSelected', (_event, emoji) ->
      params =
        reactableType: _.capitalize($scope.model.constructor.singular)
        reactableId:   $scope.model.id
        userId:        Session.user().id
      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = emoji
      reaction.save()

    $scope.setCurrent = (reaction) ->
      $scope.current = reaction or 'all'

    $scope.isInactive = (reaction) ->
      $scope.current != 'all' and $scope.current != reaction

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
        reaction: ($scope.current unless $scope.current == 'all')

    Records.reactions.fetch(params:
      reactable_type: _.capitalize($scope.model.constructor.singular)
      reactable_id: $scope.model.id
    ).finally -> $scope.loaded = true
