<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import { mapKeys, without, some, pick, snakeCase, pickBy, identity } from 'lodash-es';
import { I18n } from '@/i18n';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { addMinutes, intervalToDuration, formatDuration, addHours, isAfter, startOfHour, setHours } from 'date-fns';
import PollTemplateInfoPanel  from '@/components/poll_template/info_panel';
import { HandleDirective } from 'vue-slicksort';
import { useWatchRecords } from '@/composables/useWatchRecords';

const props = defineProps({
  poll: Object,
  redirectOnSave: Boolean
});

const emit = defineEmits(['setPoll', 'saveSuccess']);

const router = useRouter();
const route = useRoute();

// url_for mixin functionality
const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});
const mergeQuery = (obj) => ({query: pickBy(Object.assign({}, route.query, obj), identity)});

// watch_records composable
const { watchRecords } = useWatchRecords();

// Template refs
const form = ref(null);

// Data
const loading = ref(false);
const newOption = ref(null);
const lastPollType = ref(props.poll.pollType);
const pollOptions = ref(props.poll.pollOptionsAttributes || props.poll.clonePollOptions());
const groupItems = ref([]);
const showAdvanced = ref(false);
const pollTemplate = ref(null);
const currentHideResults = ref(props.poll.hideResults);
const hideResultsItems = ref([
  { title: I18n.global.t('poll_common_card.do_not_hide_results'), value: 'off' },
  { title: I18n.global.t('poll_common_card.until_you_vote'), value: 'until_vote' },
  { title: I18n.global.t('poll_common_card.until_voting_is_closed'), value: 'until_closed' }
]);
const newDateOption = ref(startOfHour(setHours(new Date(), 12)));
const minDate = ref(new Date());
const closingAtWas = ref(null);

// Methods
const validate = (field) => {
  return [ () => props.poll.errors[field] === undefined || props.poll.errors[field][0] ];
};

const discardDraft = () => {
  if (confirm(I18n.global.t('formatting.confirm_discard'))) {
    EventBus.$emit('resetDraft', 'poll', props.poll.id, 'details', props.poll.details);
  }
};

const optionHasVotes = (option) => {
  return (props.poll.results.find(o => o.id === option.id) || {voter_count: 0}).voter_count > 0;
};

const setPollOptionPriority = () => {
  let i = 0;
  pollOptions.value.forEach(o => o.priority = 0);
  visiblePollOptions.value.forEach(o => o.priority = i++);
};

const removeOption = (option) => {
  if (optionHasVotes(option)) {
    if (!confirm(I18n.global.t("poll_common_form.option_has_votes_confirm_delete"))) { return; }
  }

  newOption.value = null;
  if (option.id) {
    option.name = '';
    option.meaning = '';
    option['_destroy'] = 1;
  } else {
    pollOptions.value = without(pollOptions.value, option);
  }
};

const addDateOption = () => {
  setTimeout(() => {
    const optionName = newDateOption.value.toJSON();
    if (some(pollOptions.value, o => o.name === optionName)) {
      Flash.error('poll_poll_form.option_already_added');
    } else {
      pollOptions.value.push({name: optionName});
    }
  });
};

const addOption = () => {
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
      poll: props.poll,
      submitFn: option => {
        if (some(pollOptions.value, o => o.name.toLowerCase() === option.name.toLowerCase())) {
          Flash.error('poll_poll_form.option_already_added');
        } else {
          pollOptions.value.push(option);
        }
      }
    }
  });
};

const editOption = (option) => {
  const clone = pick(option, 'name', 'icon', 'meaning', 'prompt', 'testOperator', 'testPercent', 'testAgainst');

  EventBus.$emit('openModal', {
    component: 'PollOptionForm',
    props: {
      edit: true,
      pollOption: clone,
      poll: props.poll,
      submitFn: clone => {
        Object.assign(option, clone);
      }
    }
  });
};

