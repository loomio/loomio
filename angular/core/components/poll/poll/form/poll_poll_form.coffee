angular.module('loomioApp').factory 'PollPollForm', ->
  templateUrl: 'generated/components/poll/poll/form/poll_poll_form.html'
  controller: ($scope, poll, FormService, KeyEventService, TranslationService) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_poll_form.messages.#{actionName}"
      draftFields: ['title', 'details']

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_poll_form.title_placeholder'
      detailsPlaceholder: 'poll_poll_form.details_placeholder'

    $scope.addOption = ->
      return unless $scope.newOptionName.length > 0
      $scope.poll.pollOptionsAttributes.push
        name: $scope.newOptionName
      $scope.newOptionName = ''

    $scope.removeOption = (option) ->
      _.pull $scope.poll.pollOptionsAttributes, option

    KeyEventService.submitOnEnter($scope)
    # KeyEventService.registerKeyEvent $scope, 'pressedEnter', (active) ->
    #   $scope.addOption() if $scope.addOptionActive(active)
