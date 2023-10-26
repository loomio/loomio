<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus        from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import Vue from 'vue';
import I18n from '@/i18n';

export default {
  props: {
    initialOrgId: {
      required: false,
      default: null,
      type: Number
    },
    initialGroupId: {
      required: false,
      default: null,
      type: Number
    },
    initialType: {
      required: false,
      default: null,
      type: String
    },
    initialQuery: {
      required: false,
      default: null,
      type: String
    }
  },

  created() {
    this.orgId = this.initialOrgId;
    this.groupId = this.initialGroupId;
    this.type = this.initialType;
  },

  data() {
    return {
      loading: false,
      query: this.initialQuery,
      results: [],
      users: {},
      type: null,
      typeItems: [
        {text: I18n.t('search_modal.all_content'), value: null},
        {text: I18n.t('group_page.threads'), value: 'Discussion'},
        {text: I18n.t('navbar.search.comments'), value: 'Comment'},
        {text: I18n.t('group_page.decisions'), value: 'Poll'},
        {text: I18n.t('poll_common.votes'), value: 'Stance'},
        {text: I18n.t('poll_common.outcomes'), value: 'Outcome'},
      ],
      orgItems: [
        {text: I18n.t('sidebar.all_groups'), value: null},
        {text: I18n.t('sidebar.invite_only_threads'), value: 0}
      ].concat(Session.user().parentGroups().map(g => ({
        text: g.name,
        value: g.id
      }))),
      orgId: null,
      groupItems: [],
      groupId: null,
      order: null,
      orderItems: [
        {text: I18n.t('search_modal.best_match'), value: null},
        {text: I18n.t('strand_nav.newest'), value: "authored_at_desc"},
        {text: I18n.t('strand_nav.oldest'), value: "authored_at_asc"},
      ],
      tag: null,
      tagItems: [],
      group: null,
      resultsQuery: null
    };
  },

  methods: {
    userById(id) { return Records.users.find(id); },
    pollById(id) { return Records.polls.find(id); },
    groupById(id) { return Records.groups.find(id); },

    fetch() {
      if (!this.query) {
        this.results = [];
      } else {
        this.loading = true;
        this.resultsQuery = this.query;
        Records.remote.get('search', {
          query: this.query,
          type: this.type,
          org_id: this.orgId,
          group_id: this.groupId,
          order: this.order,
          tag: this.tag
        }).then(data => {
          this.results = data.search_results;
          this.lastQuery = this.query;
        }).finally(() => {
          this.loading = false;
        });
      }
    },

    urlForResult(result) {
      switch (result.searchable_type) {
        case 'Discussion':
          return `/d/${result.discussion_key}/${this.stub(result.discussion_title)}`;
        case 'Comment':
          return `/d/${result.discussion_key}/comment/${result.searchable_id}`;
        case 'Poll': case 'Outcome': case 'Stance':
          if (result.sequence_id) {
            return `/d/${result.discussion_key}/${this.stub(result.discussion_title)}/${result.sequence_id}`;
          } else {
            return `/p/${result.poll_key}/${this.stub(result.poll_title)}`;
          }
        default:
          return '/notdefined';
      }
    },

    stub(name) {
      return name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase();
    },

    closeModal() {
      EventBus.$emit('closeModal');
    },

    updateTagItems(group) {
      this.tagItems = [{text: I18n.t('search_modal.any_tag'), value: null}].concat(group.tagsByName().map(t => ({
        text: t.name,
        value: t.name
      })));
    }
  },

  watch: {
    orgId(newval, oldval){
      if (this.orgId) {
        this.group = Records.groups.find(this.orgId);
        const base = [
          {text: I18n.t('search_modal.all_subgroups'), value: null},
          {text: I18n.t('search_modal.parent_only'), value: this.orgId},
        ];
        this.updateTagItems(this.group);
        this.groupItems = base.concat(this.group.subgroups().filter(g => !g.archivedAt && g.membershipFor(Session.user())).map(g => ({
          text: g.name,
          value: g.id
        })));
      } else {
        this.groupItems = [];
        this.tagItems = [];
      }
      this.fetch();
    },

    groupId(groupId) { 
      if (groupId) {
        const group = Records.groups.find(groupId);
        this.updateTagItems(group);
      }
      this.fetch();
    },
    type() { this.fetch(); },
    order() { this.fetch(); },
    tag() { this.fetch(); },

    '$route.path': 'closeModal'
  }
};

</script>
<template lang="pug">
v-card.search-modal
  .d-flex.px-4.pt-4.align-center
    v-text-field(
      :loading="loading"
      autofocus
      filled
      rounded
      single-line
      append-icon="mdi-magnify"
      append-outer-icon="mdi-close"
      @click:append-outer="closeModal"
      @click:append="fetch"
      v-model="query"
      :placeholder="$t('common.action.search')"
      @keydown.enter.prevent="fetch"
      hide-details
      )
  .d-flex.px-4.align-center
    v-select.mr-2(v-model="orgId" :items="orgItems")
    v-select.mr-2(v-if="groupItems.length > 2" v-model="groupId" :items="groupItems" :disabled="!orgId")
    v-select.mr-2(v-if="tagItems.length" v-model="tag" :items="tagItems")
    v-select.mr-2(v-model="type" :items="typeItems")
    v-select(v-model="order" :items="orderItems")
  v-list(two-line)
    v-list-item.poll-common-preview(v-if="!loading && resultsQuery && results.length == 0")
      v-list-item-title(v-t="{path: 'discussions_panel.no_results_found', args: {search: resultsQuery}}")
    v-list-item.poll-common-preview(v-for="result in results" :key="result.id" :to="urlForResult(result)")
      v-list-item-avatar 
        poll-common-icon-panel(v-if="['Outcome', 'Poll'].includes(result.searchable_type)" :poll='pollById(result.poll_id)' show-my-stance)
        user-avatar(v-else :user="userById(result.author_id)")
      v-list-item-content
        v-list-item-title.d-flex
          span.text-truncate {{ result.poll_title || result.discussion_title }}
          tags-display.ml-1(:tags="result.tags" :group="groupById(result.group_id)" smaller)
          v-spacer
          time-ago.text--secondary(style="font-size: 0.875rem;" :date="result.authored_at")
        v-list-item-subtitle.text--primary(v-html="result.highlight")
        v-list-item-subtitle
          span
            span {{result.searchable_type}}
            mid-dot
            span {{result.author_name}}
            mid-dot
            span {{result.group_name || $t('discussion.invite_only')}}

</template>
