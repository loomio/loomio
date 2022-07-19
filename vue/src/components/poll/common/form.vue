<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import { compact, without, kebabCase, snakeCase, some } from 'lodash'
import Flash from '@/shared/services/flash'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { addDays, addMinutes, intervalToDuration, formatDuration } from 'date-fns'
import { optionImages } from '@/shared/helpers/poll'
import { addHours, isAfter } from 'date-fns'
import PollCommonWipField from '@/components/poll/common/wip_field'
import { HandleDirective } from 'vue-slicksort';
import { isSameYear, startOfHour, setHours }  from 'date-fns'

export default
  components: { PollCommonWipField }
  directives: { handle: HandleDirective }

  props:
    poll: Object
    shouldReset: Boolean
    redirectOnSave: Boolean

  mounted: ->
    Records.users.fetchGroups()
    @watchRecords
      collections: ['groups', 'memberships']
      query: =>
        @groupItems = [
          {text: @$t('discussion_form.none_invite_only_thread'), value: null}
        ].concat Session.user().groups().map (g) ->
          {text: g.fullName, value: g.id}

  data: ->
    tab: 0
    newOption: null
    lastPollType: @poll.pollType
    pollOptions: @getPollOptions()
    groupItems: []
    pollTypeItems: compact Object.keys(AppConfig.pollTypes).map (key) =>
      pollType = AppConfig.pollTypes[key]
      return null unless pollType.template
      {text: @$t('poll_common_form.voting_methods.'+pollType.vote_method), value: key}
    chartTypeItems: [
      {text: 'bar', value: 'bar'}
      {text: 'pie', value: 'pie'}
      {text: 'grid', value: 'grid'}
    ]
    currentHideResults: @poll.hideResults
    hideResultsItems: [
      { text: @$t('common.off'), value: 'off' }
      { text: @$t('poll_common_card.until_vote'), value: 'until_vote' }
      { text: @$t('poll_common_card.until_poll_type_closed', pollType: @poll.translatedPollType()), value: 'until_closed' }
    ]
    newDateOption: startOfHour(setHours(new Date(), 12))
    minDate: new Date()
    closingAtWas: null

  methods:
    setPollOptionPriority: ->
      i = 0
      @pollOptions.forEach (o) -> o.priority = 0
      @visiblePollOptions.forEach (o) -> o.priority = i++

    getPollOptions: ->
      if @poll.pollOptionNames.length
        console.log 'names has length'
        @poll.pollOptions()
      else
        common_poll_options = AppConfig.pollTypes[@poll.pollType].common_poll_options || []
        options = common_poll_options.filter((o) -> o.default)
          .map((o) -> structuredClone(o))
          .map (o) =>
            o.name = @$t(o.name_i18n)
            o.meaning = @$t(o.meaning_i18n)
            o.prompt = @$t(o.prompt_i18n)
            o
          .map (o) -> Records.pollOptions.build(o)
        options

    settingDisabled: (setting) ->
      !@poll.closingAt || (!@poll.isNew() && setting == 'anonymous')
    snakify: (setting) -> snakeCase setting
    kebabify: (setting) -> kebabCase setting

    clearOptionsIfRequired: (newValue) ->
      if newValue == 'meeting' || @lastPollType == 'meeting'
        @pollOptions = []
      @lastPollType = newValue

    removeOption: (option) ->
      @newOption = null
      if option.id
        option.name = null
        option['_destroy'] = 1
      else
        @pollOptions = without(@pollOptions, option)

    addDateOption: ->
      @newOption = @newDateOption.toJSON()
      @addOption()

    addOption: ->
      if some(@pollOptions, (o) => o.name == @newOption)
        Flash.error('poll_poll_form.option_already_added')
      else
        knownOption = (AppConfig.pollTypes[@poll.pollType].common_poll_options || []).find (o) =>
          @$t(o.name_i18n).toLowerCase() == @newOption.toLowerCase()

        if knownOption
          @pollOptions.push Records.pollOptions.build(
            name: @newOption
            icon:  knownOption.icon
            meaning: @$t(knownOption.meaning_i18n)
            prompt: @$t(knownOption.prompt_i18n)
          )
        else
          @pollOptions.push Records.pollOptions.build(
            name: @newOption
            icon: 'agree'
          )

        @newOption = null

    editOption: (option) ->
      EventBus.$emit 'openModal',
        component: 'PollOptionForm'
        props:
          pollOption: option
          poll: @poll

    submit: ->
      actionName = if @poll.isNew() then 'created' else 'updated'
      @poll.setErrors({})
      @setPollOptionPriority()
      @poll.pollOptionsAttributes = @pollOptions.map (o) -> o.serialize().poll_option
      @poll.save()
      .then (data) =>
        poll = Records.polls.find(data.polls[0].id)
        @$router.replace(@urlFor(poll)) if @redirectOnSave
        @$emit('saveSuccess', poll)
        Flash.success "poll_common_form.poll_type_started", {poll_type: poll.translatedPollTypeCaps()}
        if actionName == 'created'
          EventBus.$emit 'openModal',
            component: 'PollMembers',
            props:
              poll: poll
      .catch (error) =>
        Flash.error 'common.something_went_wrong'
        console.error error

  watch:
    'poll.template': (val) -> 
      if val
        @closingAtWas = @poll.closingAt
        @poll.closingAt = null
      else
        @poll.closingAt = @closingAtWas

  computed:
    formattedDuration: -> 
      return '' unless @poll.meetingDuration
      minutes = parseInt(@poll.meetingDuration)
      duration = intervalToDuration({ start: new Date, end: addMinutes(new Date, minutes) })
      formatDuration(duration, { format: ['hours', 'minutes'] })

    visiblePollOptions: -> @pollOptions.filter (o) -> !o._destroy
    
    allowAnonymous: -> !@poll.config().prevent_anonymous
    stanceReasonRequiredItems: ->
      [
        {text: @$t('poll_common_form.stance_reason_required'), value: 'required'},
        {text: @$t('poll_common_form.stance_reason_optional'), value: 'optional'},
        {text: @$t('poll_common_form.stance_reason_disabled'), value: 'disabled'}
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

    optionFormat: -> @poll.pollOptionNameFormat
    hasOptionIcon: -> @poll.config().has_option_icon
    i18nItems: -> 
      compact 'agree abstain disagree consent objection block yes no'.split(' ').map (name) =>
        return null if @poll.pollOptionNames.includes(name)
        text: @$t('poll_proposal_options.'+name)
        value: name

</script>
<template lang="pug">
.poll-common-form
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.ml-n4.headline(tabindex="-1" v-t="{path: title_key, args: {'pollType': poll.translatedPollType()}}")
    v-spacer
    v-btn(v-if="poll.id" icon :to="urlFor(poll)" aria-hidden='true')
      v-icon mdi-close
    v-btn(v-if="!poll.id" icon @click="$emit('setPoll', null)" aria-hidden='true')
      v-icon mdi-close

  v-tabs(v-model="tab")
    v-tabs-slider(color="primary")
    v-tab.poll-common-form__details-tab(v-t="'poll_common.decision'")
    v-tab.poll-common-form__settings-tab(v-t="'poll_common_form.process'")

  v-tabs-items.pt-4(v-model="tab")
    v-tab-item.poll-common-form__details-tab.poll-common-form-fields
      v-select(
        v-if="!poll.id && !poll.discussionId"
        v-model="poll.groupId"
        :items="groupItems"
        :label="$t('common.group')"
      )

      v-text-field.poll-common-form-fields__title.text-h5(
        type='text'
        required='true'
        :hint="$t('poll_common_form.title_hint')"
        :label="$t('poll_common_form.title')"
        v-model='poll.title'
        maxlength='250')
      validation-errors(:subject='poll' field='title')
      //- tags-field(:model="poll")

      lmo-textarea(
        :model='poll'
        field="details"
        :placeholder="$t('poll_common_form.details_placeholder')"
        :label="$t('poll_common_form.details')"
        :should-reset="shouldReset"
      )

      .v-label.v-label--active.px-0.text-caption.py-2(v-t="'poll_common_form.options'")
      v-subheader.px-0(v-if="!pollOptions.length" v-t="'poll_common_form.no_options_add_some'")
      sortable-list(v-model="pollOptions" append-to=".app-is-booted" use-drag-handle lock-axis="y")
        sortable-item(
          v-for="(option, priority) in visiblePollOptions"
          :index="priority"
          :key="option.name"
          :item="option"
          v-if="pollOptions.length"
        )
          v-sheet.mb-2.rounded(outlined)
            v-list-item(style="user-select: none")
              v-list-item-icon(v-if="hasOptionIcon" v-handle)
                v-avatar(size="48")
                  img(:src="'/img/' + option.icon + '.svg'" aria-hidden="true")
           
              v-list-item-content(v-handle)
                v-list-item-title
                  span(v-if="optionFormat == 'i18n'" v-t="'poll_proposal_options.'+option.name")
                  span(v-if="optionFormat == 'plain'") {{option.name}}
                  span(v-if="optionFormat == 'iso8601'")
                    poll-meeting-time(:name="option.name")
                v-list-item-subtitle {{option.meaning}}

              v-list-item-action
                v-btn(icon @click="removeOption(option)", :title="$t('common.action.delete')")
                  v-icon.text--secondary mdi-delete
              v-list-item-action.ml-0(v-if="poll.pollType != 'meeting'")
                v-btn(icon @click="editOption(option)", :title="$t('common.action.edit')")
                  v-icon.text--secondary mdi-pencil
              v-icon.text--secondary(v-handle, :title="$t('common.action.move')" v-if="poll.pollType != 'meeting'") mdi-drag-vertical

      template(v-if="optionFormat == 'i18n'")
        v-select(
          outlined
          v-model="newOption"
          :items="i18nItems" 
          :label="$t('poll_poll_form.add_option_placeholder')"
          @change="addOption")

      template(v-if="optionFormat == 'plain'")
        v-text-field.poll-poll-form__add-option-input.mt-4(
          v-model="newOption"
          :label="$t('poll_poll_form.new_option')"
          :placeholder="$t('poll_poll_form.add_option_hint')"
          @keydown.enter="addOption"
          filled
          rounded
          color="primary"
        )
          template(v-slot:append)
            v-btn.mt-n2(@click="addOption", icon, :disabled="!newOption" color="primary" outlined :title="$t('poll_poll_form.add_option_placeholder')")
              v-icon mdi-plus

      template(v-if="optionFormat == 'iso8601'")
        .v-label.v-label--active.px-0.text-caption.pt-2(v-t="'poll_poll_form.new_option'")
        .d-flex.align-center
          date-time-picker(:min="minDate" v-model="newDateOption")
          v-btn.poll-meeting-form__option-button.ml-4(
            :title="$t('poll_meeting_time_field.add_time_slot')"
            outlined color="primary"
            @click='addDateOption()'
            v-t="'poll_poll_form.add_option_placeholder'"
          )
        poll-meeting-add-option-menu(:poll="poll", :value="newDateOption")

      template(v-if="optionFormat == 'iso8601'")
        .d-flex.align-center
          v-text-field.text-right(
            style="max-width: 120px; text-align: right"
            :label="$t('poll_meeting_form.meeting_duration')"
            v-model="poll.meetingDuration"
            type="number"
          )
          span.pl-2(v-t="'common.minutes'")
          span.pl-1.text--secondary(v-if="formattedDuration") ({{formattedDuration}})

       
      v-divider.my-4

      poll-common-wip-field(:poll="poll")
      poll-common-closing-at-field(:poll="poll")
        
      common-notify-fields(:model="poll")

    v-tab-item.poll-common-form__settings-tab
      v-checkbox(
        v-if="poll.groupId && !poll.discussionId"
        v-model="poll.template"
        :label="$t('poll_common_form.this_is_a_template_for_new_decisions')"
      ) 
      template(v-if="poll.template")
        v-text-field(
           v-model="poll.processTitle"
          :label="$t('poll_common_form.process_title')"
          :hint="$t('poll_common_form.process_title_hint')")
        validation-errors(:subject='poll' field='processTitle')

        v-text-field(
           v-model="poll.processSubtitle"
          :label="$t('poll_common_form.process_subtitle')"
          :hint="$t('poll_common_form.process_subtitle_hint')")
        validation-errors(:subject='poll' field='processSubtitle')

        lmo-textarea(
          :model='poll'
          field="processDescription"
          :placeholder="$t('poll_common_form.process_description_hint')"
          :label="$t('poll_common_form.process_description')"
          :should-reset="shouldReset"
        )

        .text-h5.my-4 Voting method
        v-select(
          :label="$t('poll_common_form.voting_method')"
          v-model="poll.pollType"
          @change="clearOptionsIfRequired"
          :items="pollTypeItems"
        )
        p.text--secondary(v-t="'poll_common_form.voting_methods.'+poll.config().vote_method+'_hint'")
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
        v-text-field(:label="$t('poll_dot_vote_form.dots_per_person')" type="number", min="1", v-model="poll.dotsPerPerson")
        validation-errors(:subject="poll" field="dotsPerPerson")


      .text-h5.mb-4.mt-8(v-t="'poll_common_card.hide_results'")
      p.text--secondary(v-t="'poll_common_form.hide_results_description'")
      v-select.poll-common-settings__hide-results(
        v-if="allowAnonymous"
        :label="$t('poll_common_card.hide_results')"
        :items="hideResultsItems"
        v-model="poll.hideResults"
        :disabled="!poll.closingAt || (!poll.isNew() && currentHideResults == 'until_closed')"
      )

      .text-h5.mb-4.mt-8(v-t="'poll_common_form.anonymous_voting'")
      p.text--secondary(v-t="'poll_common_form.anonymous_voting_description'")
      v-checkbox.poll-common-checkbox-option(
        hide-details
        v-if="allowAnonymous"
        :disabled="!poll.closingAt || !poll.isNew()"
        v-model="poll.anonymous"
        :label="$t('poll_common_form.votes_are_anonymous')")

      v-checkbox.poll-common-checkbox-option.poll-settings-shuffle-options(
        v-if="poll.config().can_shuffle_options"
        hide-details
        v-model="poll.shuffleOptions"
        :label="$t('poll_common_settings.shuffle_options.title')")

      v-checkbox.poll-common-checkbox-option.poll-settings-can-respond-maybe(
        v-if="poll.pollType == 'meeting'"
        hide-details
        v-model="poll.canRespondMaybe"
        :label="$t('poll_common_settings.can_respond_maybe.title')")

      .text-h5.mb-4.mt-8(v-t="'poll_common_form.vote_reason'")
      p.text--secondary(v-t="'poll_common_form.vote_reason_description'")
      v-select(
        :label="$t('poll_common_form.stance_reason_required_label')"
        :items="stanceReasonRequiredItems"
        v-model="poll.stanceReasonRequired"
      )

      v-text-field(
        v-if="poll.stanceReasonRequired != 'disabled' && (!poll.config().per_option_reason_prompt)"
        v-model="poll.reasonPrompt"
        :label="$t('poll_common_form.reason_prompt')"
        :hint="$t('poll_option_form.prompt_hint')"
        :placeholder="$t('poll_common.reason_placeholder')")
      p.text-caption.text--secondary(
        v-if="poll.stanceReasonRequired != 'disabled' && poll.config().per_option_reason_prompt"
        v-t="'poll_common_form.you_can_set_a_prompt_per_option'")

      v-checkbox.poll-common-checkbox-option.mt-0.mb-4(
        v-if="poll.stanceReasonRequired != 'disabled'"
        hide-details
        v-model="poll.limitReasonLength"
        :label="$t('poll_common_form.limit_reason_length')"
      )

      //- v-select(
        :label="$t('poll_common_form.chart_type')"
        v-model="poll.chartType"
        :items="chartTypeItems")
      //- chartType
      //- chartColumn

      .poll-common-notify-on-closing-soon
        .text-h5.mb-4.mt-8(v-t="'poll_common_form.reminder'")
        p.text--secondary(v-t="'poll_common_form.reminder_helptext'")
        p(v-if="!reminderEnabled" v-t="{path: 'poll_common_settings.notify_on_closing_soon.closes_too_soon', args: {pollType: poll.translatedPollType()}}")
        v-select(
          v-if="reminderEnabled"
          :disabled="!poll.closingAt"
          :label="$t('poll_common_settings.notify_on_closing_soon.title', {pollType: poll.translatedPollType()})"
          v-model="poll.notifyOnClosingSoon"
          :items="closingSoonItems")

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

  .d-flex.justify-space-between.my-4.mt-8.poll-common-form-actions
    help-link(path="en/user_manual/polls/starting_proposals" text="poll_poll_form.help_starting_polls")
    v-spacer
    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit()'
      :loading="poll.processing"
      :disabled="pollOptions.length == 0"
    )
      span(v-if='poll.id' v-t="'common.action.save_changes'")
      span(v-if='!poll.id && poll.closingAt' v-t="'poll_common_form.start_poll'")
      span(v-if='!poll.id && !poll.closingAt' v-t="'poll_common_form.save_poll'")

</template>
