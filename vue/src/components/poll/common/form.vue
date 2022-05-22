<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { compact, without, kebabCase, snakeCase } from 'lodash'
import Flash from '@/shared/services/flash'
import Records from '@/shared/services/records'
import { addDays, addMinutes, intervalToDuration, formatDuration } from 'date-fns'
import { optionImages } from '@/shared/helpers/poll'
import { addHours, isAfter } from 'date-fns'

export default
  props:
    poll: Object
    shouldReset: Boolean
    redirectOnSave: Boolean

  data: ->
    tab: 0
    newOption: null
    lastPollType: @poll.pollType
    optionImages: optionImages()
    pollTypeItems: compact Object.keys(AppConfig.pollTypes).map (key) =>
      pollType = AppConfig.pollTypes[key]
      return null unless pollType.template
      {text: @$t('poll_common_form.voting_methods.'+pollType.vote_method), value: key}

    durations:
      [5, 10, 15, 20, 30, 45, 60, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, null].map (minutes) =>
        if minutes
          duration = intervalToDuration({ start: new Date, end: addMinutes(new Date, minutes) })
          {text: formatDuration(duration, { format: ['hours', 'minutes'] }), value: minutes}
        else
          {text: @$t('common.all_day'), value: null}

    currentHideResults: @poll.hideResults
    hideResultsItems: [
      { text: @$t('common.off'), value: 'off' }
      { text: @$t('poll_common_card.until_vote'), value: 'until_vote' }
      { text: @$t('poll_common_card.until_poll_type_closed', pollType: @poll.translatedPollType()), value: 'until_closed' }
    ]


  methods:
    settingDisabled: (setting) ->
      !@poll.closingAt || (!@poll.isNew() && setting == 'anonymous')
    snakify: (setting) -> snakeCase setting
    kebabify: (setting) -> kebabCase setting

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
        poll = Records.polls.find(data.polls[0].id)
        @$router.replace(@urlFor(poll)) if @redirectOnSave
        @$emit('saveSuccess', poll)
        Flash.success "poll_common_form.poll_type_created", {poll_type: poll.translatedPollType()}
      .catch (error) =>
        Flash.error 'common.something_went_wrong'
        console.error error


  computed:
    allowAnonymous: -> !@poll.config().prevent_anonymous

    settings: ->
      compact [
        ('shuffleOptions'         if @poll.config().can_shuffle_options),
        ('canRespondMaybe'        if @poll.pollType == 'meeting'),
        ('anonymous'              if @allowAnonymous),
        ('allowLongReason')
      ]

    title_key: ->
      mode = if @poll.isNew()
        'action_dock.new_poll_type'
      else
        'action_dock.edit_poll_type'

    reminderEnabled: ->
      !@poll.closingAt || isAfter(@poll.closingAt, addHours(new Date(), 24))

    closingSoonItems: ->
      'nobody author undecided_voters voters'.split(' ').map (name) =>
        {text: @$t("poll_common_settings.notify_on_closing_soon.#{name}"), value: name}
    optionFormat: -> @poll.config().poll_option_name_format
    i18nItems: -> 
      compact 'agree abstain disagree yes no consent objection block'.split(' ').map (name) =>
        return null if @poll.pollOptionNames.includes(name)
        text: @$t('poll_proposal_options.'+name)
        value: name

