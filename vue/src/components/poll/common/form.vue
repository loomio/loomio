<script lang="coffee">
export default
  props:
    poll: Object
    shouldReset: Boolean

  data: ->
    pollTypes: [
      {text: @$t('poll_common_form.voting_methods.single_choice'), value: "single_choice"}
      {text: @$t('poll_common_form.voting_methods.multiple_choice'), value: "multiple_choice"}
      {text: @$t('poll_common_form.voting_methods.score'), value: "score"}
      {text: @$t('poll_common_form.voting_methods.dot_vote'), value: "dot_vote"}
      {text: @$t('poll_common_form.voting_methods.ranked_choice'), value: "ranked_choice"}
      {text: @$t('poll_common_form.voting_methods.meeting'), value: "meeting"}
    ]

  methods:
    submit: ->
      actionName = if @poll.isNew() then 'created' else 'updated'
      @poll.customFields.can_respond_maybe = @poll.canRespondMaybe if @poll.pollType == 'meeting'
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

  poll-common-form-options-field(:poll="poll")
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
