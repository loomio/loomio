<script setup>
import AppConfig    from '@/shared/services/app_config';
import Session      from '@/shared/services/session';
import Records      from '@/shared/services/records';
import EventBus     from '@/shared/services/event_bus';
import PollTemplateService     from '@/shared/services/poll_template_service';
import { pickBy } from 'lodash-es';
import { HandleDirective } from 'vue-slicksort';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, watch } from 'vue';

const vHandle = HandleDirective;

const props = defineProps({
  topic: Object,
  group: Object
});

const emit = defineEmits(['setPoll']);

const isSorting = ref(false);
const showHidden = ref(false);
const hasHiddenTemplates = ref(false);
const hiddenAlert = ref(Session.user().hasExperienced('dismissPollTemplatesAlert'));
const returnTo = Session.returnTo();
const pollTemplates = ref([]);
const hiddenTemplates = ref([]);
const discussionTemplate = ref(null);
const actions = ref({});
const hiddenActions = ref({});
const filter = ref('proposal');

const filterLabels = {
  recommended: 'decision_tools_card.recommended',
  proposal: 'decision_tools_card.proposal_title',
  poll: 'decision_tools_card.poll_title'
};

const discussion = computed(() => props.topic.discussion());

const userIsAdmin = computed(() => props.group.adminsInclude(Session.user()));

const userCanCreateTemplates = computed(() => {
  return userIsAdmin.value || (props.group.membersCanCreateTemplates && props.group.membersInclude(Session.user()));
});

const filters = computed(() => {
  const recommendedIcon = (discussionTemplate.value && discussionTemplate.value.pollTemplateKeysOrIds.length && 'mdi-star') || null;
  return pickBy({
    recommended: recommendedIcon,
    proposal: 'mdi-thumbs-up-down',
    poll: 'mdi-poll'
  }, v => !!v);
});

function query() {
  if (filter.value === 'recommended') {
    pollTemplates.value = discussionTemplate.value.pollTemplates();
  } else {
    const pollTypeFilter = (() => { switch (filter.value) {
      case 'proposal':
        return {pollType: {$in: ['proposal', 'question']}};
      case 'poll':
        return {pollType: {$in: ['score', 'poll', 'ranked_choice', 'dot_vote', 'meeting', 'count']}};
    } })();

    pollTemplates.value = Records.pollTemplates.collection.chain().
      find({groupId: props.group.id || null}).
      find({example: {$ne: true}}).
      find({discardedAt: null}).
      find(pollTypeFilter).
      simplesort('position').data();

    hiddenTemplates.value = Records.pollTemplates.collection.chain().
      find({groupId: props.group.id || null}).
      find({example: {$ne: true}}).
      find({discardedAt: {$ne: null}}).
      find(pollTypeFilter).
      simplesort('position').data();

    hasHiddenTemplates.value = hiddenTemplates.value.length > 0;
  }

  actions.value = {};
  pollTemplates.value.forEach((pollTemplate, i) => {
    if (filter.value === 'recommended') {
      actions.value[i] = {};
    } else {
      actions.value[i] = PollTemplateService.actions(pollTemplate, props.group);
    }
  });

  hiddenActions.value = {};
  hiddenTemplates.value.forEach((pollTemplate, i) => {
    hiddenActions.value[i] = PollTemplateService.actions(pollTemplate, props.group);
  });
}

function dismissAlert() {
  hiddenAlert.value = true;
  Records.users.saveExperience('dismissPollTemplatesAlert');
}

function cloneTemplate(template) {
  const poll = template.buildPoll();
  poll.topicId = props.topic.id
  emit('setPoll', poll);
}

function sortEnded() {
  isSorting.value = false;
  setTimeout(() => {
    const ids = pollTemplates.value.map(p => p.id || p.key);
    Records.remote.post('poll_templates/positions', {group_id: props.group.id, ids});
  });
}

watch(filter, () => {
  showHidden.value = false;
  query();
});
watch(showHidden, query);
watch(discussionTemplate, query);

// init
const { watchRecords } = useWatchRecords();
watchRecords({
  collections: ["pollTemplates"],
  query: () => query()
});

