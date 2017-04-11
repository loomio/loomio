angular.module('loomioApp').directive 'pollDotVoteVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/dot_vote/vote_form/poll_dot_vote_vote_form.html'
  controller: ($scope, Records, PollService, TranslationService, MentionService, KeyEventService) ->
    $scope.vars = {}

    $scope.stanceChoiceFor = (option) ->
      _.first(_.filter($scope.stance.stanceChoices(), (choice) ->
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    $scope.adjust = (choice, amount) ->
      choice.score += amount

    $scope.optionFor = (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    $scope.dotsRemaining = ->
      $scope.stance.poll().customFields.dots_per_person - _.sum(_.pluck($scope.stanceChoices, 'score'))

    $scope.tooManyDots = ->
      $scope.dotsRemaining() < 0

    $scope.stanceChoices = _.map $scope.stance.poll().pollOptions(), (option) ->
      poll_option_id: option.id
      score: $scope.stanceChoiceFor(option).score

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        return unless _.sum(_.pluck($scope.stanceChoices, 'score')) > 0
        $scope.stance.stanceChoicesAttributes = $scope.stanceChoices

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
