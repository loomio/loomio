<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import { compact, without, some, pick } from 'lodash';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { addDays, addMinutes, intervalToDuration, formatDuration } from 'date-fns';
import { HandleDirective } from 'vue-slicksort';
import { isSameYear, startOfHour, setHours }  from 'date-fns';

export default {
  directives: { handle: HandleDirective },

  props: {
    isModal: {
      default: false,
      type: Boolean
    },
    pollTemplate: Object
  },

  data() {
    return {
      newOption: null,
      lastPollType: this.pollTemplate.pollType,
      pollOptions: this.pollTemplate.pollOptionsAttributes(),

      votingMethodsI18n: {
        count: {
          title: 'poll_common_form.voting_methods.show_thumbsdecision_tools_card.proposal_title',
          hint: 'poll_common_form.voting_methods.show_thumbs_hint'
        },
        question: { 
          title: 'poll_common_form.voting_methods.question',
          hint: 'poll_common_form.voting_methods.question_hint'
        },
        proposal: { 
          title: 'decision_tools_card.proposal_title',
          hint: 'poll_common_form.voting_methods.show_thumbs_hint'
        },
        poll: { 
          title: 'poll_common_form.voting_methods.simple_poll',
          hint: 'poll_common_form.voting_methods.choose_hint'
        },
        meeting: {
          title: 'poll_common_form.voting_methods.time_poll',
          hint: 'poll_common_form.voting_methods.time_poll_hint'
        },
        dot_vote: {
          title: 'decision_tools_card.dot_vote_title',
          hint: 'poll_common_form.voting_methods.allocate_hint'
        },
        score: { 
          title: 'poll_common_form.voting_methods.score',
          hint: 'poll_common_form.voting_methods.score_hint'
        },
        ranked_choice: {
          title: 'poll_common_form.voting_methods.ranked_choice',
          hint: 'poll_common_form.voting_methods.ranked_choice_hint'
        }
      },

      currentHideResults: this.pollTemplate.hideResults,
      hideResultsItems: [
        { text: this.$t('common.off'), value: 'off' },
        { text: this.$t('poll_common_card.until_you_vote'), value: 'until_vote' },
        { text: this.$t('poll_common_card.until_voting_is_closed'), value: 'until_closed' }
      ]
    };
  },

  methods: {
    setPollOptionPriority() {
      let i = 0;
      this.pollOptions.forEach(o => o.priority = i++);
    },

    removeOption(option) {
      this.newOption = null;
      this.pollOptions = without(this.pollOptions, option);
    },

    addOption() {
      const option = { 
        name: '',
        meaning: '',
        prompt: '',
        icon: 'agree'
      };

      EventBus.$emit('openModal', {
        component: 'PollOptionForm',
        props: {
          pollOption: option,
          poll: this.pollTemplate,
          submitFn: option => {
            if (some(this.pollOptions, o => o.name.toLowerCase() === option.name.toLowerCase())) {
              Flash.error('poll_poll_form.option_already_added');
            } else {
              this.pollOptions.push(option);
            }
          }
        }
      }
      );
    },

    editOption(option) {
      const clone = pick(option, 'name', 'icon', 'meaning', 'prompt');

      EventBus.$emit('openModal', {
        component: 'PollOptionForm',
        props: {
          edit: true,
          pollOption: clone,
          poll: this.pollTemplate,
          submitFn: clone => {
            return Object.assign(option, clone);
          }
        }
      }
      );
    },

    submit() {
      const actionName = this.pollTemplate.isNew() ? 'created' : 'updated';
      this.pollTemplate.setErrors({});
      this.setPollOptionPriority();
      this.pollTemplate.pollOptions = this.pollOptions;
      this.pollTemplate.save().then(data => {
        Flash.success("poll_common.poll_template_saved");
        if (this.isModal) {
          EventBus.$emit('closeModal');
        } else {
          this.$router.push(this.$route.query.return_to);
        }
      }).catch(error => {
        Flash.warning('poll_common_form.please_review_the_form');
        console.error(error);
      });
    }
  },

  computed: {
    hasOptions() { return this.pollTemplate.config().has_options; },
    breadcrumbs() {
      return compact([this.pollTemplate.group().parentId && this.pollTemplate.group().parent(), this.pollTemplate.group()]).map(g => {
        return {
          text: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    },

    votingMethodsItems() {
      return without(Object.keys(this.votingMethodsI18n), 'count').map(key => {
        return {text: this.$t(this.votingMethodsI18n[key].title), value: key};
      });
    },

    knownOptions() {
      return (AppConfig.pollTypes[this.pollTemplate.pollType].common_poll_options || []);
    },

    allowAnonymous() { return !this.pollTemplate.config().prevent_anonymous; },
    stanceReasonRequiredItems() {
      return [
        {text: this.$t('poll_common_form.stance_reason_required'), value: 'required'},
        {text: this.$t('poll_common_form.stance_reason_optional'), value: 'optional'},
        {text: this.$t('poll_common_form.stance_reason_disabled'), value: 'disabled'}
      ];
    },

    titlePath() {
      if (this.pollTemplate.pollType === 'proposal') {
        return (this.pollTemplate.isNew() && 'poll_common.new_proposal_template') || 'poll_common.edit_proposal_template';
      } else {
        return (this.pollTemplate.isNew() && 'poll_common.new_poll_template') || 'poll_common.edit_poll_template';
      }
    },

    closingSoonItems() {
      return 'nobody author undecided_voters voters'.split(' ').map(name => {
        return {text: this.$t(`poll_common_settings.notify_on_closing_soon.${name}`), value: name};
      });
    },

    optionFormat() { return this.pollTemplate.pollOptionNameFormat; },
    hasOptionIcon() { return this.pollTemplate.config().has_option_icon; },
    i18nItems() { 
      return compact('agree abstain disagree consent objection block yes no'.split(' ').map(name => {
        if (this.pollTemplate.pollOptionNames.includes(name)) { return null; }
        return {
          text: this.$t('poll_proposal_options.'+name),
          value: name
        };
      }));
    }
  }
};

</script>
<template lang="pug">
.poll-template-form(:class="isModal ? 'pa-4' : ''") 
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

  v-alert.poll-template-info-panel(type="info" text outlined)
    span 
      span(v-t="'poll_common.need_help_with_templates'")
      space
      a.text-decoration-underline(target="_blank" href="https://help.loomio.com/en/user_manual/polls/poll_templates/index.html")
        span(v-t="'common.visit_loomio_help'")

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

  v-text-field.thread-template-form-fields__title(
    :label="$t('thread_template.default_title_label')"
    :hint="$t('thread_template.default_title_hint')"
    v-model='pollTemplate.title'
    maxlength='250')
  validation-errors(:subject='pollTemplate' field='title')

  v-text-field.poll-common-form-fields__title-placeholder(
    :hint="$t('thread_template.title_placeholder_hint')"
    :label="$t('thread_template.title_placeholder_label')"
    :placeholder="$t('thread_template.title_placeholder_placeholder')"
    v-model='pollTemplate.titlePlaceholder'
    maxlength='250')
  validation-errors(:subject='pollTemplate' field='titlePlaceholder')

  tags-field(:model="pollTemplate")

  lmo-textarea(
    :model='pollTemplate'
    field="details"
    :placeholder="$t('poll_common_form.example_details_placeholder')"
    :label="$t('poll_common_form.details')"
  )
  
  template(v-if="hasOptions")
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

    .d-flex.justify-center
      v-btn.poll-template-form__add-option-btn.my-2(@click="addOption" v-t="'poll_common_add_option.modal.title'")

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

  lmo-textarea(
    :model='pollTemplate'
    field="outcomeStatement"
    :placeholder="$t('poll_common_outcome_form.statement_template_placeholder')"
    :label="$t('poll_common_outcome_form.outcome_statement_template')"
  )

  v-text-field(
    :label="$t('poll_common_outcome_form.review_due_in_days')"
    :hint="$t('poll_common_outcome_form.review_due_in_days_hint')"
    type="number"
    min="1"
    v-model="pollTemplate.outcomeReviewDueInDays")
  validation-errors(:subject="pollTemplate" field="outcomeReviewDueInDays")

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
