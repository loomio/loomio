<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus        from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { I18n } from '@/i18n';
import { mdiMagnify, mdiClose } from '@mdi/js';

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
      mdiMagnify,
      mdiClose,
      loading: false,
      query: this.initialQuery,
      results: [],
      users: {},
      type: null,
      typeItems: [
        {title: I18n.global.t('search_modal.all_content'), value: null},
        {title: I18n.global.t('group_page.discussions'), value: 'Discussion'},
        {title: I18n.global.t('navbar.search.comments'), value: 'Comment'},
        {title: I18n.global.t('group_page.polls'), value: 'Poll'},
        {title: I18n.global.t('poll_common.votes'), value: 'Stance'},
        {title: I18n.global.t('poll_common.outcomes'), value: 'Outcome'},
      ],
      orgItems: [
        {title: I18n.global.t('sidebar.all_groups'), value: null},
        {title: I18n.global.t('sidebar.direct_discussions'), value: 0}
      ].concat(Session.user().parentGroups().map(g => ({
        title: g.name,
        value: g.id
      }))),
      orgId: null,
      groupItems: [],
      groupId: null,
      order: "authored_at_desc",
      orderItems: [
        {title: I18n.global.t('search_modal.best_match'), value: null},
        {title: I18n.global.t('strand_nav.newest'), value: "authored_at_desc"},
        {title: I18n.global.t('strand_nav.oldest'), value: "authored_at_asc"},
      ],
      tag: null,
      tagItems: [],
      group: null,
      resultsQuery: null
    };
  },

  methods: {
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

    closeModal() {
      EventBus.$emit('closeModal');
    },

    updateTagItems(group) {
      this.tagItems = [{title: I18n.global.t('search_modal.any_tag'), value: null}].concat(group.tagsByName().map(t => ({
        title: t.name,
        value: t.name
      })));
    }
  },

  watch: {
    orgId(newval, oldval){
      if (this.orgId) {
        this.group = Records.groups.find(this.orgId);
        const base = [
          {title: I18n.global.t('search_modal.all_subgroups'), value: null},
          {title: I18n.global.t('search_modal.parent_only'), value: this.orgId},
        ];
        this.updateTagItems(this.group);
        this.groupItems = base.concat(this.group.subgroups().filter(g => !g.archivedAt && g.membershipFor(Session.user())).map(g => ({
          title: g.name,
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
v-card.search-modal(:title="$t('common.action.search')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    .d-flex.align-center
      v-text-field(
        :append-inner-icon="mdiMagnify"
        @click:append-inner="fetch"
        color="info"
        variant="solo-filled"
        :loading="loading"
        autofocus
        v-model="query"
        @keydown.enter.prevent="fetch"
        hide-details
      )

    .d-flex.align-center.pt-4
      v-select.mr-2(variant="solo-filled" density="compact" v-model="orgId" :items="orgItems")
      v-select.mr-2(variant="solo-filled" density="compact" v-if="groupItems.length > 2" v-model="groupId" :items="groupItems" :disabled="!orgId")
      v-select.mr-2(variant="solo-filled" density="compact" v-if="tagItems.length" v-model="tag" :items="tagItems")
      v-select.mr-2(variant="solo-filled" density="compact" v-model="type" :items="typeItems")
      v-select(variant="solo-filled" density="compact" v-model="order" :items="orderItems")
    search-results-list(
      :results="results"
      :empty-text="!loading && resultsQuery && results.length === 0 ? $t('discussions_panel.no_results_found', { search: resultsQuery }) : null"
    )

</template>