const submit = () => {
  loading.value = true;
  const actionName = props.poll.isNew() ? 'created' : 'updated';
  props.poll.setErrors({});
  setPollOptionPriority();
  props.poll.pollOptionsAttributes = pollOptions.value.map((o) => mapKeys(o, (_, k) => k === '_destroy' ? k : snakeCase(k)))
  props.poll.save().then(data => {
    EventBus.$emit('deleteDraft', 'poll', props.poll.id, 'details');

    const poll = Records.polls.find(data.polls[0].id);
    if (props.redirectOnSave) { router.replace(urlFor(poll)); }
    emit('saveSuccess', poll);

    if (actionName == 'created') {
      Flash.success("poll_common_form.poll_type_started", {poll_type: poll.translatedPollTypeCaps()});
    } else {
      Flash.success("poll_common_form.poll_type_updated", {poll_type: poll.translatedPollTypeCaps()});
    }

    if ((actionName == 'created') && poll.specifiedVotersOnly) {
      EventBus.$emit('openModal', {
        component: 'PollMembers',
        props: { poll }
      });
    }
  }).catch(error => {
    form.value.validate();
    Flash.error('common.check_for_errors_and_try_again');
  }).finally(() => loading.value = false);
};

// Computed
const currentTimeZone = computed(() => Session.user().timeZone);

const titlePlaceholder = computed(() => {
  if (pollTemplate.value && pollTemplate.value.titlePlaceholder) {
    return I18n.global.t('common.prefix_eg', {val: pollTemplate.value.titlePlaceholder});
  } else {
    return I18n.global.t('poll_proposal_form.title_placeholder');
  }
});

const knownOptions = computed(() => {
  return (AppConfig.pollTypes[props.poll.pollType].common_poll_options || []);
});

const formattedDuration = computed(() => {
  if (!props.poll.meetingDuration) { return ''; }
  const minutes = parseInt(props.poll.meetingDuration);
  const duration = intervalToDuration({ start: new Date, end: addMinutes(new Date, minutes) });
  return formatDuration(duration, { format: ['hours', 'minutes'] });
});

const visiblePollOptions = computed(() => pollOptions.value.filter(o => !o._destroy));

const hasOptions = computed(() => props.poll.config().has_options);
const minOptions = computed(() => props.poll.config().min_options);
const allowAnonymous = computed(() => !props.poll.config().prevent_anonymous);

const stanceReasonRequiredItems = computed(() => [
  {title: I18n.global.t('poll_common_form.stance_reason_required'), value: 'required'},
  {title: I18n.global.t('poll_common_form.stance_reason_optional'), value: 'optional'},
  {title: I18n.global.t('poll_common_form.stance_reason_disabled'), value: 'disabled'}
]);

const titlePath = computed(() => {
  return (props.poll.isNew() && 'action_dock.new_poll_type') || 'action_dock.edit_poll_type';
});

const titleArgs = computed(() => {
  return {pollType: props.poll.translatedPollType().toLowerCase()};
});

const closesSoon = computed(() => {
  return !(props.poll.closingAt && isAfter(props.poll.closingAt, addHours(new Date(), 24)));
});

const closingSoonItems = computed(() => {
  return 'nobody author undecided_voters voters'.split(' ').map(name => {
    return {title: I18n.global.t(`poll_common_settings.notify_on_closing_soon.${name}`), value: name};
  });
});

const optionFormat = computed(() => props.poll.pollOptionNameFormat);
const hasOptionIcon = computed(() => props.poll.config().has_option_icon);

// Lifecycle
onMounted(() => {
  Records.users.findOrFetchGroups();

  Records.pollTemplates.findOrFetchByKeyOrId(props.poll.pollTemplateKeyOrId()).then(template => {
    pollTemplate.value = template;
  });

  watchRecords({
    collections: ['groups', 'memberships'],
    query: () => {
      return groupItems.value = [
        {title: I18n.global.t('discussion_form.none_invite_only_discussion'), value: null}
      ].concat(Session.user().groups().filter(g => AbilityService.canStartPoll(g)).map(g => ({
        title: g.fullName,
        value: g.id
      })));
    }
  });
});

