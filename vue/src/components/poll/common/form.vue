<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import { compact, without, some, pick } from 'lodash-es';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { addMinutes, intervalToDuration, formatDuration, addHours, isAfter, startOfHour, setHours } from 'date-fns';
import PollTemplateInfoPanel  from '@/components/poll_template/info_panel';
import { HandleDirective } from 'vue-slicksort';
import I18n from '@/i18n';

export default {
  components: { PollTemplateInfoPanel },
  directives: { handle: HandleDirective },

  props: {
    poll: Object,
    shouldReset: Boolean,
    redirectOnSave: Boolean
  },

  mounted() {
    Records.users.findOrFetchGroups();

    Records.pollTemplates.findOrFetchByKeyOrId(this.poll.pollTemplateKeyOrId()).then(template => {
      this.pollTemplate = template;
    });

    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: () => {
        return this.groupItems = [
          {text: this.$t('discussion_form.none_invite_only_thread'), value: null}
        ].concat(Session.user().groups().filter( g => AbilityService.canStartPoll(g)).map(g => ({
          text: g.fullName,
          value: g.id
        })));
    }});
  },

  data() {
    return {
      newOption: null,
      lastPollType: this.poll.pollType,
      pollOptions: this.poll.pollOptionsAttributes || this.poll.clonePollOptions(),
      groupItems: [],
      showAdvanced: false,
      pollTemplate: null,

      votingMethodsI18n: {
        proposal: { 
          title: 'poll_common_form.voting_methods.show_thumbs',
          hint: 'poll_common_form.voting_methods.show_thumbs_hint'
        },
        poll: { 
          title: 'poll_common_form.voting_methods.simple_poll',
          hint: 'poll_common_form.voting_methods.choose_hint'
        },
        // meeting:
        //   title: 'poll_common_form.voting_methods.time_poll'
        //   hint: 'poll_common_form.voting_methods.time_poll_hint'
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

      chartTypeItems: [
        {text: 'bar', value: 'bar'},
        {text: 'pie', value: 'pie'},
        {text: 'grid', value: 'grid'}
      ],

      currentHideResults: this.poll.hideResults,
      hideResultsItems: [
        { text: this.$t('common.off'), value: 'off' },
        { text: this.$t('poll_common_card.until_you_vote'), value: 'until_vote' },
        { text: this.$t('poll_common_card.until_voting_is_closed'), value: 'until_closed' }
      ],
      newDateOption: startOfHour(setHours(new Date(), 12)),
      minDate: new Date(),
      closingAtWas: null
    };
  },

  methods: {
    optionHasVotes(option) {
      return (this.poll.results.find(o => o.id === option.id) || {voter_count: 0}).voter_count > 0;
    },

    setPollOptionPriority() {
      let i = 0;
      this.pollOptions.forEach(o => o.priority = 0);
      this.visiblePollOptions.forEach(o => o.priority = i++);
    },

    removeOption(option) {
      if (this.optionHasVotes(option)) {
        if (!confirm(I18n.t("poll_common_form.option_has_votes_confirm_delete"))) { return; }
      }

      this.newOption = null;
      if (option.id) {
        option.name = '';
        option.meaning = '';
        option['_destroy'] = 1;
      } else {
        this.pollOptions = without(this.pollOptions, option);
      }
    },

    addDateOption() {
      const optionName = this.newDateOption.toJSON();
      if (some(this.pollOptions, o => o.name === optionName)) {
        Flash.error('poll_poll_form.option_already_added');
      } else {
        this.pollOptions.push({name: optionName});
      }
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
          poll: this.poll,
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
          poll: this.poll,
          submitFn: clone => {
            Object.assign(option, clone);
          }
        }
      }
      );
    },

    submit() {
      const actionName = this.poll.isNew() ? 'created' : 'updated';
      this.poll.setErrors({});
      this.setPollOptionPriority();
      this.poll.pollOptionsAttributes = this.pollOptions;
      this.poll.save().then(data => {
        const poll = Records.polls.find(data.polls[0].id);
        if (this.redirectOnSave) { this.$router.replace(this.urlFor(poll)); }
        this.$emit('saveSuccess', poll);

        if (actionName == 'created') {
          Flash.success("poll_common_form.poll_type_started", {poll_type: poll.translatedPollTypeCaps()});
        } else {
          Flash.success("poll_common_form.poll_type_updated", {poll_type: poll.translatedPollTypeCaps()});
        }

        if ((actionName == 'created') && poll.specifiedVotersOnly) {
          EventBus.$emit('openModal', {
            component: 'PollMembers',
            props: {
              poll
            }
          });
        }
      }).catch(error => {
        Flash.warning('poll_common_form.please_review_the_form');
        console.error(error);
      });
    }
  },

  computed: {
    titlePlaceholder() {
      if (this.pollTemplate && this.pollTemplate.titlePlaceholder) {
        return I18n.t('common.prefix_eg', {val: this.pollTemplate.titlePlaceholder});
      } else {
        return I18n.t('poll_proposal_form.title_placeholder');
      }
    },

    votingMethodsItems() {
      return Object.keys(this.votingMethodsI18n).map(key => {
        return {text: this.$t(this.votingMethodsI18n[key].title), value: key};
    });
    },

    knownOptions() {
      return (AppConfig.pollTypes[this.poll.pollType].common_poll_options || []);
    },

    formattedDuration() { 
      if (!this.poll.meetingDuration) { return ''; }
      const minutes = parseInt(this.poll.meetingDuration);
      const duration = intervalToDuration({ start: new Date, end: addMinutes(new Date, minutes) });
      return formatDuration(duration, { format: ['hours', 'minutes'] });
    },

    visiblePollOptions() { return this.pollOptions.filter(o => !o._destroy); },
  
    hasOptions() { return this.poll.config().has_options; },
    minOptions() { return this.poll.config().min_options; },
    allowAnonymous() { return !this.poll.config().prevent_anonymous; },
    stanceReasonRequiredItems() {
      return [
        {text: this.$t('poll_common_form.stance_reason_required'), value: 'required'},
        {text: this.$t('poll_common_form.stance_reason_optional'), value: 'optional'},
        {text: this.$t('poll_common_form.stance_reason_disabled'), value: 'disabled'}
      ];
    },

    titlePath() {
      return (this.poll.isNew() && 'action_dock.new_poll_type') || 'action_dock.edit_poll_type';
    },

    titleArgs() { 
      return {pollType: this.poll.translatedPollType().toLowerCase()};
    },

    closesSoon() {
      return !(this.poll.closingAt && isAfter(this.poll.closingAt, addHours(new Date(), 24)));
    },

    closingSoonItems() {
      return 'nobody author undecided_voters voters'.split(' ').map(name => {
        return {text: this.$t(`poll_common_settings.notify_on_closing_soon.${name}`), value: name};
    });
    },

    optionFormat() { return this.poll.pollOptionNameFormat; },
    hasOptionIcon() { return this.poll.config().has_option_icon; },
    i18nItems() { 
      return compact('agree abstain disagree consent objection block yes no'.split(' ').map(name => {
        if (this.poll.pollOptionNames.includes(name)) { return null; }
        return {
          text: this.$t('poll_proposal_options.'+name),
          value: name
        };
      })
      );
    }
  }
};
</script>
<template lang="pug">
.poll-common-form
  submit-overlay(:value="poll.processing")
  v-card-title.px-0
    h1.text-h4(tabindex="-1" v-t="{path: titlePath, args: titleArgs}")
    v-spacer

    v-btn(v-if="poll.id" icon :to="urlFor(poll)" aria-hidden='true')
      common-icon(name="mdi-close")
    v-btn(v-if="!poll.id" icon @click="$emit('setPoll', null)" aria-hidden='true')
      common-icon(name="mdi-close")

  poll-template-info-panel(v-if="pollTemplate" :poll-template="pollTemplate")

  v-select(
    v-if="!poll.id && !poll.discussionId"
    v-model="poll.groupId"
    :items="groupItems"
    :label="$t('common.group')"
  )

  v-text-field.poll-common-form-fields__title(
    type='text'
    required='true'
    :hint="$t('poll_common_form.title_hint')"
    :placeholder="titlePlaceholder"
    :label="$t('poll_common_form.title')"
    v-model='poll.title'
    maxlength='250')
  validation-errors(:subject='poll' field='title')

  tags-field(:model="poll")

  lmo-textarea.poll-common-form-fields__details(
    :model='poll'
    field="details"
    :placeholder="$t('poll_common_form.details_placeholder')"
    :label="$t('poll_common_form.details')"
    :should-reset="shouldReset"
  )

  template(v-if="hasOptions")
    .v-label.v-label--active.px-0.text-caption.py-2(v-t="'poll_common_form.options'")
    v-subheader.px-0(v-if="!pollOptions.length" v-t="'poll_common_form.no_options_add_some'")
    sortable-list(
      v-model="pollOptions" 
      append-to=".app-is-booted" 
      use-drag-handle 
      lock-axis="y"
      v-if="pollOptions.length"
    )
      sortable-item(
        v-for="(option, priority) in visiblePollOptions"
        :index="priority"
        :key="option.name"
        :item="option"
        v-if="!option._destroy"
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
              v-list-item-subtitle.poll-common-vote-form__allow-wrap {{option.meaning}}

            v-list-item-action
              v-btn(
                icon
                @click="removeOption(option)"
                :title="$t('common.action.delete')"
              )
                common-icon.text--secondary(name="mdi-delete")
            v-list-item-action.ml-0(v-if="poll.pollType != 'meeting'")
              v-btn(icon @click="editOption(option)", :title="$t('common.action.edit')")
                common-icon.text--secondary(name="mdi-pencil")
            common-icon.text--secondary(name="mdi-drag-vertical" style="cursor: grab" v-handle :title="$t('common.action.move')" v-if="poll.pollType != 'meeting'") 

    template(v-if="optionFormat == 'i18n'")
      p This poll cannot have new options added. (contact support if you see this message)

    template(v-if="optionFormat == 'plain'")
      .d-flex.justify-center
        v-btn.poll-common-form__add-option-btn.my-2(@click="addOption" v-t="'poll_common_add_option.modal.title'")

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
      poll-meeting-add-option-menu(:poll="poll" :value="newDateOption")

  template(v-if="optionFormat == 'iso8601'")
    .d-flex.align-center
      v-text-field.text-right(
        style="max-width: 120px; text-align: right"
        :label="$t('poll_meeting_form.meeting_duration')"
        v-model="poll.meetingDuration"
        type="number"
      )
      span.pl-2.text--secondary(v-t="'common.minutes'")
      span.pl-1.text--secondary(v-if="formattedDuration") ({{formattedDuration}})

  template(v-if="poll.pollType == 'count'")
    p.text--secondary(v-t="'poll_count_form.agree_target_helptext'")
    .d-flex
      v-text-field.poll-common-form__agree-target(
        v-model="poll.agreeTarget"
        type="number"
        :step="1"
        :label="$t('poll_count_form.agree_target_label')"
      )

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

  template(v-if="poll.pollType == 'poll'")
    p.text--secondary(v-t="'poll_common_form.how_many_options_can_a_voter_choose'")
    .d-flex
      v-text-field.poll-common-form__minimum-stance-choices(
        v-model="poll.minimumStanceChoices"
        type="number"
        :step="1"
        :hint="$t('poll_common_form.choose_at_least')"
        :label="$t('poll_common_form.minimum_choices')")
      v-spacer
      v-text-field.poll-common-form__maximum-stance-choices(
        v-model="poll.maximumStanceChoices"
        type="number"
        :step="1"
        :hint="$t('poll_common_form.choose_at_most')"
        :label="$t('poll_common_form.maximum_choices')")

  .d-flex.align-center(v-if="poll.pollType == 'ranked_choice'")
    v-text-field.lmo-number-input(
      v-model="poll.minimumStanceChoices"
      :label="$t('poll_ranked_choice_form.minimum_stance_choices_helptext')"
      :hint="$t('poll_ranked_choice_form.minimum_stance_choices_hint')"
      type="number"
      :min="1"
      :max="poll.pollOptionNames.length")
    validation-errors(:subject="poll", field="minimumStanceChoices")

  template(v-if="poll.pollType == 'dot_vote'")
    v-text-field(:label="$t('poll_dot_vote_form.dots_per_person')" type="number", min="1", v-model="poll.dotsPerPerson")
    validation-errors(:subject="poll" field="dotsPerPerson")

  v-divider.my-4

  poll-common-closing-at-field(:poll="poll")
  //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_form.reminder'")
  //- p.text--secondary(v-t="'poll_common_form.reminder_helptext'")
  p(v-if="poll.closingAt && closesSoon" 
    v-t="{path: 'poll_common_settings.notify_on_closing_soon.voting_closes_too_soon', args: {pollType: poll.translatedPollType()}}")

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
  .text-caption.mt-n4.text--secondary.text-caption(
    v-if="poll.specifiedVotersOnly"
    v-t="$t('poll_common_settings.invite_people_next', {poll_type: poll.translatedPollType()})")

  v-checkbox.mt-0(v-if="!poll.id && !poll.specifiedVotersOnly" :label="$t('poll_common_form.notify_everyone_when_poll_starts', {poll_type: poll.translatedPollType()})" v-model="poll.notifyRecipients")

  .d-flex.justify-center
    v-btn.my-4.poll-common-form__advanced-btn(@click="showAdvanced = !showAdvanced")
      span(v-if='showAdvanced' v-t="'poll_common_form.hide_advanced_settings'")
      span(v-else v-t="'poll_common_form.show_advanced_settings'")

  div(v-show="showAdvanced")
    v-select(
      :disabled="!poll.closingAt"
      :label="$t('poll_common_settings.notify_on_closing_soon.voting_title')"
      v-model="poll.notifyOnClosingSoon"
      :items="closingSoonItems")

    template(v-if="allowAnonymous")
      //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_form.anonymous_voting'")
      //- p.text--secondary(v-t="'poll_common_form.anonymous_voting_description'")
      v-checkbox.poll-common-checkbox-option.poll-settings-anonymous(
        :disabled="!poll.isNew()"
        v-model="poll.anonymous"
        :label="$t('poll_common_form.votes_are_anonymous')")


    template(v-if="poll.config().can_shuffle_options")
      //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_settings.shuffle_options.shuffle_options'")
      //- p.text--secondary(v-t="'poll_common_settings.shuffle_options.helptext'")
      v-checkbox.poll-common-checkbox-option.poll-settings-shuffle-options.mt-4.pt-2(
        v-model="poll.shuffleOptions"
        :label="$t('poll_common_settings.shuffle_options.title')")

    //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_form.vote_reason'")
    //- p.text--secondary(v-t="'poll_common_form.vote_reason_description'")
    template(v-if="!poll.config().hide_reason_required")
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

    template(v-if="poll.stanceReasonRequired != 'disabled'")
      //- p.text--secondary(v-t="'poll_common_settings.short_reason_can_be_helpful'")
      v-checkbox.poll-common-checkbox-option(
        v-model="poll.limitReasonLength"
        :label="$t('poll_common_form.limit_reason_length')"
      )

    template(v-if="allowAnonymous")
      //- .lmo-form-label.mb-1.mt-4(v-t="'poll_common_card.hide_results'")
      //- p.text--secondary(v-t="'poll_common_form.hide_results_description'")
      v-select.poll-common-settings__hide-results.mt-6.pt-2(
        :label="$t('poll_common_card.hide_results')"
        :items="hideResultsItems"
        v-model="poll.hideResults"
        :disabled="!poll.isNew() && currentHideResults == 'until_closed'"
      )

  common-notify-fields(v-if="poll.id" :model="poll" includeActor)

  v-card-actions.poll-common-form-actions
    help-link(path='en/user_manual/polls/intro_to_decisions')
    v-spacer
    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit()'
      :loading="poll.processing"
      :disabled="!poll.title || (hasOptions && pollOptions.length < minOptions)"
    )
      span(v-if='poll.id' v-t="'common.action.save_changes'")
      span(v-if='!poll.id && poll.closingAt' v-t="{path: 'poll_common_form.start_poll_type', args: {poll_type: poll.translatedPollType()}}")
      span(v-if='!poll.id && !poll.closingAt' v-t="'poll_common_form.save_poll'")

</template>
<style>
.lmo-form-label {
  font-size: 14px;
}
.theme--dark .lmo-form-label{
}
.theme--light .lmo-form-label{
  color: rgba(0, 0, 0, 0.6);
}
</style>
