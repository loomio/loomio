angular.module('loomioApp').factory 'ReactionService', ($translate, Records, Session, LoadingService) ->
  new class ReactionService

    listenForReactions: ($scope, model) ->
      $scope.currentUserReaction = ->
        _.first Records.reactions.find
          reactableId:   model.id
          reactableType: _.capitalize(model.constructor.singular)
          userId:        Session.user().id

      $scope.react = ->
        Records.reactions.build(
          reactableId:   model.id
          reactableType: _.capitalize(model.constructor.singular)
          reaction: '+1'
        ).save()
      LoadingService.applyLoadingFunction $scope, 'react'

      $scope.unreact = ->
        $scope.currentUserReaction().destroy()
      LoadingService.applyLoadingFunction $scope, 'unreact'

      $scope.reactionSentence = ->
        return '' unless model.reactors().length
        otherNames  = _.pluck _.without(model.reactors(), Session.user()), 'name'
        translateKey = if $scope.reactExecuting or $scope.currentUserReaction()
          switch otherNames.length
            # You like this.
            when 0 then 'discussion.you_like_this'
            # liked by you and Rebeka.
            when 1 then 'discussion.liked_by_you_and_someone'
            # liked by you, Rebeka and Joshua.
            else        'discussion.liked_by_you_and_others'
        else
          switch otherNames.length
            # Liked by Rebeka.
            when 1 then 'discussion.liked_by_someone'
            # Liked by Rebeka and Joshua.
            when 2 then 'discussion.liked_by_two_others'
            # Liked by Rebeka, Someone and Joshua
            else        'discussion.liked_by_many_others'

        $translate.instant translateKey,
          joinedNames: _.initial(otherNames).join(', ')
          name:        _.last(otherNames)

      true
