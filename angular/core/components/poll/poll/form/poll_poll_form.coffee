angular.module('loomioApp').directive 'pollPollForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/form/poll_poll_form.html'
  controller: ($scope, FormService, KeyEventService, TranslationService) ->
    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_poll_form.title_placeholder'
      detailsPlaceholder:   'poll_poll_form.details_placeholder'
      addOptionPlaceholder: 'poll_poll_form.add_option_placeholder'

    $scope.addOption =  ->
      return unless $scope.newOptionName
      $scope.poll.pollOptionNames.push $scope.newOptionName
      $scope.newOptionName = ''

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.submit = FormService.submit $scope, $scope.poll,
      successCallback: (data) -> $scope.$emit 'pollSaved', data.polls[0].key
      flashSuccess: "poll_poll_form.poll_#{actionName}"
      draftFields: ['title', 'details']
      prepareFn: $scope.addOption

    KeyEventService.submitOnEnter($scope)
    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-poll-form__add-option-input')
