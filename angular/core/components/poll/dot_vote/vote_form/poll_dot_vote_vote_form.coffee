angular.module('loomioApp').directive 'pollDotVoteVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/dot_vote/vote_form/poll_dot_vote_vote_form.html'
  controller: ($scope, Records, FormService, TranslationService, MentionService, KeyEventService) ->
    $scope.vars = {}

    $scope.stanceChoiceFor = (option) ->
      _.first(_.filter($scope.stance.stanceChoices(), (choice) ->
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    $scope.optionFor = (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    $scope.tooManyDots = ->
      _.sum(_.pluck($scope.stanceChoices, 'score')) > $scope.stance.poll().customFields.dots_per_person

    $scope.stanceChoices = _.map $scope.stance.poll().pollOptions(), (option) ->
      poll_option_id: option.id
      score: $scope.stanceChoiceFor(option).score

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      successCallback: -> $scope.$emit 'stanceSaved'
      prepareFn: -> $scope.stance.stanceChoicesAttributes = $scope.stanceChoices
      flashSuccess: "poll_dot_vote_vote_form.stance_#{actionName}"
      draftFields: ['reason']

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
