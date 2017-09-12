angular.module('loomioApp').factory 'ReactionService', (Records, Session) ->
  new class ReactionService

    listenForReactions: ($scope, model) ->
      $scope.$on 'emojiSelected', (_event, emoji) ->
        reaction = Records.reactions.find(paramsFor(model))[0] ||
                   Records.reactions.build(paramsFor(model))
        reaction.reaction = emoji
        reaction.save()

    paramsFor = (model) ->
      reactableType: _.capitalize(model.constructor.singular)
      reactableId:   model.id
      userId:        Session.user().id