</script>
<template lang="pug">
.poll-common-form
  v-card-title
    h1.ml-n4.headline(tabindex="-1" v-t="{path: title_key, args: {'pollType': poll.translatedPollType()}}")
    v-spacer
    v-btn(v-if="poll.id" icon :to="urlFor(poll)" aria-hidden='true')
      v-icon mdi-close
    v-btn(v-if="!poll.id" icon @click="$emit('setPoll', null)" aria-hidden='true')
      v-icon mdi-close

  v-tabs(v-model="tab")
   v-tabs-slider(color="yellow")
   v-tab(v-t="'poll_common.details'")
   v-tab(v-t="'common.settings'")
  v-tabs-items(v-model="tab")
    v-tab-item.poll-common-form__details-tab
      v-text-field.poll-common-form-fields__title.text-h5.mt-4(
        type='text'
        required='true'
        :hint="$t('poll_common_form.title_hint')"
        :label="$t('poll_common_form.title')"
        v-model='poll.title'
        maxlength='250')
      validation-errors(:subject='poll' field='title')

      lmo-textarea(
        :model='poll'
        field="details"
        :placeholder="$t('poll_common_form.details_placeholder')"
        :label="$t('poll_common_form.details')"
        :should-reset="shouldReset")
          v-divider.my-4

      v-list
        v-subheader.px-0(v-t="'poll_common_form.options'")
        v-subheader.px-0(v-if="!poll.pollOptionNames.length" v-t="'poll_common_form.no_options_add_some'")
        v-list-item.px-0(dense :key="name" v-for="name in poll.pollOptionNames" v-if="poll.pollOptionNames.length")
          v-list-item-icon(v-if="optionFormat == 'i18n'")
            v-avatar
              img(:src="'/img/' + optionImages[name] + '.svg'" aria-hidden="true")
     
          v-list-item-content
            v-list-item-title
              span(v-if="optionFormat == 'i18n'" v-t="'poll_proposal_options.'+name") {{name}}
              span(v-if="optionFormat == 'none'") {{name}}
              span(v-if="optionFormat == 'iso8601'")
                poll-meeting-time(:name="name")

          v-list-item-action
            v-btn(icon outlined @click="removeOptionName(name)")
              v-icon() mdi-minus

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

      poll-common-closing-at-field(:poll="poll")

      common-notify-fields(:model="poll")

    v-tab-item.poll-common-form__settings-tab
      v-text-field(
         v-model="poll.processName"
        :label="$t('poll_common_form.process_name')"
        :hint="$t('poll_common_form.process_name_hint')")
      validation-errors(:subject='poll' field='processName')
      tags-field(:model="poll")

      v-select(
        :label="$t('poll_common_form.voting_method')"
        v-model="poll.pollType"
        @change="clearOptionsIfRequired"
        :hint="$t('poll_common_form.voting_methods.'+poll.config().vote_method+'_hint')"
        :items="pollTypeItems")

      //- chartType
      //- chartColumn

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

      .poll-common-notify-on-closing-soon
        p(v-if="!reminderEnabled" v-t="{path: 'poll_common_settings.notify_on_closing_soon.closes_too_soon', args: {pollType: poll.translatedPollType()}}")
        v-select(
          v-if="reminderEnabled"
          :disabled="!poll.closingAt"
          :label="$t('poll_common_settings.notify_on_closing_soon.title', {pollType: poll.translatedPollType()})"
          v-model="poll.notifyOnClosingSoon"
          :items="closingSoonItems")

      template(v-if="poll.pollType == 'dot_vote'")
        v-subheader(v-t="'poll_dot_vote_form.dots_per_person'")
        v-text-field(type="number", min="1", v-model="poll.dotsPerPerson", single-line)
        validation-errors(:subject="poll" field="dotsPerPerson")

      v-select.poll-common-settings__hide-results(
        v-if="allowAnonymous"
        :label="$t('poll_common_card.hide_results')"
        :items="hideResultsItems"
        v-model="poll.hideResults"
        :disabled="!poll.closingAt || (!poll.isNew() && currentHideResults == 'until_closed')"
      )

      v-checkbox.poll-common-checkbox-option(
        v-for="(setting, index) in settings"
        hide-details
        :disabled="settingDisabled(setting)"
        :key="index"
        v-model="poll[setting]"
        :class="'poll-settings-' + kebabify(setting)"
        :label="$t('poll_common_settings.' + snakify(setting) + '.title')")

      v-radio-group(
        v-model="poll.specifiedVotersOnly"
        :disabled="!poll.closingAt"
        :label="$t('poll_common_settings.who_can_vote')"
      )
        v-radio(
          v-if="poll.discussionId && !poll.groupId"
          :value="false"
          :label="$t('poll_common_settings.specified_voters_only_false_discussion')")
        v-radio(
          v-if="poll.groupId"
          :value="false"
          :label="$t('poll_common_settings.specified_voters_only_false_group')")
        v-radio.poll-common-settings__specified-voters-only(
          :value="true"
          :label="$t('poll_common_settings.specified_voters_only_true')")
      .caption.mt-n4(
        v-if="poll.specifiedVotersOnly"
        v-t="$t('poll_common_settings.invite_people_next', {poll_type: poll.translatedPollType()})")

      v-checkbox(
        v-if="poll.id"
        v-model="poll.template"
        :label="$t('poll_common_form.this_is_a_template_for_new_decisions')")

  .d-flex.justify-space-between.my-4.mt-8.poll-common-form-actions
    help-link(path="en/user_manual/polls/starting_proposals" text="poll_poll_form.help_starting_polls")
    v-spacer
    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit()'
      :loading="poll.processing"
    )
      span(v-if='poll.id' v-t="'common.action.save_changes'")
      span(v-if='!poll.id && poll.closingAt' v-t="'poll_common_form.start_poll'")
      span(v-if='!poll.id && !poll.closingAt' v-t="'poll_common_form.save_poll'")

</template>