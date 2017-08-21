angular.module('loomioApp').factory 'ReactionService', ($translate, Records, Session) ->
  new class ReactionService

    listenForReactions: ($scope, model) ->
      updateReactionSentence = =>
        $scope.reactionSentence = @sentenceFor model

      addLiker = ->
        model.addLiker Session.user()
        updateReactionSentence()

      removeLiker = ->
        model.removeLiker Session.user()
        updateReactionSentence()

      recordStore = Records[model.constructor.plural]

      $scope.anybodyLikesIt = ->
        model.likerIds.length > 0

      $scope.currentUserLikesIt = ->
        _.contains model.likers(), Session.user()

      $scope.like = ->
        addLiker()
        recordStore.like(Session.user(), model).then (->), removeLiker

      $scope.unlike = ->
        removeLiker()
        recordStore.unlike(Session.user(), model).then (->), addLiker

      $scope.$watch 'model.likerIds', updateReactionSentence

    sentenceFor: (model) ->
      otherIds   = _.without(model.likerIds, Session.user().id)
      otherUsers = _.filter model.likers(), (user) -> _.contains(otherIds, user.id)
      otherNames = _.map otherUsers, (user) -> user.name

      if _.contains(model.likerIds, Session.user().id)
        switch otherNames.length
          when 0
            # You like this.
            $translate.instant('discussion.you_like_this')
          when 1
            # liked by you and Rebeka.
            $translate.instant('discussion.liked_by_you_and_someone',
                       name: otherNames[0])
          else
            # liked by you, Rebeka and Joshua.
            joinedNames = otherNames.slice(0, -1).join(', ')
            name = otherNames.slice(-1)[0]
            $translate.instant('discussion.liked_by_you_and_others',
                       joinedNames: joinedNames, name: name)
      else
        switch otherNames.length
          when 0
            ''
          when 1
            # Liked by Rebeka.
            $translate.instant('discussion.liked_by_someone', name: otherNames[0])
          when 2
            # Liked by Rebeka and Joshua.
            $translate.instant('discussion.liked_by_two_others', name_1: otherNames[0], name_2: otherNames[1])
          else
            # Liked by Rebeka, Someone and Joshua
            joinedNames = otherNames.slice(0, -1).join(', ')
            name = otherNames.slice(-1)[0]
            $translate.instant('discussion.liked_by_many_others', joinedNames: joinedNames, name: name)
