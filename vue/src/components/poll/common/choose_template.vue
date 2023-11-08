<script lang="js">
import AppConfig    from '@/shared/services/app_config';
import Session      from '@/shared/services/session';
import Records      from '@/shared/services/records';
import EventBus     from '@/shared/services/event_bus';
import PollTemplateService     from '@/shared/services/poll_template_service';
import {map, without, compact, pickBy} from 'lodash-es';
import { ContainerMixin, HandleDirective } from 'vue-slicksort';
import ThreadTemplateHelpPanel from '@/components/thread_template/help_panel';

export default {
  components: {ThreadTemplateHelpPanel},
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
      returnTo: Session.returnTo(),
      groups: [],
      pollTemplates: [],
      discussionTemplate: null,
      actions: {},
      filter: 'proposal',
      singleList: !this.group.categorizePollTemplates,
      filterLabels: {
        recommended: 'decision_tools_card.recommended',
        proposal: 'decision_tools_card.proposal_title',
        poll: 'decision_tools_card.poll_title',
        meeting: 'decision_tools_card.meeting',
        admin: 'group_page.settings',
        templates: 'templates.templates'
      }
    };
  },

  created() {
    this.watchRecords({
      collections: ["pollTemplates"],
      query: records => this.query()
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
        let params;
        if (this.group.categorizePollTemplates) {
          params = (() => { switch (this.filter) {
            case 'proposal':
              return {pollType: {$in: ['proposal', 'question']}, discardedAt: null};
            case 'poll':
              return {pollType: {$in: ['score', 'poll', 'ranked_choice', 'dot_vote']}, discardedAt: null};
            case 'meeting':
              return {pollType: {$in: ['meeting', 'count']}, discardedAt: null};
            case 'admin':
              return {discardedAt: {$ne: null}};
          } })();
        } else {
          params = (() => { switch (this.filter) {
            case 'admin':
              return {discardedAt: {$ne: null}};
            default:
              return {discardedAt: null};
          } })();
        }

        this.pollTemplates = Records.pollTemplates.collection.chain().
          find({groupId: this.group.id || null}).
          find(params).
          simplesort('position').data();
      }

      this.actions = {};
      this.pollTemplates.forEach((pollTemplate, i) => {
        if (this.filter === 'recommended') {
          this.actions[i] = {};
        } else {
          this.actions[i] = PollTemplateService.actions(pollTemplate, this.group);
        }
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
    filter: 'query',
    discussionTemplate: 'query',
    singleList() {
      setTimeout(() => {
        this.group.categorizePollTemplates = !this.singleList;
        Records.remote.post('poll_templates/settings', {group_id: this.group.id, categorize_poll_templates: this.group.categorizePollTemplates});
      });
    }
  },

  computed: {
    userIsAdmin() {
      return this.group.adminsInclude(Session.user());
    },

    filters() {
      if (this.singleList) {
        return {templates: 'mdi-thumbs-up-down'};
      } else {
        const recommendedIcon = (this.discussionTemplate && this.discussionTemplate.pollTemplateKeysOrIds.length && 'mdi-star') || null;
        return pickBy({
          recommended: recommendedIcon,
          proposal: 'mdi-thumbs-up-down',
          poll: 'mdi-poll',
          meeting: 'mdi-calendar'
        }
        , v => !!v);
      }
    }
  }
};
</script>

<template lang="pug">
.poll-common-templates-list
  thread-template-help-panel(v-if="discussionTemplate" :discussion-template="discussionTemplate")
  .d-flex(:class="{'px-4': !discussion}")
    v-chip.mr-1(
      v-for="icon, name in filters"
      label
      :key="name"
      :outlined="filter != name"
      @click="filter = name"
      :class="'poll-common-choose-template__'+name"
    )
      v-icon(small).mr-2 {{icon}}
      span.poll-type-chip-name(v-t="filterLabels[name]")
    template(v-if="userIsAdmin")
      v-spacer
      v-chip(@click="filter = 'admin'" :outlined="filter != 'admin'")
        v-icon(small).mr-2 mdi-cog
        span.poll-type-chip-name(v-t="filterLabels['admin']")
  v-list.decision-tools-card__poll-types(two-line dense)
    template(v-if="filter == 'admin'")
      v-list-item.decision-tools-card__new-template(
        :to="'/poll_templates/new?group_id='+group.id+'&return_to='+returnTo"
        :class="'decision-tools-card__poll-type--new-template'"
        :key="99999"
      )
        v-list-item-content
          v-list-item-title(v-t="'discussion_form.new_template'")
          v-list-item-subtitle(v-t="'poll_common.create_a_custom_process'")

      v-checkbox.pl-4(v-model="singleList" :label="$t('poll_common.show_all_templates_in_one_list')")
      v-subheader(v-if="pollTemplates.length" v-t="'poll_common.hidden_poll_templates'")

    template(v-if="isSorting")
      sortable-list(v-model="pollTemplates"  @sort-end="sortEnded" append-to=".decision-tools-card__poll-types"  lock-axis="y" axis="y")
        sortable-item(v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key")
          v-list-item.decision-tools-card__poll-type(
            :class="'decision-tools-card__poll-type--' + template.pollType"
            :key='template.id || template.key'
          )
            v-list-item-content
              v-list-item-title
                span {{ template.processName }}
                v-chip.ml-2(x-small outlined v-if="filter == 'admin' && !template.id" v-t="'poll_common_action_panel.default_template'")
                v-chip.ml-2(x-small outlined v-if="filter == 'admin' && template.id" v-t="'poll_common_action_panel.custom_template'")
              v-list-item-subtitle {{ template.processSubtitle }}
            v-list-item-action.handle(v-handle style="cursor: grab")
              v-icon mdi-drag-vertical
    template(v-else)
      v-list-item.decision-tools-card__poll-type(
        v-for='(template, i) in pollTemplates'
        @click="cloneTemplate(template)"
        :class="'decision-tools-card__poll-type--' + template.pollType"
        :key="template.id || template.key"
      )
        v-list-item-content
          v-list-item-title
            span {{ template.processName }}
            v-chip.ml-2(x-small outlined v-if="filter == 'admin' && !template.id" v-t="'poll_common_action_panel.default_template'")
            v-chip.ml-2(x-small outlined v-if="filter == 'admin' && template.id" v-t="'poll_common_action_panel.custom_template'")
          v-list-item-subtitle {{ template.processSubtitle }}
        v-list-item-action
          action-menu(:actions='actions[i]', small, icon, :name="$t('action_dock.more_actions')")

</template>
<style>
.decision-tools-card__poll-type {
  user-select: none;
}
</style>
