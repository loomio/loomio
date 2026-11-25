<script lang="js">
import Records            from '@/shared/services/records';
import GroupAbility from '@/shared/abilities/group_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import EventBus           from '@/shared/services/event_bus';
import PageLoader         from '@/shared/services/page_loader';
import Session from '@/shared/services/session';
import { mdiMagnify } from '@mdi/js';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';
import TagsFilterMenu from '@/components/tags/filter_menu';
import UrlFor from '@/mixins/url_for';

export default
{
  components: { TagsFilterMenu },
  mixins: [UrlFor],
  props: {
    dashboard: { type: Boolean, default: false }
  },
  created() {
    this.refresh();
    EventBus.$on('signedIn', this.hardRefresh);
    EventBus.$on('joinedGroup', this.hardRefresh);
  },

  beforeDestroy() {
    EventBus.$off('signedIn', this.hardRefresh);
    EventBus.$off('joinedGroup', this.hardRefresh);
  },

  data() {
    return {
      group: null,
      loader: null,
      isMember: false,
      per: 25,
      dummyQuery: null,
      mdiMagnify
    };
  },

  methods: {
    routeQuery(o) {
      this.$router.replace(this.mergeQuery(o));
    },

    selectTag(tag) {
      this.routeQuery({tag, page: null});
    },

    toggleSubgroups() {
      this.routeQuery({ subgroups: this.includeSubgroups ? null : 'mine', page: null });
    },

    hardRefresh() {
      if (this.dashboard) {
        this.refresh();
      } else {
        Records.groups.remote.fetchById(this.$route.params.key).then(this.refresh);
      }
    },

    refresh() {
      if (this.dashboard) {
        this.group = null;
        this.isMember = false;
        this.loader = new PageLoader({
          path: 'topics',
          order: 'lastActivityAt',
          params: {
            filter: ['all', 'direct'].includes(this.$route.query.t) ? undefined : (this.$route.query.t || 'unlocked'),
            unread: this.$route.query.t === 'unread' ? 1 : undefined,
            direct: this.$route.query.t === 'direct' ? 1 : undefined,
            per: this.per
          }
        });
        this.fetch();
        return;
      }

      // GroupPage loads the group before mounting this panel.
      const group = Records.groups.fuzzyFind(this.$route.params.key);
      this.group = group;
      this.isMember = !!Session.user().membershipFor(this.group);

      this.loader = new PageLoader({
        path: 'topics',
        order: 'lastActivityAt',
        params: {
          group_id: this.group.id,
          subgroups: this.includeSubgroups ? 'mine' : undefined,
          filter: this.$route.query.t === 'all' ? undefined : (this.$route.query.t || 'unlocked'),
          tags: this.$route.query.tag,
          per: this.per
        }
      });

      this.fetch();

      EventBus.$emit('currentComponent', {
        page: 'groupPage',
        title: this.group.name,
        group: this.group,
        search: {
          placeholder: this.$t('navbar.search_discussions_in_group', {name: this.group.parentOrSelf().name})
        }
      });
    },

    fetch() {
      this.loader.fetch(this.page);
    },

    filterName(filter) {
      switch (filter) {
        case 'unread': return 'discussions_panel.unread';
        case 'direct': return 'sidebar.direct_threads';
        case 'locked': return 'discussions_panel.locked';
        case 'all': return 'discussions_panel.all';
        default:
          return 'discussions_panel.unlocked';
      }
    },

    openSearchModal() {
      let initialOrgId = null;
      let initialGroupId = null;

      if (this.group) {
        if (this.group.isParent()) {
          initialOrgId = this.group.id;
        } else {
          initialOrgId = this.group.parentId;
          initialGroupId = this.group.id;
        }
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
      });
    }
  },

  watch: {
    '$route.query': 'refresh',
    '$route.params.key': 'refresh'
  },

  computed: {
    includeSubgroups() {
      return Boolean(this.group && this.group.subgroupsCount > 0 && this.$route.query.subgroups === 'mine');
    },

    noGroups() {
      return this.dashboard && Session.user().groups().length === 0;
    },

    topics() {
      if (!this.dashboard && !this.group) { return []; }

      let pinnedTopics = [];
      let chain;
      if (this.dashboard) {
        if (this.$route.query.t === 'direct') {
          chain = Records.topics.collection.chain().find({
            groupId: null,
            discardedAt: null
          }).simplesort('lastActivityAt', true);
        } else {
          const groupIds = Session.user().groupIds();
          chain = Records.topics.collection.chain().find({
            discardedAt: null,
            $or: [
              { groupId: { $in: groupIds } },
              { readerGuest: true }
            ]
          }).simplesort('lastActivityAt', true);
        }
      } else {
        const groupFilter = this.includeSubgroups ? { $in: this.group.organisationIds() } : this.group.id;
        if (this.page == 1 && !this.$route.query.tag && !['locked', 'unread'].includes(this.$route.query.t)) {
          pinnedTopics = Records.topics.collection.chain().find({
            groupId: groupFilter,
            discardedAt: null,
            pinnedAt: {$ne: null}
          }).simplesort('pinnedAt', true).data();
        }

        chain = Records.topics.collection.chain().find({
          groupId: groupFilter,
          discardedAt: null,
          id: {$nin: pinnedTopics.map(t => t.id)}
        }).simplesort('lastActivityAt', true);
      }

      switch (this.$route.query.t) {
        case 'unread':
          chain = chain.find({ lastActivityAt: { $gt: unreadCutoffDate() } }).where(topic => topic.isUnread());
          break;
        case 'locked':
          chain = chain.find({lockedAt: {$ne: null}});
          break;
        case 'all':
        case 'direct':
          break;
        default: // null or 'unlocked' — show only unlocked threads
          chain = chain.find({lockedAt: null});
          break;
      }

      if (this.$route.query.tag) {
        const tagName = this.$route.query.tag;
        chain = chain.where(topic => topic.tags.includes(tagName));
      }

      let topics = [];
      if (this.loader.pageWindow[this.page]) {
        if (this.page === 1) {
          chain = chain.find({lastActivityAt: {$gte: this.loader.pageWindow[this.page][0]}});
        } else {
          chain = chain.find({lastActivityAt: {$between: this.loader.pageWindow[this.page]}});
        }
        topics = chain.data();
      }
      return pinnedTopics.concat(topics);
    },

    page: {
      get() { return parseInt(this.$route.query.page) || 1; },
      set(val) {
        return this.$router.replace({query: Object.assign({}, this.$route.query, {page: val})});
      }
    },

    totalPages() {
      return Math.max(1, Math.ceil((this.loader.total || 0) / this.per));
    },

    loading() {
      return this.loader.loading;
    },

    noThreads() {
      return !this.loading && this.topics.length === 0
    },

    noThreadsMatchingFilters() {
      return !this.dashboard && this.noThreads && ((this.group.discussionsCount || 0) + (this.group.pollsCount || 0)) > 0;
    },

    canViewPrivateContent() {
      return this.dashboard || GroupAbility.canSeePrivateContent(this.group);
    },

    canStartThread() {
      return Boolean(this.group) && DiscussionAbility.canCreate(this.group);
    },

    isLoggedIn() {
      return Session.isSignedIn();
    },

    unreadCount() {
      const recentCutoff = unreadCutoffDate();
      return this.topics.filter(topic => topic.isUnread() && topic.lastActivityAt > recentCutoff).length;
    },

    suggestLockedThreads() {
      return !['locked', 'unread', 'all'].includes(String(this.$route.query.t)) &&
        this.group && this.loader &&
        this.group.discussionsCount > this.loader.total;
    }
  }
};

