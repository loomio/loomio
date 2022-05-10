<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { compact, without } from 'lodash'
import Flash from '@/shared/services/flash'
import { addDays, addMinutes, intervalToDuration, formatDuration } from 'date-fns'
import { optionImages } from '@/shared/helpers/poll'

export default
  props:
    poll: Object
    shouldReset: Boolean

  data: ->
    newOption: null
    lastPollType: @poll.pollType
    optionImages: optionImages()
    pollTypeItems: compact Object.keys(AppConfig.pollTypes).map (key) =>
      pollType = AppConfig.pollTypes[key]
      return null unless pollType.enabled
      {text: @$t('poll_common_form.voting_methods.'+pollType.vote_method), value: key}

    durations:
      [5, 10, 15, 20, 30, 45, 60, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, null].map (minutes) =>
        if minutes
          duration = intervalToDuration({ start: new Date, end: addMinutes(new Date, minutes) })
          {text: formatDuration(duration, { format: ['hours', 'minutes'] }), value: minutes}
        else
          {text: @$t('common.all_day'), value: null}

  methods:
    clearOptionsIfRequired: (newValue) ->
      if newValue == 'meeting' || @lastPollType == 'meeting'
        @poll.pollOptionNames = [] 
      @lastPollType = newValue

    removeOptionName: (optionName) ->
      @poll.pollOptionNames = without(@poll.pollOptionNames, optionName)

    addOption: ->
      if @poll.addOption(@newOption)
        @newOption = null
      else
        Flash.error('poll_poll_form.option_already_added')

    submit: ->
      actionName = if @poll.isNew() then 'created' else 'updated'
      @poll.setErrors({})
      @poll.save()
      .then (data) =>
        pollKey = data.polls[0].key
        Records.polls.findOrFetchById(pollKey, {}, true).then (poll) =>
          @$router.replace(@urlFor(poll))
          Flash.success "poll_#{poll.pollType}_form.#{poll.pollType}_#{actionName}"
      .catch => true

  computed:
    optionFormat: -> @$pollTypes[@poll.pollType].poll_option_name_format
    i18nItems: -> 
      compact 'agree abstain disagree yes no consent objection block'.split(' ').map (name) =>
        return null if @poll.pollOptionNames.includes(name)
        text: @$t('poll_proposal_options.'+name)
        value: name

</script>
<template lang="pug">
.poll-common-form
  v-text-field(
     v-model="poll.processName"
    :label="$t('poll_common_form.process_name')"
    :hint="$t('poll_common_form.process_name_hint')")
  validation-errors(:subject='poll' field='processName')

  v-text-field.poll-common-form-fields__title.text-h5(
    type='text'
    required='true'
    :placeholder="$t('poll_common_form.title_'+poll.pollType+'_placeholder')"
    :label="$t('poll_common_form.title')"
    v-model='poll.title'
    maxlength='250')
  validation-errors(:subject='poll' field='title')

  tags-field(:model="poll")

  lmo-textarea(
    :model='poll'
    field="details"
    :placeholder="$t('poll_common_form.details_placeholder')"
    :label="$t('poll_common_form.details')"
    :should-reset="shouldReset")

  v-select(
    :label="$t('poll_common_form.voting_method')"
    v-model="poll.pollType"
    @change="clearOptionsIfRequired"
    :hint="$t('poll_common_form.voting_methods.'+$pollTypes[poll.pollType].vote_method+'_hint')"
    :items="pollTypeItems")

  v-divider.my-4
  v-list
    v-subheader.px-0(v-t="'poll_common_form.options'")
    v-subheader.px-0(v-if="!poll.pollOptionNames.length" v-t="'poll_common_form.no_options_add_some'")
    v-list-item.px-0(:key="name" v-for="name in poll.pollOptionNames" v-if="poll.pollOptionNames.length")
      v-list-item-icon(v-if="optionFormat == 'i18n'")
        v-avatar(size="36px")
          img(:src="'/img/' + optionImages[name] + '.svg'" aria-hidden="true")
 
      v-list-item-content
        v-list-item-title
          span(v-if="optionFormat == 'i18n'" v-t="'poll_proposal_options.'+name") {{name}}
          span(v-if="optionFormat == 'none'") {{name}}
          span(v-if="optionFormat == 'iso8601'")
            poll-meeting-time(:name="name")

      v-list-item-action
        v-btn(icon outlined @click="removeOptionName(name)")
          v-icon mdi-minus

  template(v-if="optionFormat == 'i18n'")
    v-select(
      outlined
      v-model="newOption"
      :items="i18nItems" 
      :label="$t('poll_poll_form.add_option_placeholder')"
      @change="addOption")

  template(v-if="optionFormat == 'none'")
    v-text-field(
      v-model="newOption"
      :label="$t('poll_poll_form.add_option_placeholder')"
      @keydown.enter="addOption"
      append-outer-icon="mdi-plus"
      @click:append-outer="addOption"
      outlined
      color="primary"
    )

  template(v-if="optionFormat == 'iso8601'")
    poll-meeting-add-option-menu(:poll="poll")
    v-select(
      v-model="poll.meetingDuration"
      :label="$t('poll_meeting_form.meeting_duration')"
      :items="durations"
    )
  v-divider.my-4

  .d-flex(v-if="poll.pollType == 'score'")
    v-text-field.poll-score-form__min(
      v-model="poll.minScore"
      type="number"
      :step="1"
      :label="$t('poll_common.min_score')")
    v-spacer
    v-text-field.poll-score-form__max(
      v-model="poll.maxScore"
      type="number"
      :step="1"
      :label="$t('poll_common.max_score')")

  .d-flex.align-center(v-if="poll.pollType == 'ranked_choice'")
    v-text-field.lmo-number-input(
      v-model="poll.minimumStanceChoices"
      :label="$t('poll_ranked_choice_form.minimum_stance_choices_helptext')"
      type="number"
      :min="1"
      :max="poll.pollOptionNames.length")
    validation-errors(:subject="poll", field="minimumStanceChoices")

  template(v-if="poll.pollType == 'dot_vote'")
    v-subheader(v-t="'poll_dot_vote_form.dots_per_person'")
    v-text-field(type="number", min="1", v-model="poll.dotsPerPerson", single-line)
    validation-errors(:subject="poll" field="dotsPerPerson")

  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
  common-notify-fields(:model="poll")
  v-card-actions.poll-common-form-actions
    help-link(path="en/user_manual/polls/starting_proposals" text="poll_poll_form.help_starting_polls")
    v-spacer
    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit()'
      :loading="poll.processing"
    )
      span(v-if='!poll.id' v-t="'common.action.save_changes'")
      span(v-if='poll.id && poll.closingAt' v-t="'poll_common_form.start_poll'")
      span(v-if='poll.id && !poll.closingAt' v-t="'poll_common_form.save_poll'")

</template>
