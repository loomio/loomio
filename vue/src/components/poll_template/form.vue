<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import { compact, without, kebabCase, snakeCase, some } from 'lodash'
import Flash from '@/shared/services/flash'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import { addDays, addMinutes, intervalToDuration, formatDuration } from 'date-fns'
import { HandleDirective } from 'vue-slicksort';
import { isSameYear, startOfHour, setHours }  from 'date-fns'

export default
  directives: { handle: HandleDirective }

  props:
    isModal:
      default: false
      type: Boolean
    pollTemplate: Object

  data: ->
    newOption: null
    lastPollType: @pollTemplate.pollType
    pollOptions: @pollTemplate.pollOptionsAttributes()

    votingMethodsI18n:
      question: 
        title: 'poll_common_form.voting_methods.question'
        hint: 'poll_common_form.voting_methods.question_hint'
      proposal: 
        title: 'poll_common_form.voting_methods.show_thumbs'
        hint: 'poll_common_form.voting_methods.show_thumbs_hint'
      poll: 
        title: 'poll_common_form.voting_methods.simple_poll'
        hint: 'poll_common_form.voting_methods.choose_hint'
      meeting:
        title: 'poll_common_form.voting_methods.time_poll'
        hint: 'poll_common_form.voting_methods.time_poll_hint'
      dot_vote:
        title: 'decision_tools_card.dot_vote_title'
        hint: 'poll_common_form.voting_methods.allocate_hint'
      score: 
        title: 'poll_common_form.voting_methods.score'
        hint: 'poll_common_form.voting_methods.score_hint'
      ranked_choice:
        title: 'poll_common_form.voting_methods.ranked_choice'
        hint: 'poll_common_form.voting_methods.ranked_choice_hint'

    currentHideResults: @pollTemplate.hideResults
    hideResultsItems: [
      { text: @$t('common.off'), value: 'off' }
      { text: @$t('poll_common_card.until_you_vote'), value: 'until_vote' }
      { text: @$t('poll_common_card.until_voting_is_closed'), value: 'until_closed' }
    ]

  methods:
    setPollOptionPriority: ->
      i = 0
      @pollOptions.forEach (o) -> o.priority = i++

    removeOption: (option) ->
      @newOption = null
      @pollOptions = without(@pollOptions, option)

    addOption: ->
      if some(@pollOptions, (o) => o.name.toLowerCase() == @newOption.toLowerCase())
        Flash.error('poll_poll_form.option_already_added')
      else
        knownOption = @knownOptions.find (o) =>
          @$t(o.name_i18n).toLowerCase() == @newOption.toLowerCase()

        if knownOption
          @pollOptions.push
            name: @newOption
            icon:  knownOption.icon
            meaning: @$t(knownOption.meaning_i18n)
            prompt: @$t(knownOption.prompt_i18n)
        else
          option = 
            name: @newOption
            meaning: ''
            prompt: ''
            icon: 'agree'
          @pollOptions.push option
          if @pollTemplate.pollType == 'proposal'
            Flash.success('poll_common_form.option_added_please_add_details')
            @editOption(option)

        @newOption = null

    editOption: (option) ->
      EventBus.$emit 'openModal',
        component: 'PollOptionForm'
        props:
          pollOption: option
          poll: @pollTemplate

    submit: ->
      actionName = if @pollTemplate.isNew() then 'created' else 'updated'
      @pollTemplate.setErrors({})
      @setPollOptionPriority()
      @pollTemplate.pollOptions = @pollOptions
      @pollTemplate.save().then (data) =>
        Flash.success "poll_common.poll_template_saved"
        if @isModal
          EventBus.$emit('refreshPollTemplates')
          EventBus.$emit('closeModal')
        else
          @$router.push @$route.query.return_to
      .catch (error) =>
        Flash.warning 'poll_common_form.please_review_the_form'
        console.error error

  computed:
    breadcrumbs: ->
      compact([@pollTemplate.group().parentId && @pollTemplate.group().parent(), @pollTemplate.group()]).map (g) =>
        text: g.name
        disabled: false
        to: @urlFor(g)

    votingMethodsItems: ->
      Object.keys(@votingMethodsI18n).map (key) =>
        {text: @$t(@votingMethodsI18n[key].title), value: key}

    knownOptions: ->
      (AppConfig.pollTypes[@pollTemplate.pollType].common_poll_options || [])

    allowAnonymous: -> !@pollTemplate.config().prevent_anonymous
    stanceReasonRequiredItems: ->
      [
        {text: @$t('poll_common_form.stance_reason_required'), value: 'required'},
        {text: @$t('poll_common_form.stance_reason_optional'), value: 'optional'},
        {text: @$t('poll_common_form.stance_reason_disabled'), value: 'disabled'}
      ]

    titlePath: ->
      (@pollTemplate.isNew() && 'poll_common.new_poll_template') || 'poll_common.edit_poll_template'

    closingSoonItems: ->
      'nobody author undecided_voters voters'.split(' ').map (name) =>
        {text: @$t("poll_common_settings.notify_on_closing_soon.#{name}"), value: name}

    optionFormat: -> @pollTemplate.pollOptionNameFormat
    hasOptionIcon: -> @pollTemplate.config().has_option_icon
    i18nItems: -> 
      compact 'agree abstain disagree consent objection block yes no'.split(' ').map (name) =>
        return null if @pollTemplate.pollOptionNames.includes(name)
        text: @$t('poll_proposal_options.'+name)
        value: name

