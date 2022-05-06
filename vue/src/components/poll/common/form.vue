<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { compact } from 'lodash'

export default
  props:
    poll: Object
    shouldReset: Boolean

  data: ->
    pollTypes: compact Object.keys(AppConfig.pollTypes).map (type) ->
      return null unless AppConfig.pollTypes[type].enabled
      {text: @$t(AppConfig.pollTypes[type].label), value: type}

    durations:
      [5, 10, 15, 20, 30, 45, 60, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, null].map (minutes) =>
        if minutes
          duration = intervalToDuration({ start: new Date, end: addMinutes(new Date, minutes) })
          {text: formatDuration(duration, { format: ['hours', 'minutes'] }), value: minutes}
        else
          {text: @$t('common.all_day'), value: null}

  methods:
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

</script>
<template lang="pug">
.poll-common-form
  v-text-field(
     v-model="poll.processName"
    :label="$t('poll_common_form.process_name')"
    :hint="$t('poll_common_form.process_name_hint')")

  v-select(
    v-model="poll.pollType"
    :items="pollTypes"
    :label="$t('poll_common_form.voting_method')")

  p.text--secondary(v-if="poll.pollType" v-t="'poll_common_form.voting_methods.'+poll.pollType+'_hint'")

  v-text-field.lmo-primary-form-input.poll-common-form-fields__title.text-h5(
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

  template(v-if="poll.pollType == 'meeting'")
    poll-meeting-form-options-field(
      :poll="poll"
      v-if="poll.pollType == 'meeting'")
    v-select(
      v-model="poll.meetingDuration"
      :label="$t('poll_meeting_form.meeting_duration')"
      :items="durations")
  template(v-else)
    poll-common-form-options-field(
      :poll="poll"
      v-if="poll.pollType != 'meeting'")

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
    validation-errors(:subject="poll", field="dotsPerPerson")

  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
  common-notify-fields(:model="poll")
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit' v-if='!poll.isNew()' :loading="poll.processing")
      span(v-t="'common.action.save_changes'")
    v-btn.poll-common-form__submit(color="primary" @click='submit' v-if='poll.closingAt && poll.isNew()' :loading="poll.processing")
      span(v-t="'poll_poll_form.start_header'")
    v-btn.poll-common-form__submit(color="primary" @click='submit' v-if='!poll.closingAt && poll.isNew()' :loading="poll.processing")
      span(v-t="{path: 'poll_common_form.start_poll_type', args: {poll_type: poll.translatedPollType()}}")

</template>