</script>

<template lang="pug">
div.discussions-panel(v-if="dashboard || group")
  .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
    v-menu
      template(v-slot:activator="{ props }")
        v-btn.discussions-panel__filters.text-medium-emphasis(v-bind="props" variant="tonal")
          span(v-t="{path: filterName($route.query.t), args: {count: unreadCount}}")
          common-icon(name="mdi-menu-down")
      v-list
        v-list-item.discussions-panel__filters-unlocked(@click="routeQuery({t: null})")
          v-list-item-title(v-t="'discussions_panel.unlocked'")
        v-list-item.discussions-panel__filters-all(@click="routeQuery({t: 'all'})")
          v-list-item-title(v-t="'discussions_panel.all'")
        v-list-item.discussions-panel__filters-locked(@click="routeQuery({t: 'locked'})")
          v-list-item-title(v-t="'discussions_panel.locked'")
        v-list-item.discussions-panel__filters-unread(@click="routeQuery({t: 'unread'})")
          v-list-item-title(v-t="{path: 'discussions_panel.unread', args: { count: unreadCount }}")
        v-list-item.discussions-panel__filters-direct(v-if="dashboard" @click="routeQuery({t: 'direct'})")
          v-list-item-title(v-t="'sidebar.direct_threads'")

    tags-filter-menu(v-if="group" :group="group" :selected-tag="$route.query.tag" @select="selectTag")
    v-btn.discussions-panel__subgroups-toggle(
      v-if="group && group.subgroupsCount > 0"
      variant="tonal"
      :color="includeSubgroups ? 'primary' : undefined"
      :class="{ 'text-medium-emphasis': !includeSubgroups }"
      @click="toggleSubgroups"
    ) {{ $t('group_cards.include_subgroups') }}
    v-btn.text-medium-emphasis(
      variant="tonal"
      @click="openSearchModal"
    )
      common-icon.mr-1(name="mdiMagnify")
      span(v-t="'common.action.search'")
    v-spacer
    v-btn.discussions-panel__new-topic-button(
      v-if="canStartThread"
      :to="'/discussion_templates/?group_id=' + group.id"
      variant="elevated"
      color="primary"
    )
      span {{ $t('discussions_panel.new_thread') }}

  v-alert(color="info" variant="tonal" v-if="noThreadsMatchingFilters")
    v-card-text
      p(v-t="'discussions_panel.no_threads_found_that_match_your_filters'")

  v-alert(color="info" variant="tonal" v-else-if="isMember && noThreads")
    v-card-title(v-t="'discussions_panel.welcome_to_your_new_group'")
    v-card-text
      p(v-t="'discussions_panel.lets_start_a_discussion'")

  v-card.discussions-panel(v-else variant="flat")
    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      .discussions-panel__content
        .discussions-panel__list--empty.pa-4(v-if='noThreads')
          template(v-if="dashboard")
            p.text-center(v-if="noGroups" v-html="$t('dashboard_page.no_groups.show_all')")
            p.text-center(v-else v-t="'dashboard_page.no_threads.show_all'")
          template(v-else)
            p.text-center(v-if='canViewPrivateContent' v-t="'group_page.no_discussions_here'")
            p.text-center(v-if='!canViewPrivateContent' v-t="'group_page.private_discussions'")
        .discussions-panel__list.topic-preview-collection__container(v-if="topics.length")
          v-list.topic-previews(lines="two")
            topic-preview(
              v-for="topic in topics"
              :show-group-name="dashboard || includeSubgroups"
              :key="topic.id"
              :topic="topic"
              :group-page="Boolean(group)"
            )

        loading(v-if="loading && topics.length == 0")

        v-pagination(v-model="page" :length="totalPages" :disabled="totalPages == 1")
        .d-flex.justify-center
          router-link.text-medium-emphasis.text-decoration-none.underline-on-hover.discussions-panel__view-locked-topics.text-center.pa-1(:to="'?t=locked'" v-if="suggestLockedThreads" v-t="'group_page.view_locked_discussions'")

</template>

<style>
.overflow-x-auto {
  overflow-x: auto;
}
</style>
