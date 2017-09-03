angular.module('loomioApp').factory 'ReactionService', (Records, Session) ->
  new class ReactionService

    listenForReactions: ($scope, model) ->
      $scope.$on 'emojiSelected', (_event, emoji) ->
        reaction = Records.reactions.find(
          reactableType: _.capitalize(model.constructor.singular)
          reactableId:   model.id
          userId:        Session.user().id
        )[0] || Records.reactions.build(params)
        reaction.reaction = emoji
        reaction.save()
