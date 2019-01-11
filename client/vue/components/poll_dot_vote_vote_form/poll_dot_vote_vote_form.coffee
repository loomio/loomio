Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitStance }  = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

module.exports =
  props:
    stance: Object
  data: ->
    vars: {}
  created: ->
    @setStanceChoices()
    EventBus.listen @, 'pollOptionsAdded', @setStanceChoices
  mounted: ->
    submitOnEnter @, element: @$el
  methods:
    percentageFor: (choice) ->
      max = @stance.poll().customFields.dots_per_person
      return unless max > 0
      "#{100 * choice.score / max}% 100%"

    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"

    styleData: (choice) ->
      option = @optionFor(choice)
      'border-color': option.color
      'background-image': @backgroundImageFor(option)
      'background-size': @percentageFor(choice)

    stanceChoiceFor: (option) ->
      _.head(_.filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    adjust: (choice, amount) ->
      choice.score += amount

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    dotsRemaining: ->
      @stance.poll().customFields.dots_per_person - _.sum(_.map(@stanceChoices, 'score'))

    tooManyDots: ->
      @dotsRemaining() < 0

    setStanceChoices: ->
      @stanceChoices = _.map @stance.poll().pollOptions(), (option) =>
        poll_option_id: option.id
        score: @stanceChoiceFor(option).score

    # submit: submitStance $scope, $scope.stance,
    #   prepareFn: ->
    #     EventBus.emit $scope, 'processing'
    #     $scope.stance.id = null
    #     return unless _.sum(_.map($scope.stanceChoices, 'score')) > 0
    #     $scope.stance.stanceChoicesAttributes = $scope.stanceChoices

  template:
    """
    <form @submit.prevent="submit()" class="poll-dot-vote-vote-form">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <div class="lmo-hint-text">
        <div v-if="tooManyDots()" v-t="'poll_dot_vote_vote_form.too_many_dots'" class="poll-dot-vote-vote-form__too-many-dots"></div>
        <div v-if="!tooManyDots()" v-t="{ path: 'poll_dot_vote_vote_form.dots_remaining', args: { count: dotsRemaining() } }" class="poll-dot-vote-vote-form__dots-remaining"></div>
      </div>
      <ul md-list class="poll-common-vote-form__options">
        <li md-list-item v-for="choice in stanceChoices" :key="choice.poll_option_id" class="poll-dot-vote-vote-form__option poll-common-vote-form__option">
          <div md-input-container class="poll-dot-vote-vote-form__input-container">
            <p :style="styleData(choice)" class="poll-dot-vote-vote-form__chosen-option--name poll-common-vote-form__border-chip poll-common-bar-chart__bar">{{ optionFor(choice).name }}</p>
            <div class="poll-dot-vote-vote-form__dot-input-field">
              <button type="button" @click="adjust(choice, -1)" :disabled="choice.score == 0" class="poll-dot-vote-vote-form__dot-button">
                <div class="mdi mdi-24px mdi-minus-circle-outline"></div>
              </button>
              <input type="number" v-model="choice.score" min="0" step="1" class="poll-dot-vote-vote-form__dot-input">
              <button type="button" @click="adjust(choice, 1)" :disabled="dotsRemaining() == 0" class="poll-dot-vote-vote-form__dot-button">
                <div class="mdi mdi-24px mdi-plus-circle-outline"></div>
              </button>
            </div>
          </div>
        </li>
      </ul>
      <validation-errors :subject="stance" field="stanceChoices"></validation-errors>
      <poll-common-stance-reason :stance="stance"></poll-common-stance-reason>
      <div class="poll-common-form-actions lmo-flex lmo-flex__space-between">
        <poll-common-show-results-button v-if="stance.isNew()"></poll-common-show-results-button>
        <div v-if="!stance.isNew()"></div>
        <button type="submit" :disabled="tooManyDots()" v-t="'poll_common.vote'" aria-label="$t('poll_poll_vote_form.vote')" class="md-primary md-raised poll-common-vote-form__submit"></button>
      </div>
    </form>
    """
