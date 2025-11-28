<script lang="js">
import AppConfig from '@/shared/services/app_config';
import { mapKeys, snakeCase, compact, without, some, pick } from 'lodash-es';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { I18n } from '@/i18n';
import UrlFor from '@/mixins/url_for';
import WatchRecords from '@/mixins/watch_records';
import { HandleDirective } from 'vue-slicksort';

export default {
  mixins: [WatchRecords, UrlFor],
  directives: { handle: HandleDirective },

  props: {
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
        { title: this.$t('poll_common_card.do_not_hide_results'), value: 'off' },
        { title: this.$t('poll_common_card.until_you_vote'), value: 'until_vote' },
        { title: this.$t('poll_common_card.until_voting_is_closed'), value: 'until_closed' }
      ]
    };
  },

  methods: {
    validate(field) {
      return [ () => this.pollTemplate.errors[field] === undefined || this.pollTemplate.errors[field][0] ]
    },
    discardDraft() {
      if (confirm(I18n.global.t('formatting.confirm_discard'))) {
        EventBus.$emit('resetDraft', 'pollTemplate', this.pollTemplate.id, 'details', this.pollTemplate.details);
        EventBus.$emit('resetDraft', 'pollTemplate', this.pollTemplate.id, 'processIntroduction', this.pollTemplate.processIntroduction);
      }
    },
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
        icon: null,
        testOperator: null,
        testPercent: null,
        testAgainst: null
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
      const clone = pick(option, 'name', 'icon', 'meaning', 'prompt', 'testOperator', 'testPercent', 'testAgainst');

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
      this.pollTemplate.setErrors({});
      this.setPollOptionPriority();
      this.pollTemplate.pollOptions = this.pollOptions.map((o) => mapKeys(o, (_, k) => snakeCase(k)))
      this.pollTemplate.save().then(() => {
        Flash.success("poll_common.poll_template_saved");
        this.$router.push(this.$route.query.return_to);
      }).catch(error => {
        this.$refs.form.validate();
        Flash.error('common.check_for_errors_and_try_again');
      });
    }
  },

  computed: {
    hasOptions() { return this.pollTemplate.config().has_options; },
    breadcrumbs() {
      return compact([this.pollTemplate.group().parentId && this.pollTemplate.group().parent(), this.pollTemplate.group()]).map(g => {
        return {
          title: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    },

    votingMethodsItems() {
      return without(Object.keys(this.votingMethodsI18n), 'count').map(key => {
        return {title: this.$t(this.votingMethodsI18n[key].title), value: key};
      });
    },

    knownOptions() {
      return (AppConfig.pollTypes[this.pollTemplate.pollType].common_poll_options || []);
    },

    allowAnonymous() { return !this.pollTemplate.config().prevent_anonymous; },
    stanceReasonRequiredItems() {
      return [
        {title: this.$t('poll_common_form.stance_reason_required'), value: 'required'},
        {title: this.$t('poll_common_form.stance_reason_optional'), value: 'optional'},
        {title: this.$t('poll_common_form.stance_reason_disabled'), value: 'disabled'}
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
        return {title: this.$t(`poll_common_settings.notify_on_closing_soon.${name}`), value: name};
      });
    },

    optionFormat() { return this.pollTemplate.pollOptionNameFormat; },
    hasOptionIcon() { return this.pollTemplate.config().has_option_icon; },
    i18nItems() {
      return compact('agree abstain disagree consent objection block yes no'.split(' ').map(name => {
        if (this.pollTemplate.pollOptionNames.includes(name)) { return null; }
        return {
          title: this.$t('poll_proposal_options.'+name),
          value: name
        };
      }));
    }
  }
};

</script>
<template lang="pug">
v-form.poll-template-form(ref="form" @submit.prevent="submit")
  .d-flex
    v-breadcrumbs.px-0.py-0(:items="breadcrumbs")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    v-spacer
    v-btn.back-button(v-if="$route.query.return_to" icon variant="text" :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
      common-icon(name="mdi-close")
  v-card-title.px-0
    h1.text-h4(tabindex="-1" v-t="titlePath")

  v-alert.poll-template-info-panel.mb-2(type="info" variant="tonal")
    span
      span(v-t="'poll_common.need_help_with_templates'")
      space
      help-link(path="user_manual/polls/poll_templates")

  v-select(
    :label="$t('poll_common_form.voting_method')"
    v-model="pollTemplate.pollType"
    :items="votingMethodsItems"
    :hint="$t(votingMethodsI18n[pollTemplate.pollType].hint)"
  )

  v-text-field(
     v-model="pollTemplate.processName"
    :label="$t('poll_common_form.process_name')"
    :hint="$t('poll_common_form.process_name_hint')"
    :rules="validate('processName')"
  )

  v-text-field(
     v-model="pollTemplate.processSubtitle"
    :label="$t('poll_common_form.process_subtitle')"
    :hint="$t('poll_common_form.process_subtitle_hint')"
    :rules="validate('processSubtitle')"
  )

  lmo-textarea(
    :model='pollTemplate'
    field="processIntroduction"
    :placeholder="$t('poll_common_form.process_introduction_hint')"
    :label="$t('poll_common_form.process_introduction')"
  )

  v-text-field.thread-template-form-fields__title(
    :label="$t('discussion_template.default_title_label')"
    :hint="$t('discussion_template.default_title_hint')"
    v-model='pollTemplate.title'
    maxlength='250')
  validation-errors(:subject='pollTemplate' field='title')

  v-text-field.poll-common-form-fields__title-placeholder(
    :hint="$t('discussion_template.title_placeholder_hint')"
    :label="$t('discussion_template.title_placeholder_label')"
    :placeholder="$t('discussion_template.title_placeholder_placeholder')"
    v-model='pollTemplate.titlePlaceholder'
    maxlength='250'
    :rules="validate('titlePlaceholder')"
  )

  tags-field(:model="pollTemplate")

  lmo-textarea(
    :model='pollTemplate'
    field="details"
    :placeholder="$t('poll_common_form.example_details_placeholder')"
    :label="$t('poll_common_form.details')"
  )

  template(v-if="hasOptions")
    v-divider.my-4
    .text-subtitle-1.py-2(v-t="'poll_common_form.options'")
    v-alert(v-if="!pollOptions.length" variant="tonal" type="info")
      span(v-t="'poll_common_form.no_options_add_some'")
    sortable-list(
      v-model:list="pollOptions"
      append-to=".app-is-booted"
      use-drag-handle
      lock-axis="y"
      v-if="pollOptions.length"
    )
      sortable-item(
        v-for="(option, priority) in pollOptions"
        :index="priority"
        :key="option.name"
      )
        v-list-item.mb-2(lines="two" rounded variant="tonal" style="user-select: none")
          template(v-slot:prepend v-if="hasOptionIcon" v-handle)
            v-avatar(size="48")
              img(:src="'/img/' + option.icon + '.svg'" aria-hidden="true")

          v-list-item-title(v-handle)
            span(v-if="optionFormat == 'i18n'" v-t="'poll_proposal_options.'+option.name")
            span(v-if="optionFormat == 'plain'") {{option.name}}
            span(v-if="optionFormat == 'iso8601'")
              poll-meeting-time(:name="option.name")
          v-list-item-subtitle.poll-common-vote-form__allow-wrap
            p.font-italic.mb-1(v-t="{path: `poll_option_form.${option.testOperator}_${option.testAgainst}`, args: {percent: option.testPercent} }" v-if="option.testOperator")
            p {{option.meaning}}

          template(v-slot:append)
            v-btn(
              icon
              variant="text"
              @click="removeOption(option)"
              :title="$t('common.action.delete')"
            )
              common-icon(name="mdi-delete")
            div.ml-0(v-if="pollTemplate.pollType != 'meeting'")
              v-btn(icon variant="text" @click="editOption(option)" :title="$t('common.action.edit')")
                common-icon(name="mdi-pencil")
            common-icon(name="mdi-drag-vertical" style="cursor: grab" v-handle :title="$t('common.action.move')" v-if="pollTemplate.pollType != 'meeting'")

    .d-flex.justify-center
      v-btn.poll-template-form__add-option-btn.my-2(color="primary" variant="tonal" @click="addOption")
        span(v-t="'poll_common_add_option.modal.title'")

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
      v-divider.my-4
      .text-subtitle-1.pb-4(v-t="'poll_common_form.how_many_options_can_a_voter_choose'")
      .d-flex
        v-text-field.poll-common-form__minimum-stance-choices.mr-2(
          v-model="pollTemplate.minimumStanceChoices"
          type="number"
          :step="1"
          :hint="$t('poll_common_form.choose_at_least')"
          :label="$t('poll_common_form.minimum_choices')")
        v-text-field.poll-common-form__maximum-stance-choices.ml-2(
          v-model="pollTemplate.maximumStanceChoices"
          type="number"
          :step="1"
          :hint="$t('poll_common_form.choose_at_most')"
          :label="$t('poll_common_form.maximum_choices')")

    .d-flex.align-center(v-if="pollTemplate.pollType == 'ranked_choice'")
      v-divider.my-4
      v-text-field.lmo-number-input(
        v-model="pollTemplate.minimumStanceChoices"
        :label="$t('poll_ranked_choice_form.minimum_stance_choices_helptext')"
        :hint="$t('poll_ranked_choice_form.minimum_stance_choices_hint')"
        type="number"
        :min="1"
        :rules="validate('minimumStanceChoices')"
      )

    template(v-if="pollTemplate.pollType == 'dot_vote'")
      v-divider.my-4
      p.mt-4.text-subtitle-1.mb-4(v-t="'poll_common_form.how_many_points_does_each_voter_have_to_allocate'")
      v-text-field(
        :label="$t('poll_dot_vote_form.dots_per_person')"
        type="number"
        min="1"
        v-model="pollTemplate.dotsPerPerson"
        :rules="validate('dotsPerPerson')"
      )

  template(v-if="pollTemplate.config().allow_none_of_the_above")
    v-checkbox.poll-settings-allow-none-of-the-above(
      hide-details
      v-model="pollTemplate.showNoneOfTheAbove"
      :label="$t('poll_common_settings.show_none_of_the_above')"
    )

  v-divider.my-4

  .text-subtitle-1.pb-2(v-t="'poll_common_form.deadline'")
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.default_duration_in_days_hint'")
  v-text-field(
    :label="$t('poll_common_form.default_duration_in_days')"
    type="number"
    min="1"
    v-model="pollTemplate.defaultDurationInDays"
    :rules="validate('defaultDurationInDays')"
  )

  v-divider.my-4
  .text-subtitle-1.pb-2(v-t="'poll_common_settings.who_can_vote'")
  v-radio-group(
    v-model="pollTemplate.specifiedVotersOnly"
  )
    v-radio(
      :value="false"
      :label="$t('poll_common_settings.specified_voters_only_false_group')")
    v-radio.poll-common-settings__specified-voters-only(
      :value="true"
      :label="$t('poll_common_settings.specified_voters_only_true')")

  v-divider.mb-4
  .text-subtitle-1.pb-2(v-t="'poll_common_form.reminder_notification'")
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.reminder_helptext'")
  v-select(
    :label="$t('poll_common_settings.notify_on_closing_soon.voting_title')"
    v-model="pollTemplate.notifyOnClosingSoon"
    :items="closingSoonItems")

  template(v-if="allowAnonymous")
    v-divider.mb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_form.anonymous_voting'")
    .text-body-2.text-medium-emphasis(v-t="{path: 'poll_common_form.anonymous_voting_description', args: {poll_type: pollTemplate.translatedPollType()}}")
    v-checkbox.poll-settings-anonymous(
      hide-details
      v-model="pollTemplate.anonymous"
      :label="$t('poll_common_form.votes_are_anonymous')")

    v-divider.mb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_card.hide_results'")
    .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.hide_results_description'")
    v-select.poll-common-settings__hide-results(
      :label="$t('poll_common_card.hide_results')"
      :items="hideResultsItems"
      v-model="pollTemplate.hideResults"
    )

  template(v-if="pollTemplate.config().can_shuffle_options")
    v-divider.pb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_settings.shuffle_options'")
    .text-body-2.text-medium-emphasis(v-t="'poll_common_settings.reduce_bias_by_showing_options_in_random_order'")
    v-checkbox.poll-settings-shuffle-options(
      hide-details
      v-model="pollTemplate.shuffleOptions"
      :label="$t('poll_common_settings.show_options_in_random_order')")

  v-divider.pb-4
  .text-subtitle-1.pb-2(v-t="'poll_common_form.vote_reason'")
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.vote_reason_description'")
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

  v-checkbox(
    v-if="pollTemplate.stanceReasonRequired != 'disabled'"
    v-model="pollTemplate.limitReasonLength"
    :label="$t('poll_common_form.limit_reason_length')"
  )

  template(v-if="pollTemplate.config().allow_quorum")
    v-divider.mb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_form.quorum'")
    .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.quorum_hint'")
    v-number-input.mb-4(
      v-model="pollTemplate.quorumPct"
      :label="$t('poll_common_form.participation_quorum')"
      :placeholder="$t('poll_common_form.quorum_placeholder')"
      :min="0"
      :max="100"
      autocomplete="off"
      control-variant="hidden"
    )
      template(v-slot:append-inner)
        span.mr-4 %
    .text-body-2.mt-n4.pb-4.font-italic.text-medium-emphasis(
      v-if="pollTemplate.quorumPct && pollTemplate.config().allow_vote_share_requirement"
      v-t="'poll_common_form.quorum_tip_vote_share_requirement'"
    )

  v-divider.mb-4
  .text-subtitle-1.pb-2(v-t="'poll_common_outcome_form.outcome_statement_template'")
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_outcome_form.statement_template_hint'")
  lmo-textarea(
    :model='pollTemplate'
    field="outcomeStatement"
    :placeholder="$t('poll_common_outcome_form.statement_template_placeholder')"
  )

  v-divider.mb-4
  .text-subtitle-1.pb-2 Decision review
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_outcome_form.review_due_in_days_hint'")
  v-text-field(
    :label="$t('poll_common_outcome_form.review_due_in_days')"
    type="number"
    min="1"
    v-model="pollTemplate.outcomeReviewDueInDays"
    :rules="validate('outcomeReviewDueInDays')"
  )

  .d-flex.justify-space-between.my-4.mt-4.poll-common-form-actions
    help-btn(path='en/user_manual/polls/poll_templates')
    v-spacer
    v-btn.mr-2(
      @click="discardDraft"
      v-t="'common.reset'"
      :title="$t('common.discard_changes_to_this_text')"
    )
    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit()'
      :loading="pollTemplate.processing"
    )
      span(v-t="'common.action.save'")

</template>
