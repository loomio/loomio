<script lang="js">
import Records            from '@/shared/services/records';
import AbilityService     from '@/shared/services/ability_service';
import EventBus           from '@/shared/services/event_bus';
import RecordLoader       from '@/shared/services/record_loader';
import PageLoader         from '@/shared/services/page_loader';
import { debounce, orderBy, intersection, concat, uniq } from 'lodash-es';
import Session from '@/shared/services/session';

export default 
{
  created() {
    this.onQueryInput = debounce(val => {
      this.$router.replace(this.mergeQuery({q: val}));
    }
    , 1000);
    this.init();
    EventBus.$on('signedIn', this.init);
  },

  beforeDestroy() {
    EventBus.$off('signedIn', this.init);
  },

  data() {
    return {
      group: null,
      discussions: [],
      loader: null,
      groupIds: [],
      per: 25,
      dummyQuery: null
    };
  },

  methods: {
    routeQuery(o) {
      this.$router.replace(this.mergeQuery(o));
    },

    beforeDestroy() {
      EventBus.$off('joinedGroup');
    },

    init() {
      Records.groups.findOrFetch(this.$route.params.key).then(group => {
        this.group = group;

        EventBus.$emit('currentComponent', {
          page: 'groupPage',
          title: this.group.name,
          group: this.group,
          search: {
            placeholder: this.$t('navbar.search_threads', {name: this.group.parentOrSelf().name})
          }
        }
        );

        EventBus.$on('joinedGroup', group => this.fetch());

        this.refresh();

        this.watchRecords({
          key: this.group.id,
          collections: ['discussions', 'groups', 'memberships'],
          query: () => this.query()
        });
      });
    },

    refresh() {
      this.loader = new PageLoader({
        path: 'discussions',
        order: 'lastActivityAt',
        params: {
          group_id: this.group.id,
          exclude_types: 'group outcome poll',
          filter: this.$route.query.t,
          subgroups: this.$route.query.subgroups || 'mine',
          tags: this.$route.query.tag,
          per: this.per
        }
      });

      this.fetch();
      this.query();
    },

    query() {
      if (!this.group) { return; }
      this.publicGroupIds = this.group.publicOrganisationIds();

      this.groupIds = (() => { switch (this.$route.query.subgroups || 'mine') {
        case 'mine': return uniq(concat(intersection(this.group.organisationIds(), Session.user().groupIds()), this.publicGroupIds, this.group.id));
        case 'all': return this.group.organisationIds();
        default: return [this.group.id];
      } })();

      let chain = Records.discussions.collection.chain();
      chain = chain.find({discardedAt: null});
      chain = chain.find({groupId: {$in: this.groupIds}});

      switch (this.$route.query.t) {
        case 'unread':
          chain = chain.where(discussion => discussion.isUnread());
          break;
        case 'closed':
          chain = chain.find({closedAt: {$ne: null}});
          break;
        case 'templates':
          chain = chain.find({template: true});
          break;
        case 'all':
          true; // noop
          break;
        default:
          chain = chain.find({closedAt: null});
      }

      if (this.$route.query.tag) {
        const tag = Records.tags.find({groupId: this.group.parentOrSelf().id, name: this.$route.query.tag})[0];
        chain = chain.find({tagIds: {'$contains': tag.id}});
      }

      if (this.loader.pageWindow[this.page]) {
        if (this.page === 1) {
          chain = chain.find({lastActivityAt: {$gte: this.loader.pageWindow[this.page][0]}});
        } else {
          chain = chain.find({lastActivityAt: {$jbetween: this.loader.pageWindow[this.page]}});
        }
        return this.discussions = chain.simplesort('lastActivityAt', true).data();
      } else {
        return this.discussions = [];
      }
    },

    fetch() {
      this.loader.fetch(this.page).then( () => this.query());
    },

    filterName(filter) {
      switch (filter) {
        case 'unread': return 'discussions_panel.unread';
        case 'all': return 'discussions_panel.all';
        case 'closed': return 'discussions_panel.closed';
        case 'subscribed': return 'change_volume_form.simple.loud';
        default:
          return 'discussions_panel.open';
      }
    },

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
          initialOrgId,
          initialGroupId,
          initialQuery: this.dummyQuery
        }
      }
      );
    }
  },

  watch: {
    '$route.params': 'init',
    '$route.query': 'refresh',
    'page'() {
      this.fetch();
      return this.query();
    }
  },

  computed: {
    page: {
      get() { return parseInt(this.$route.query.page) || 1; },
      set(val) {
        return this.$router.replace({query: Object.assign({}, this.$route.query, {page: val})});
      }
    }, 

    totalPages() {
      return Math.ceil(parseFloat(this.loader.total) / parseFloat(this.per));
    },

    pinnedDiscussions() {
      return orderBy(this.discussions.filter(discussion => discussion.pinnedAt), ['pinnedAt'], ['desc']);
    },

    regularDiscussions() {
      return orderBy(this.discussions.filter(discussion => !discussion.pinnedAt), ['lastActivityAt'], ['desc']);
    },

    groupTags() {
      return this.group && this.group.tags().filter(tag => tag.taggingsCount > 0);
    },

    loading() {
      return this.loader.loading;
    },

    noThreads() {
      return !this.loading && (this.discussions.length === 0);
    },

    canViewPrivateContent() {
      return AbilityService.canViewPrivateContent(this.group);
    },

    canStartThread() {
      return AbilityService.canStartThread(this.group);
    },

    isLoggedIn() {
      return Session.isSignedIn();
    },

    unreadCount() {
      return this.discussions.filter(discussion => discussion.isUnread()).length;
    },

    suggestClosedThreads() {
      return ['undefined', 'open', 'unread'].includes(String(this.$route.query.t)) && this.group && this.group.closedDiscussionsCount;
    }
  }
};