if (discussion.value && discussion.value.discussionTemplateId) {
  Records.discussionTemplates.findOrFetchById(discussion.value.discussionTemplateId).then(dt => {
    discussionTemplate.value = dt;
    if (dt.pollTemplateKeysOrIds.length) { filter.value = 'recommended'; }
    return query();
  });
}

if (props.group) {
  Records.pollTemplates.fetchByGroupId(props.group.id);
}

EventBus.$on('sortPollTemplates', () => { isSorting.value = true; });
</script>

<template lang="pug">
.poll-common-templates-list
  v-alert.ma-4(v-if="userIsAdmin && !discussion && !hiddenAlert" type="info" variant="tonal" closable @click:close="dismissAlert")
    span(v-t="'poll_common.these_are_templates'")
    |
    span(v-t="'common.templates_admin_hint'")

  .d-flex(:class="{'px-4': !discussion}")
    v-chip.mr-1(
      :color="filter == name ? 'primary' : null"
      v-for="icon, name in filters"
      label
      :key="name"
      @click="filter = name"
      :class="'poll-common-choose-template__'+name"
    )
      common-icon.mr-2(size="small" :name="icon" :color="filter == name ? 'primary' : null")

      span.poll-type-chip-name(v-t="filterLabels[name]")
    template(v-if="userCanCreateTemplates")
      v-spacer
      v-btn(variant="tonal" size="small" :to="'/poll_templates/browse?group_id='+group.id+'&return_to='+returnTo")
        span.text-medium-emphasis(v-t="'discussion_form.new_template'")
  v-list.decision-tools-card__poll-types(lines="two" density="comfortable")

    template(v-if="isSorting")
      sortable-list(v-model:list="pollTemplates"  @sort-end="sortEnded" append-to=".decision-tools-card__poll-types"  lock-axis="y" axis="y")
        sortable-item(v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key")
          v-list-item.decision-tools-card__poll-type(
            :class="'decision-tools-card__poll-type--' + template.pollType"
            :key='template.id || template.key'
            lines="two"
          )
            v-list-item-title
              span {{ template.processName }}
            v-list-item-subtitle {{ template.processSubtitle }}
            template(v-slot:append)
              common-icon(name="mdi-drag-vertical")
    v-list-item(v-if="!isSorting && !pollTemplates.length")
      v-list-item-title.text-medium-emphasis(v-t="'poll_common.all_templates_hidden'")
    template(v-else-if="!isSorting")
      v-list-item.decision-tools-card__poll-type(
        v-for='(template, i) in pollTemplates'
        @click="cloneTemplate(template)"
        :class="'decision-tools-card__poll-type--' + template.pollType"
        :key="template.id || template.key"
        lines="two"
      )
        v-list-item-title
          span {{ template.processName }}
        v-list-item-subtitle {{ template.processSubtitle }}
        template(v-slot:append)
          action-menu(:actions='actions[i]' size="small" icon :name="$t('action_dock.more_actions')")

    .d-flex.justify-center.my-2(v-if="userIsAdmin && hasHiddenTemplates && !showHidden && filter !== 'recommended'")
      v-btn.text-medium-emphasis(variant="text" size="small" @click="showHidden = true")
        span(v-t="'discussion_template.show_hidden_templates'")

    template(v-if="userIsAdmin && showHidden")
      v-list-subheader(v-t="'discussion_template.hidden_templates'")
      v-list-item.decision-tools-card__poll-type(
        v-for='(template, i) in hiddenTemplates'
        @click="cloneTemplate(template)"
        :class="'decision-tools-card__poll-type--' + template.pollType"
        :key="template.id || template.key"
        lines="two"
      )
        v-list-item-title
          span {{ template.processName }}
        v-list-item-subtitle {{ template.processSubtitle }}
        template(v-slot:append)
          action-menu(:actions='hiddenActions[i]' size="small" icon :name="$t('action_dock.more_actions')")
      .d-flex.justify-center.my-2
        v-btn.text-medium-emphasis(variant="text" size="small" @click="showHidden = false")
          span(v-t="'discussion_template.show_fewer'")

</template>
<style>
.sortable-list-item {
  cursor: grab;
}

.decision-tools-card__poll-type {
  user-select: none;
}
</style>
