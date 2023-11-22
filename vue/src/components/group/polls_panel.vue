<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records from '@/shared/services/records';
import PageLoader from '@/shared/services/page_loader';
import EventBus       from '@/shared/services/event_bus';
import Session       from '@/shared/services/session';
import { intersection } from 'lodash-es';
import { uniq } from 'lodash-es';

export default
{
  data() {
    return {
      group: null,
      polls: [],
      loader: null,
      pollTypes: AppConfig.pollTypes,
      per: 25,
      dummyQuery: null
    };
  },

  created() {
    this.group = Records.groups.find(this.$route.params.key);

    this.initLoader();

    this.watchRecords({
      collections: ['polls', 'groups', 'stances'],
      query: () => this.findRecords()
    });

    this.loader.fetch(this.page).then(() => {
      EventBus.$emit('currentComponent', {
        page: 'groupPage',
        title: this.group.name,
        group: this.group
      });
    });
  },

  methods: {
    openSearchModal() {
      let initialOrgId = null;
      let initialGroupId = null;
    
      if (this.group.isParent()) {
        initialOrgId = this.group.id;
      } else {
        initialOrgId = this.group.parentId;
        initialGroupId = this.group.id;
      }

      EventBus.$emit('openModal', {
        component: 'SearchModal',
        persistent: false,
        maxWidth: 900,
        props: {
          initialType: 'Poll',
          initialOrgId,
          initialGroupId,  
          initialQuery: this.dummyQuery
        }
      });
    },

    initLoader() {
      return this.loader = new PageLoader({
        path: 'polls',
        order: 'createdAt',
        params: {
          exclude_types: 'group',
          group_key: this.$route.params.key,
          status: this.$route.query.status,
          poll_type: this.$route.query.poll_type,
          subgroups: this.$route.query.subgroups,
          per: this.per
        }
      });
    },

    findRecords() {
      const groupIds = (() => { switch (this.$route.query.subgroups || 'mine') {
        case 'all': return this.group.organisationIds();
        case 'none': return [this.group.id];
        case 'mine': return uniq([this.group.id].concat(intersection(this.group.organisationIds(), Session.user().groupIds())));
      } })();

      let chain = Records.polls.collection.chain();
      chain = chain.find({groupId: {$in: groupIds}});
      chain = chain.find({discardedAt: null});

      switch (this.$route.query.status) {
        case 'active':
          chain = chain.find({'closedAt': null});
          break;
        case 'closed':
          chain = chain.find({'closedAt': {$ne: null}});
          break;
        case 'vote':
          chain = chain.find({'closedAt': null}).where(p => p.iCanVote() && !p.iHaveVoted());
          break;
      }

      if (this.$route.query.poll_type) {
        chain = chain.find({'pollType': this.$route.query.poll_type});
      }

      if (this.loader.pageWindow[this.page]) {
        if (this.page === 1) {
          chain = chain.find({createdAt: {$gte: this.loader.pageWindow[this.page][0]}});
        } else {
          chain = chain.find({createdAt: {$jbetween: this.loader.pageWindow[this.page]}});
        }
        this.polls = chain.simplesort('createdAt', true).data();
      } else {
        this.polls = [];
      }
    }
  },

  watch: {
    '$route.query.status'() {
      this.initLoader().fetch(this.page);
    },
    '$route.query.poll_type'() {
      this.initLoader().fetch(this.page);
    },
    '$route.query.subgroups'() {
      this.initLoader().fetch(this.page);
    },
    '$route.query.page'() {
      this.loader.fetch(this.page);
    }
  },

  computed: {
    totalPages() {
      return Math.ceil(parseFloat(this.loader.total) / parseFloat(this.per));
    },
    canStartPoll() { return AbilityService.canStartPoll(this.group); },
    page: {
      get() { return parseInt(this.$route.query.page) || 1; },
      set(val) {
        return this.$router.replace({query: Object.assign({}, this.$route.query, {page: val})});
      }
    }
  }
};
</script>

<template lang="pug">
.polls-panel
  loading(v-if="!group")
  div(v-if="group")
    v-layout.py-2(align-center wrap)
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            span(v-if="$route.query.status == 'active'" v-t="'polls_panel.open'")
            span(v-if="$route.query.status == 'closed'" v-t="'polls_panel.closed'")
            span(v-if="$route.query.status == 'vote'" v-t="'polls_panel.need_vote'")
            span(v-if="!$route.query.status" v-t="'polls_panel.any_status'")
            common-icon(name="mdi-menu-down")
        v-list(dense)
          v-list-item(:to="mergeQuery({status: null })" v-t="'polls_panel.any_status'")
          v-list-item(:to="mergeQuery({status: 'active'})" v-t="'polls_panel.open'")
          v-list-item(:to="mergeQuery({status: 'closed'})" v-t="'polls_panel.closed'")
          v-list-item(:to="mergeQuery({status: 'vote'})" v-t="'polls_panel.need_vote'")
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            span(v-if="$route.query.poll_type" v-t="'poll_types.'+$route.query.poll_type")
            span(v-if="!$route.query.poll_type" v-t="'polls_panel.any_type'")
            common-icon(name="mdi-menu-down")
        v-list(dense)
          v-list-item(:to="mergeQuery({poll_type: null})" )
            v-list-item-title(v-t="'polls_panel.any_type'")
          v-list-item(
            v-for="pollType in Object.keys(pollTypes)"
            :key="pollType"
            :to="mergeQuery({poll_type: pollType})"
          )
            v-list-item-title(v-t="'poll_types.'+pollType")
      v-text-field.mr-2(
        clearable
        hide-details
        solo
        v-model="dummyQuery"
        @click="openSearchModal"
        @change="openSearchModal"
        @keyup.enter="openSearchModal"
        @click:append="openSearchModal"
        :placeholder="$t('navbar.search_polls', {name: group.name})"
        append-icon="mdi-magnify")
      v-btn.polls-panel__new-poll-button(
        :to="'/p/new?group_id='+group.id"
        color='primary'
        v-if='canStartPoll'
        v-t="'sidebar.start_decision'")
    v-card(outlined)
      div(v-if="loader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        v-list(two-line avatar v-if='polls.length && loader.pageWindow[page]')
          poll-common-preview(
            :poll='poll'
            v-for='poll in polls'
            :key='poll.id'
            :display-group-name="poll.groupId != group.id")
        p.pa-4.text-center(v-if='polls.length == 0 && !loader.loading' v-t="'polls_panel.no_polls'")
        loading(v-if="loader.loading")
        v-pagination(v-model="page" :length="totalPages" :total-visible="7" :disabled="totalPages == 1")

</template>