</script>

<template>

<div class="discussions-panel" v-if="group">
  <v-layout class="py-3" align-center="align-center" wrap="wrap">
    <v-menu>
      <template v-slot:activator="{ on, attrs }">
        <v-btn class="mr-2 text-lowercase discussions-panel__filters" v-on="on" v-bind="attrs" text="text"><span v-t="{path: filterName($route.query.t), args: {count: unreadCount}}"></span>
          <common-icon name="mdi-menu-down"></common-icon>
        </v-btn>
      </template>
      <v-list>
        <v-list-item class="discussions-panel__filters-open" @click="routeQuery({t: null})">
          <v-list-item-title v-t="'discussions_panel.open'"></v-list-item-title>
        </v-list-item>
        <v-list-item class="discussions-panel__filters-all" @click="routeQuery({t: 'all'})">
          <v-list-item-title v-t="'discussions_panel.all'"></v-list-item-title>
        </v-list-item>
        <v-list-item class="discussions-panel__filters-closed" @click="routeQuery({t: 'closed'})">
          <v-list-item-title v-t="'discussions_panel.closed'"></v-list-item-title>
        </v-list-item>
        <v-list-item class="discussions-panel__filters-unread" @click="routeQuery({t: 'unread'})">
          <v-list-item-title v-t="{path: 'discussions_panel.unread', args: { count: unreadCount }}"></v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
    <v-menu offset-y="offset-y">
      <template v-slot:activator="{ on, attrs }">
        <v-btn class="mr-2 text-lowercase" v-on="on" v-bind="attrs" text="text"><span v-if="$route.query.tag">{{$route.query.tag}}</span><span v-else v-t="'loomio_tags.tags'"></span>
          <common-icon name="mdi-menu-down"></common-icon>
        </v-btn>
      </template>
      <v-sheet class="pa-1">
        <tags-display :tags="group.tagNames()" :group="group" :show-counts="!!group.parentId" :show-org-counts="!group.parentId"></tags-display>
      </v-sheet>
    </v-menu>
    <v-text-field class="mr-2 flex-grow-1" v-model="dummyQuery" clearable="clearable" solo="solo" hide-details="hide-details" @click="openSearchModal" @change="openSearchModal" @keyup.enter="openSearchModal" @click:append="openSearchModal" :placeholder="$t('navbar.search_threads', {name: group.name})" append-icon="mdi-magnify"></v-text-field>
    <v-btn class="discussions-panel__new-thread-button" v-if="canStartThread" v-t="'navbar.start_thread'" :to="'/thread_templates/?group_id='+group.id" color="primary"></v-btn>
  </v-layout>
  <v-alert color="info" text="text" outlined="outlined" v-if="noThreads">
    <v-card-title v-t="'discussions_panel.welcome_to_your_new_group'"></v-card-title>
    <p class="px-4" v-t="'discussions_panel.lets_start_a_thread'"></p>
  </v-alert>
  <v-card class="discussions-panel" v-else outlined="outlined">
    <div v-if="loader.status == 403">
      <p class="pa-4 text-center" v-t="'error_page.forbidden'"></p>
    </div>
    <div v-else>
      <div class="discussions-panel__content">
        <div class="discussions-panel__list thread-preview-collection__container" v-if="discussions.length">
          <v-list class="thread-previews" two-line="two-line">
            <thread-preview :show-group-name="groupIds.length > 1" v-for="thread in pinnedDiscussions" :key="thread.id" :thread="thread" group-page="group-page"></thread-preview>
            <thread-preview :show-group-name="groupIds.length > 1" v-for="thread in regularDiscussions" :key="thread.id" :thread="thread" group-page="group-page"></thread-preview>
          </v-list>
        </div>
        <loading v-if="loading && discussions.length == 0"></loading>
        <v-pagination v-model="page" :length="totalPages" :total-visible="7" :disabled="totalPages == 1"></v-pagination>
        <div class="d-flex justify-center">
          <router-link class="discussions-panel__view-closed-threads text-center pa-1" :to="'?t=closed'" v-if="suggestClosedThreads" v-t="'group_page.view_closed_threads'"></router-link>
        </div>
      </div>
    </div>
  </v-card>
</div>
</template>

<style lang="sass">
.overflow-x-auto
  overflow-x: auto
</style>
