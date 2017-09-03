angular.module('loomioApp').directive 'reactionsInput', (Session, Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/reactions/input/reactions_input.html'
  controller: ($scope) ->

    $scope.$on 'emojiSelected', (_event, emoji) ->
      params =
        reactableType: _.capitalize($scope.model.constructor.singular)
        reactableId:   $scope.model.id
        userId:        Session.user().id
      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = emoji
      reaction.save()