// Expose handle directive for template
defineOptions({
  directives: { handle: HandleDirective }
});
</script>
<template lang="pug">
v-form.poll-common-form(ref="form" @submit.prevent="submit")
  v-card-title.px-0.pt-4.d-flex
    span(tabindex="-1" v-t="{path: titlePath, args: titleArgs}")
    v-spacer

    v-btn(v-if="poll.id" icon variant="text" :to="urlFor(poll)" aria-hidden='true')
      common-icon(name="mdi-close")
    v-btn(v-if="!poll.id" icon variant="text" @click="$emit('setPoll', null)" aria-hidden='true')
      common-icon(name="mdi-close")

  poll-template-info-panel.mb-4(v-if="pollTemplate" :poll-template="pollTemplate")

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
    :rules="validate('title')"
    maxlength='250'
  )

  tags-field(:model="poll")

  lmo-textarea.poll-common-form-fields__details(
    :model='poll'
    field="details"
    :placeholder="$t('poll_common_form.details_placeholder')"
    :label="$t('poll_common_form.details')"
  )

  template(v-if="hasOptions")
    v-divider.my-4
    .text-subtitle-1.py-2( v-t="'poll_common_form.options'")
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
        v-for="(option, priority) in visiblePollOptions"
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
            div.ml-0(v-if="poll.pollType != 'meeting'")
              v-btn(icon variant="text" @click="editOption(option)" :title="$t('common.action.edit')")
                common-icon(name="mdi-pencil")
            common-icon(name="mdi-drag-vertical" style="cursor: grab" v-handle :title="$t('common.action.move')" v-if="poll.pollType != 'meeting'")

    template(v-if="optionFormat == 'i18n'")
      p This poll cannot have new options added. (contact support if you see this message)

    template(v-if="optionFormat == 'plain'")
      .d-flex.justify-center
        v-btn.poll-common-form__add-option-btn.my-2(
          variant="tonal"
          color="primary"
          @click="addOption"
        )
          span(v-t="'poll_common_add_option.modal.title'")

    template(v-if="optionFormat == 'iso8601'")
      .text-subtitle-1.py-2(v-t="'poll_poll_form.new_option'")
      .d-flex.align-center
        date-time-picker(:min="minDate" v-model="newDateOption")
        v-btn.poll-meeting-form__option-button.ml-4(
          color="primary" variant="tonal"
          @click='addDateOption()'
        )
          span(v-t="'poll_poll_form.add_option_placeholder'")
      .poll-meeting-add-option-menu
        p.text-caption.text-medium-emphasis
          span(v-t="{path: 'poll_common_form.your_in_zone', args: {zone: currentTimeZone}}")
          br
          span(v-t="'poll_meeting_form.participants_see_local_times'")

      .d-flex.align-center.mt-4
        v-text-field.flex-grow-1(
          :label="$t('poll_meeting_form.meeting_duration')"
          v-model="poll.meetingDuration"
          :hint="formattedDuration ? formattedDuration : null"
          type="number"
        )

  template(v-if="poll.pollType == 'count'")
    p.text-subtitle-1.mb-2(v-t="'poll_count_form.agree_target_helptext'")
    .d-flex
      v-text-field.poll-common-form__agree-target(
        v-model="poll.agreeTarget"
        type="number"
        :step="1"
        :label="$t('poll_count_form.agree_target_label')"
      )

  template(v-if="poll.pollType == 'score'")
    v-divider.my-4
    p.mt-4.text-subtitle-1.mb-4(v-t="'poll_common_form.define_minimum_and_maxmimum_score'")
    .d-flex
      v-text-field.poll-score-form__min.mr-2(
        v-model="poll.minScore"
        type="number"
        :step="1"
        :label="$t('poll_common.min_score')")
      v-text-field.poll-score-form__max(
        v-model="poll.maxScore"
        type="number"
        :step="1"
        :label="$t('poll_common.max_score')")

  template(v-if="poll.pollType == 'poll'")
    v-divider.my-4
    p.mt-4.text-subtitle-1.mb-4(v-t="'poll_common_form.how_many_options_can_a_voter_choose'")
    .d-flex
      v-text-field.poll-common-form__minimum-stance-choices.mr-2(
        v-model="poll.minimumStanceChoices"
        type="number"
        :step="1"
        :hint="$t('poll_common_form.choose_at_least')"
        :label="$t('poll_common_form.minimum_choices')")
      v-text-field.poll-common-form__maximum-stance-choices(
        v-model="poll.maximumStanceChoices"
        type="number"
        :step="1"
        :hint="$t('poll_common_form.choose_at_most')"
        :label="$t('poll_common_form.maximum_choices')")

  template(v-if="poll.pollType == 'ranked_choice'")
    v-divider.my-4
    p.mt-4.text-subtitle-1.mb-2(v-t="'poll_ranked_choice_form.minimum_stance_choices_helptext'")
    .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_ranked_choice_form.how_many_ranking_positions_explained'")
    .d-flex.align-center(v-if="poll.pollType == 'ranked_choice'")
      v-text-field.lmo-number-input(
        v-model="poll.minimumStanceChoices"
        :label="$t('poll_ranked_choice_form.number_of_choices')"
        type="number"
        :min="1"
        :max="poll.pollOptionNames.length"
        :rules="validate('minimumStanceChoices')"
      )

  template(v-if="poll.pollType == 'dot_vote'")
    v-divider.my-4
    p.mt-4.text-subtitle-1.mb-4(v-t="'poll_common_form.how_many_points_does_each_voter_have_to_allocate'")
    v-text-field(
      :label="$t('poll_dot_vote_form.dots_per_person')"
      type="number"
      min="1"
      v-model="poll.dotsPerPerson"
      :rules="validate('dotsPerPerson')"
    )

  template(v-if="poll.config().allow_none_of_the_above")
    v-divider.my-4
    v-checkbox.poll-settings-allow-none-of-the-above(
      hide-details
      v-model="poll.showNoneOfTheAbove"
      :label="$t('poll_common_settings.show_none_of_the_above')"
    )

  v-divider.my-4
  .text-subtitle-1.pb-2(v-t="'poll_common_form.deadline'")
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.how_much_time_to_vote'")
  poll-common-closing-at-field.pb-4(:poll="poll")

  v-divider.my-4
  .text-subtitle-1.pb-2(v-t="'poll_common_settings.who_can_vote'")
  v-radio-group(
    v-model="poll.specifiedVotersOnly"
    :disabled="!poll.closingAt"
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

  div(style="height: 64px" v-if="poll.specifiedVotersOnly")
    .text-body-2.font-italic.text-medium-emphasis.mt-n4.py-4(
      v-t="{path: 'poll_common_settings.invite_people_next', args: {poll_type: poll.translatedPollType()}}")

  div(style="height: 64px" v-if="!poll.id && !poll.specifiedVotersOnly")
    v-checkbox.mt-n4.pb-0(
      :label="$t('poll_common_form.notify_everyone_when_poll_starts', {poll_type: poll.translatedPollType()})"
      v-model="poll.notifyRecipients")

  v-divider.my-4
  .text-subtitle-1.pb-2(v-t="'poll_common_form.reminder_notification'")
  .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.reminder_helptext'")
  p(v-if="poll.closingAt && closesSoon"
    v-t="{path: 'poll_common_settings.notify_on_closing_soon.voting_closes_too_soon', args: {pollType: poll.translatedPollType()}}")
  v-select(
    :disabled="!poll.closingAt"
    :label="$t('poll_common_settings.notify_on_closing_soon.voting_title')"
    v-model="poll.notifyOnClosingSoon"
    :items="closingSoonItems")

  template(v-if="allowAnonymous")
    v-divider.mb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_form.anonymous_voting'")
    .text-body-2.pb-2.text-medium-emphasis(v-t="{path: 'poll_common_form.anonymous_voting_description', args: {poll_type: poll.translatedPollType()}}")
    v-checkbox.poll-settings-anonymous(
      hide-label
      :disabled="!poll.isNew()"
      v-model="poll.anonymous"
      :label="$t('poll_common_form.votes_are_anonymous')")

    v-divider.mb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_card.hide_results'")
    .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.hide_results_description'")
    v-select.poll-common-settings__hide-results(
      :label="$t('poll_common_card.hide_results')"
      :items="hideResultsItems"
      v-model="poll.hideResults"
      :disabled="!poll.isNew() && currentHideResults == 'until_closed'"
    )

  template(v-if="poll.config().can_shuffle_options")
    v-divider.pb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_settings.shuffle_options'")
    .text-body-2.pb-2.text-medium-emphasis(v-t="'poll_common_settings.reduce_bias_by_showing_options_in_random_order'")
    v-checkbox.poll-settings-shuffle-options(
      hide-details
      v-model="poll.shuffleOptions"
      :label="$t('poll_common_settings.show_options_in_random_order')")

  template(v-if="!poll.config().hide_reason_required")
    v-divider.pb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_form.vote_reason'")
    .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.vote_reason_description'")
    v-select(
      :label="$t('poll_common_form.stance_reason_required_label')"
      :items="stanceReasonRequiredItems"
      v-model="poll.stanceReasonRequired"
    )
    //.text-body-2.font-italic.text-medium-emphasis(v-if="poll.stanceReasonRequired != 'disabled' && poll.config().per_option_reason_prompt" v-t="'poll_common_form.each_option_has_own_reason_prompt'")

    v-text-field(
      v-if="poll.stanceReasonRequired != 'disabled' && !poll.config().per_option_reason_prompt"
      v-model="poll.reasonPrompt"
      :label="$t('poll_common_form.reason_prompt')"
      :hint="$t('poll_option_form.prompt_hint')"
      :placeholder="$t('poll_common.reason_placeholder')")

    v-checkbox(
      v-if="poll.stanceReasonRequired != 'disabled'"
      v-model="poll.limitReasonLength"
      :label="$t('poll_common_form.limit_reason_length')"
    )

  template(v-if="poll.config().allow_quorum")
    v-divider.mb-4
    .text-subtitle-1.pb-2(v-t="'poll_common_form.quorum'")
    .text-body-2.pb-4.text-medium-emphasis(v-t="'poll_common_form.quorum_hint'")
    v-number-input.mb-4(
      v-model="poll.quorumPct"
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
      v-if="poll.quorumPct && poll.pollType == 'proposal' && poll.config().allow_vote_share_requirement"
      v-t="'poll_common_form.quorum_tip_vote_share_requirement'"
    )

  common-notify-fields(v-if="poll.id" :model="poll" includeActor)

  v-card-actions.poll-common-form-actions
    help-btn(path='en/user_manual/polls/intro_to_decisions')
    v-spacer
    v-btn(
      variant="plain"
      @click="discardDraft"
    )
     span(v-t="'common.reset'")

    v-btn.poll-common-form__submit(
      color="primary"
      @click='submit'
      :loading="loading"
      :disabled="hasOptions && pollOptions.length < minOptions"
      variant="elevated"
    )
      span(v-if='poll.id' v-t="'common.action.save_changes'")
      span(v-if='!poll.id && poll.closingAt' v-t="{path: 'poll_common_form.start_poll_type', args: {poll_type: poll.translatedPollType()}}")
      span(v-if='!poll.id && !poll.closingAt' v-t="'poll_common_form.save_poll'")

</template>
