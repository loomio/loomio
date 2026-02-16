<script lang="js">
import AppConfig    from '@/shared/services/app_config';
import Session      from '@/shared/services/session';
import Records      from '@/shared/services/records';
import EventBus     from '@/shared/services/event_bus';
import PollTemplateService     from '@/shared/services/poll_template_service';
import { pickBy } from 'lodash-es';
import { ContainerMixin, HandleDirective } from 'vue-slicksort';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  directives: {
    handle: HandleDirective
  },

  props: {
    discussion: Object,
    group: Object
  },

  data() {
    return {
      isSorting: false,
      showHidden: false,
      hasHiddenTemplates: false,
      returnTo: Session.returnTo(),
      groups: [],
      pollTemplates: [],
      hiddenTemplates: [],
      discussionTemplate: null,
      actions: {},
      hiddenActions: {},
      filter: 'proposal',
      filterLabels: {
        recommended: 'decision_tools_card.recommended',
        proposal: 'decision_tools_card.proposal_title',
        poll: 'decision_tools_card.poll_title'
      }
    };
  },

  created() {
    this.watchRecords({
      collections: ["pollTemplates"],
      query: () => this.query()
    });

    if (this.discussion && this.discussion.discussionTemplateId) {
      Records.discussionTemplates.findOrFetchById(this.discussion.discussionTemplateId).then(dt => {
        this.discussionTemplate = dt;
        if (dt.pollTemplateKeysOrIds.length) { this.filter = 'recommended'; }
        return this.query();
      });
    }

    if (this.group) {
      Records.pollTemplates.fetchByGroupId(this.group.id);
    }

    EventBus.$on('sortPollTemplates', () => { return this.isSorting = true; });
  },

  methods: {
    query() {
      if (this.filter === 'recommended') {
        this.pollTemplates = this.discussionTemplate.pollTemplates();
      } else {
        const pollTypeFilter = (() => { switch (this.filter) {
          case 'proposal':
            return {pollType: {$in: ['proposal', 'question']}};
          case 'poll':
            return {pollType: {$in: ['score', 'poll', 'ranked_choice', 'dot_vote', 'meeting', 'count']}};
        } })();

        this.pollTemplates = Records.pollTemplates.collection.chain().
          find({groupId: this.group.id || null}).
          find({example: {$ne: true}}).
          find({discardedAt: null}).
          find(pollTypeFilter).
          simplesort('position').data();

        this.hiddenTemplates = Records.pollTemplates.collection.chain().
          find({groupId: this.group.id || null}).
          find({example: {$ne: true}}).
          find({discardedAt: {$ne: null}}).
          find(pollTypeFilter).
          simplesort('position').data();

        this.hasHiddenTemplates = this.hiddenTemplates.length > 0;
      }

      this.actions = {};
      this.pollTemplates.forEach((pollTemplate, i) => {
        if (this.filter === 'recommended') {
          this.actions[i] = {};
        } else {
          this.actions[i] = PollTemplateService.actions(pollTemplate, this.group);
        }
      });

      this.hiddenActions = {};
      this.hiddenTemplates.forEach((pollTemplate, i) => {
        this.hiddenActions[i] = PollTemplateService.actions(pollTemplate, this.group);
      });
    },

    cloneTemplate(template) {
      const poll = template.buildPoll();
      if (this.discussion) {
        poll.discussionId = this.discussion.id;
        poll.groupId = this.discussion.groupId;
      } else {
        if (this.group) { poll.groupId = this.group.id; }
      }
      this.$emit('setPoll', poll);
    },

    sortEnded() {
      this.isSorting = false;
      setTimeout(() => {
        const ids = this.pollTemplates.map(p => p.id || p.key);
        Records.remote.post('poll_templates/positions', {group_id: this.group.id, ids});
      });
    }
  },

  watch: {
    filter() {
      this.showHidden = false;
      this.query();
    },
    showHidden: 'query',
    discussionTemplate: 'query'
  },

  computed: {
    userIsAdmin() {
      return this.group.adminsInclude(Session.user());
    },

    userCanCreateTemplates() {
      return this.userIsAdmin || (this.group.membersCanCreateTemplates && this.group.membersInclude(Session.user()));
    },

    filters() {
      const recommendedIcon = (this.discussionTemplate && this.discussionTemplate.pollTemplateKeysOrIds.length && 'mdi-star') || null;
      return pickBy({
        recommended: recommendedIcon,
        proposal: 'mdi-thumbs-up-down',
        poll: 'mdi-poll'
      }
      , v => !!v);
    }
  }
};
</script>

<template lang="pug">
.poll-common-templates-list
  v-alert.ma-4(v-if="userIsAdmin && !discussion" type="info" variant="tonal")
    span(v-t="'poll_common.these_are_templates'")
    space
    help-link(path="user_manual/polls/poll_templates")

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
            //- v-list-item-action.handle(v-handle style="cursor: grab")
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
