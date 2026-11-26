<script lang="js">
import Records            from '@/shared/services/records';
import GroupAbility from '@/shared/abilities/group_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import EventBus           from '@/shared/services/event_bus';
import PageLoader         from '@/shared/services/page_loader';
import Session from '@/shared/services/session';
import { mdiMagnify } from '@mdi/js';
import { intersection, uniq } from 'lodash-es';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';
import TagsFilterMenu from '@/components/tags/filter_menu';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import UrlFor from '@/mixins/url_for';

export default
{
  components: { TagsFilterMenu, SubgroupsFilterMenu },
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

    selectSubgroups(val) {
      this.routeQuery({ subgroups: val, page: null });
    },

    toggleUnread() {
      this.routeQuery({
        unread: this.isUnreadFilter ? null : '1',
        t: this.$route.query.t === 'unread' ? null : this.$route.query.t,
        page: null
      });
    },

    toggleDirect() {
      this.routeQuery({
        direct: this.isDirectFilter ? null : '1',
        t: this.$route.query.t === 'direct' ? null : this.$route.query.t,
        page: null
      });
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
            filter: this.lockFilter === 'all' ? undefined : (this.lockFilter || 'unlocked'),
            unread: this.isUnreadFilter ? 1 : undefined,
            last_activity_gte: this.isUnreadFilter ? unreadCutoffDate().toISOString() : undefined,
            direct: this.isDirectFilter ? 1 : undefined,
            tags: this.$route.query.tag,
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
          subgroups: this.subgroupsFilter || undefined,
          filter: this.lockFilter === 'all' ? undefined : (this.lockFilter || 'unlocked'),
          unread: this.isUnreadFilter ? 1 : undefined,
          last_activity_gte: this.isUnreadFilter ? unreadCutoffDate().toISOString() : undefined,
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
    lockFilter() {
      return ['all', 'locked'].includes(this.$route.query.t) ? this.$route.query.t : null;
    },

    isUnreadFilter() {
      return Boolean(this.$route.query.unread) || this.$route.query.t === 'unread';
    },

    isDirectFilter() {
      return this.dashboard && (Boolean(this.$route.query.direct) || this.$route.query.t === 'direct');
    },

    subgroupsFilter() {
      if (!this.group || !(this.group.subgroupsCount > 0)) { return null; }
      return ['mine', 'all'].includes(this.$route.query.subgroups) ? this.$route.query.subgroups : null;
    },

    includeSubgroups() {
      return Boolean(this.subgroupsFilter);
    },

    groupFilter() {
      if (!this.group) { return null; }
      if (this.subgroupsFilter === 'all') { return { $in: this.group.organisationIds() }; }
      if (this.subgroupsFilter === 'mine') {
        return { $in: uniq([this.group.id].concat(intersection(this.group.organisationIds(), Session.user().groupIds()))) };
      }
      return this.group.id;
    },

    noGroups() {
      return this.dashboard && Session.user().groups().length === 0;
    },

    topics() {
      if (!this.dashboard && !this.group) { return []; }

      let pinnedTopics = [];
      let chain;
      if (this.dashboard) {
        if (this.isDirectFilter) {
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
        const groupFilter = this.groupFilter;
        if (this.page == 1 && !this.$route.query.tag && !this.isUnreadFilter && this.lockFilter !== 'locked') {
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

      switch (this.lockFilter) {
        case 'locked':
          chain = chain.find({lockedAt: {$ne: null}});
          break;
        case 'all':
          break;
        default: // null — show only unlocked threads
          chain = chain.find({lockedAt: null});
          break;
      }

      if (this.isUnreadFilter) {
        chain = chain.find({ lastActivityAt: { $gt: unreadCutoffDate() } }).where(topic => topic.isUnread());
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

    hasActiveFilters() {
      return Boolean(this.isUnreadFilter || this.isDirectFilter || this.lockFilter || this.$route.query.tag);
    },

    emptyFilterMessage() {
      const qualifiers = [];
      if (this.isUnreadFilter) { qualifiers.push(this.$t('group_cards.filter_qualifier_unread')); }
      if (this.isDirectFilter) { qualifiers.push(this.$t('group_cards.filter_qualifier_direct')); }
      if (this.lockFilter === 'locked') {
        qualifiers.push(this.$t('group_cards.filter_qualifier_locked'));
      } else if (this.lockFilter !== 'all') {
        qualifiers.push(this.$t('group_cards.filter_qualifier_unlocked'));
      }
      const filters = qualifiers.join(', ');
      if (this.$route.query.tag) {
        return filters
          ? this.$t('group_cards.no_filtered_threads_with_tag', { filters, tag: this.$route.query.tag })
          : this.$t('group_cards.no_threads_with_tag', { tag: this.$route.query.tag });
      }
      return filters
        ? this.$t('group_cards.no_filtered_threads', { filters })
        : this.$t('discussions_panel.no_threads_found_that_match_your_filters');
    },

    noThreadsMatchingFilters() {
      return !this.dashboard && this.noThreads && (this.hasActiveFilters || ((this.group.discussionsCount || 0) + (this.group.pollsCount || 0)) > 0);
    },

    canViewPrivateContent() {
      return this.dashboard || GroupAbility.canSeePrivateContent(this.group);
    },

    canStartThread() {
      if (this.group) { return DiscussionAbility.canCreate(this.group); }
      return this.dashboard && this.isDirectFilter && Session.isSignedIn();
    },

    newThreadRoute() {
      return this.group ? `/discussion_templates/?group_id=${this.group.id}` : '/discussion_templates/';
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
    subgroups-filter-menu(v-if="group" :group="group" :selected="subgroupsFilter" @select="selectSubgroups")
    v-menu
      template(v-slot:activator="{ props }")
        v-btn.discussions-panel__filters.text-medium-emphasis(v-bind="props" variant="tonal")
          span(v-t="filterName(lockFilter)")
          common-icon(name="mdi-menu-down")
      v-list(density="compact")
        v-list-item.discussions-panel__filters-all(:active="lockFilter === 'all'" @click="routeQuery({t: 'all'})")
          v-list-item-title(v-t="'discussions_panel.all'")
        v-list-item.discussions-panel__filters-locked(:active="lockFilter === 'locked'" @click="routeQuery({t: 'locked'})")
          v-list-item-title(v-t="'discussions_panel.locked'")
        v-list-item.discussions-panel__filters-unlocked(:active="!lockFilter" @click="routeQuery({t: null})")
          v-list-item-title(v-t="'discussions_panel.unlocked'")

    v-btn.discussions-panel__unread-toggle(
      v-if="isLoggedIn"
      variant="tonal"
      :color="isUnreadFilter ? 'primary' : undefined"
      :class="{ 'text-medium-emphasis': !isUnreadFilter }"
      :aria-pressed="isUnreadFilter"
      @click="toggleUnread"
    )
      common-icon.mr-1(v-if="isUnreadFilter" name="mdi-check" size="small" color="currentColor")
      span(v-t="'common.unread'")

    v-btn.discussions-panel__direct-toggle(
      v-if="dashboard"
      variant="tonal"
      :color="isDirectFilter ? 'primary' : undefined"
      :class="{ 'text-medium-emphasis': !isDirectFilter }"
      :aria-pressed="isDirectFilter"
      @click="toggleDirect"
    )
      common-icon.mr-1(v-if="isDirectFilter" name="mdi-check" size="small" color="currentColor")
      span(v-t="'dashboard_cards.direct'")

    tags-filter-menu(:group="group" :selected-tag="$route.query.tag" @select="selectTag")
    v-btn.text-medium-emphasis(
      variant="tonal"
      @click="openSearchModal"
    )
      common-icon.mr-1(name="mdiMagnify")
      span(v-t="'common.action.search'")
    v-spacer
    v-btn.discussions-panel__new-topic-button(
      v-if="canStartThread"
      :to="newThreadRoute"
      variant="elevated"
      color="primary"
    )
      span {{ $t('discussions_panel.new_thread') }}

  v-alert(color="info" variant="tonal" v-if="noThreadsMatchingFilters")
    v-card-text
      p {{ emptyFilterMessage }}

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
            p.text-center(v-else-if="hasActiveFilters") {{ emptyFilterMessage }}
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

        v-pagination(v-if="!noThreads && totalPages > 1" v-model="page" :length="totalPages")
        .d-flex.justify-center
          router-link.text-medium-emphasis.text-decoration-none.underline-on-hover.discussions-panel__view-locked-topics.text-center.pa-1(:to="'?t=locked'" v-if="suggestLockedThreads" v-t="'group_page.view_locked_discussions'")

</template>

<style>
.overflow-x-auto {
  overflow-x: auto;
}
</style>