</script>
<template lang="pug">
.poll-common-form(:class="isModal ? 'pa-4' : ''") 
  submit-overlay(:value="pollTemplate.processing")
  .d-flex
    v-breadcrumbs.px-0.py-0(:items="breadcrumbs")
      template(v-slot:divider)
        v-icon mdi-chevron-right
    v-spacer
    dismiss-modal-button(v-if="isModal" :model='pollTemplate')
    v-btn.back-button(v-if="!isModal && $route.query.return_to" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
      v-icon mdi-close
  v-card-title.px-0
    h1.text-h4(tabindex="-1" v-t="titlePath")

  v-select(
    :label="$t('poll_common_form.voting_method')"
    v-model="pollTemplate.pollType"
    :items="votingMethodsItems"
    :hint="$t(votingMethodsI18n[pollTemplate.pollType].hint)"
  )

  v-text-field(
     v-model="pollTemplate.processName"
    :label="$t('poll_common_form.process_name')"
    :hint="$t('poll_common_form.process_name_hint')")
  validation-errors(:subject='pollTemplate' field='processName')

  v-text-field(
     v-model="pollTemplate.processSubtitle"
    :label="$t('poll_common_form.process_subtitle')"
    :hint="$t('poll_common_form.process_subtitle_hint')")
  validation-errors(:subject='pollTemplate' field='processSubtitle')

  lmo-textarea(
    :model='pollTemplate'
    field="processIntroduction"
    :placeholder="$t('poll_common_form.process_introduction_hint')"
    :label="$t('poll_common_form.process_introduction')"
  )

  //- v-text-field(
  //-    v-model="pollTemplate.processUrl"
  //-   :label="$t('poll_common_form.process_url')"
  //-   :hint="$t('poll_common_form.process_url_hint')")
  //- validation-errors(:subject='pollTemplate' field='processUrl')

  v-text-field.poll-common-form-fields__title(
    type='text'
    required='true'
    :hint="$t('poll_common_form.example_title_hint')"
    :label="$t('poll_common_form.example_title')"
    v-model='pollTemplate.title'
    maxlength='250')
  validation-errors(:subject='pollTemplate' field='title')

  tags-field(:model="pollTemplate")

  lmo-textarea(
    :model='pollTemplate'
    field="details"
    :placeholder="$t('poll_common_form.example_details_placeholder')"
    :label="$t('poll_common_form.example_details')"
  )
  
  .v-label.v-label--active.px-0.text-caption.py-2(v-t="'poll_common_form.options'")
  v-subheader.px-0(v-if="!pollOptions.length" v-t="'poll_common_form.no_options_add_some'")
  sortable-list(v-model="pollOptions" append-to=".app-is-booted" use-drag-handle lock-axis="y")
    sortable-item(
      v-for="(option, priority) in pollOptions"
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
            v-btn(
              icon
              @click="removeOption(option)"
              :title="$t('common.action.delete')"
            )
              v-icon.text--secondary mdi-delete
          v-list-item-action.ml-0
            v-btn(icon @click="editOption(option)", :title="$t('common.action.edit')")
              v-icon.text--secondary mdi-pencil
          v-icon.text--secondary(v-handle, :title="$t('common.action.move')") mdi-drag-vertical

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
      v-btn.mt-n2(
        @click="addOption"
        icon
        :disabled="!newOption"
        color="primary"
        outlined
        :title="$t('poll_poll_form.add_option_placeholder')")
        v-icon mdi-plus

  .d-flex(v-if="pollTemplate.pollType == 'score'")
    v-text-field.poll-score-form__min(
      v-model="pollTemplate.minScore"
      type="number"
      :step="1"
      :label="$t('poll_common.min_score')")
    v-spacer
    v-text-field.poll-score-form__max(
      v-model="pollTemplate.maxScore"
      type="number"
      :step="1"
      :label="$t('poll_common.max_score')")

  template(v-if="pollTemplate.pollType == 'poll'")
    p.text--secondary(v-t="'poll_common_form.how_many_options_can_a_voter_choose'")
    .d-flex
      v-text-field.poll-common-form__minimum-stance-choices(
        v-model="pollTemplate.minimumStanceChoices"
        type="number"
        :step="1"
        :hint="$t('poll_common_form.choose_at_least')"
        :label="$t('poll_common_form.minimum_choices')")
      v-spacer
      v-text-field.poll-common-form__maximum-stance-choices(
        v-model="pollTemplate.maximumStanceChoices"
        type="number"
        :step="1"
        :hint="$t('poll_common_form.choose_at_most')"
        :label="$t('poll_common_form.maximum_choices')")

  .d-flex.align-center(v-if="pollTemplate.pollType == 'ranked_choice'")
    v-text-field.lmo-number-input(
      v-model="pollTemplate.minimumStanceChoices"
      :label="$t('poll_ranked_choice_form.minimum_stance_choices_helptext')"
      :hint="$t('poll_ranked_choice_form.minimum_stance_choices_hint')"
      type="number"
      :min="1")
    validation-errors(:subject="pollTemplate", field="minimumStanceChoices")

  template(v-if="pollTemplate.pollType == 'dot_vote'")
    v-text-field(
      :label="$t('poll_dot_vote_form.dots_per_person')"
      type="number"
      min="1"
      v-model="pollTemplate.dotsPerPerson")
    validation-errors(:subject="pollTemplate" field="dotsPerPerson")
  v-divider.my-4

  v-text-field(
    :label="$t('poll_common_form.default_duration_in_days')"
    :hint="$t('poll_common_form.default_duration_in_days_hint')"
    type="number"
    min="1"
    v-model="pollTemplate.defaultDurationInDays")
  validation-errors(:subject="pollTemplate" field="defaultDurationInDays")

  v-radio-group(
    v-model="pollTemplate.specifiedVotersOnly"
    :label="$t('poll_common_settings.who_can_vote')"
  )
    v-radio(
      :value="false"
      :label="$t('poll_common_settings.specified_voters_only_false_group')")
    v-radio.poll-common-settings__specified-voters-only(
      :value="true"
      :label="$t('poll_common_settings.specified_voters_only_true')")

  template(v-if="allowAnonymous")
    //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_form.anonymous_voting'")
    //- p.text--secondary(v-t="'poll_common_form.anonymous_voting_description'")
    v-checkbox.poll-common-checkbox-option.poll-settings-anonymous(
      v-model="pollTemplate.anonymous"
      :label="$t('poll_common_form.votes_are_anonymous')")


  template(v-if="pollTemplate.config().can_shuffle_options")
    //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_settings.shuffle_options.shuffle_options'")
    //- p.text--secondary(v-t="'poll_common_settings.shuffle_options.helptext'")
    v-checkbox.poll-common-checkbox-option.poll-settings-shuffle-options.mt-4.pt-2(
      v-model="pollTemplate.shuffleOptions"
      :label="$t('poll_common_settings.shuffle_options.title')")

  //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_form.vote_reason'")
  //- p.text--secondary(v-t="'poll_common_form.vote_reason_description'")
  v-select(
    :label="$t('poll_common_form.stance_reason_required_label')"
    :items="stanceReasonRequiredItems"
    v-model="pollTemplate.stanceReasonRequired"
  )

  v-text-field(
    v-if="pollTemplate.stanceReasonRequired != 'disabled' && (!pollTemplate.config().per_option_reason_prompt)"
    v-model="pollTemplate.reasonPrompt"
    :label="$t('poll_common_form.reason_prompt')"
    :hint="$t('poll_option_form.prompt_hint')"
    :placeholder="$t('poll_common.reason_placeholder')")

  template(v-if="pollTemplate.stanceReasonRequired != 'disabled'")
    //- p.text--secondary(v-t="'poll_common_settings.short_reason_can_be_helpful'")
    v-checkbox.poll-common-checkbox-option(
      v-model="pollTemplate.limitReasonLength"
      :label="$t('poll_common_form.limit_reason_length')"
    )

  template(v-if="allowAnonymous")
    //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_card.hide_results'")
    //- p.text--secondary(v-t="'poll_common_form.hide_results_description'")
    v-select.poll-common-settings__hide-results.mt-6.pt-2(
      :label="$t('poll_common_card.hide_results')"
      :items="hideResultsItems"
      v-model="pollTemplate.hideResults"
    )

  .d-flex.justify-space-between.my-4.mt-4.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit()'
      :loading="pollTemplate.processing"
      :disabled="!pollTemplate.processName || !pollTemplate.processSubtitle"
    )
      span(v-t="'common.action.save'")

</template>
