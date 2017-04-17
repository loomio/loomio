angular.module('loomioApp').directive 'pollPollForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/poll/form/poll_poll_form.html'
  controller: ($scope, PollService, KeyEventService, TranslationService) ->
    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_poll_form.title_placeholder'
      detailsPlaceholder:   'poll_poll_form.details_placeholder'
      addOptionPlaceholder: 'poll_poll_form.add_option_placeholder'

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$broadcast('addPollOption')

    KeyEventService.submitOnEnter($scope)
