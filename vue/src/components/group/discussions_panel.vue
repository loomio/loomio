<script lang="js">
import Records            from '@/shared/services/records';
import AbilityService     from '@/shared/services/ability_service';
import EventBus           from '@/shared/services/event_bus';
import RecordLoader       from '@/shared/services/record_loader';
import PageLoader         from '@/shared/services/page_loader';
import DiscussionService      from '@/shared/services/discussion_service';
import { debounce, orderBy, intersection, concat, uniq } from 'lodash-es';
import Session from '@/shared/services/session';
import { mdiMagnify } from '@mdi/js';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default
{
  mixins: [WatchRecords, UrlFor],
  created() {
    this.watchRecords({
      key: this.$route.params.key,
      collections: ['discussions', 'groups', 'memberships'],
      query: this.query
    });

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
      discussions: [],
      loader: null,
      groupIds: [],
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

    hardRefresh() {
      Records.groups.remote.fetchById(this.$route.params.key).then(this.refresh);
    },

    refresh() {
      Records.groups.findOrFetch(this.$route.params.key).then(group => {
        this.group = group;
        this.isMember = !!Session.user().membershipFor(this.group);

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
      });
    },

    query() {
      if (!this.group) { return }
      this.groupIds = (() => { switch (this.$route.query.subgroups || 'mine') {
        case 'mine': return uniq(concat(intersection(this.group.organisationIds(), Session.user().groupIds()), this.group.id));
        case 'all': return this.group.organisationIds();
        default: return [this.group.id];
      } })();

      this.discussions = DiscussionService.groupDiscussionsQuery(this.group, this.groupIds, this.$route.query.t, this.$route.query.tag, this.page, this.loader);
      EventBus.$emit('currentComponent', {
        page: 'groupPage',
        title: this.group.name,
        group: this.group,
        discussions: this.discussions,
        discussionsGroup: this.group,
        search: {
          placeholder: this.$t('navbar.search_discussions_in_group', {name: this.group.parentOrSelf().name})
        }
      });
    },

    fetch() {
      this.loader.fetch(this.page).then(this.query);
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
    '$route.params': 'refresh',
    '$route.query': 'refresh',
    'page'() {
      this.fetch();
      this.query();
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

    groupTags() {
      return this.group && this.group.tags().filter(tag => tag.taggingsCount > 0);
    },

    loading() {
      return this.loader.loading;
    },

    noThreads() {
      return !this.loading && this.discussions.length === 0
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

<template lang="pug">
div.discussions-panel(v-if="group")
  .d-flex.align-center.flex-wrap.pt-4.pb-2
    v-menu
      template(v-slot:activator="{ props }")
        v-btn.discussions-panel__filters.mr-2.text-transform-none.text-medium-emphasis(v-bind="props" variant="tonal")
          span(v-t="{path: filterName($route.query.t), args: {count: unreadCount}}")
          common-icon(name="mdi-menu-down")
      v-list
        v-list-item.discussions-panel__filters-open(@click="routeQuery({t: null})")
          v-list-item-title(v-t="'discussions_panel.open'")
        v-list-item.discussions-panel__filters-all(@click="routeQuery({t: 'all'})")
          v-list-item-title(v-t="'discussions_panel.all'")
        v-list-item.discussions-panel__filters-closed(@click="routeQuery({t: 'closed'})")
          v-list-item-title(v-t="'discussions_panel.closed'")
        v-list-item.discussions-panel__filters-unread(@click="routeQuery({t: 'unread'})")
          v-list-item-title(v-t="{path: 'discussions_panel.unread', args: { count: unreadCount }}")

    v-menu(offset-y)
      template(v-slot:activator="{ props }")
        v-btn.mr-2.text-transform-none.text-medium-emphasis(v-bind="props" variant="tonal")
          span(v-if="$route.query.tag") {{$route.query.tag}}
          span(v-else v-t="'loomio_tags.tags'")
          common-icon(name="mdi-menu-down")
      v-sheet.pa-1.max-width-800
        tags-display(:tags="group.tagNames()" :group="group" :show-counts="!!group.parentId" :show-org-counts="!group.parentId")
    v-btn.text-transform-none.text-medium-emphasis(
      variant="tonal"
      @click="openSearchModal"
    )
      common-icon.mr-1(name="mdiMagnify")
      span(v-t="'common.action.search'")
    v-spacer
    v-btn.discussions-panel__new-thread-button(
      variant="elevated"
      v-if='canStartThread'
      :to="'/thread_templates/?group_id='+group.id"
      color='primary'
    )
      span(v-t="'discussions_panel.new_discussion'")

  v-alert(color="info" variant="tonal" v-if="isMember && noThreads")
    v-card-title(v-t="'discussions_panel.welcome_to_your_new_group'")
    v-card-text
      p(v-t="'discussions_panel.lets_start_a_discussion'")

  v-card.discussions-panel(v-else)
    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      .discussions-panel__content
        .discussions-panel__list--empty.pa-4(v-if='noThreads')
          p.text-center(v-if='canViewPrivateContent' v-t="'group_page.no_discussions_here'")
          p.text-center(v-if='!canViewPrivateContent' v-t="'group_page.private_discussions'")
        .discussions-panel__list.thread-preview-collection__container(v-if="discussions.length")
          v-list.thread-previews(lines="two")
            thread-preview(
              v-for="thread in discussions"
              :show-group-name="thread.groupId != group.id"
              :key="thread.id"
              :thread="thread"
              group-page
            )

        loading(v-if="loading && discussions.length == 0")

        v-pagination(v-model="page" :length="totalPages" :disabled="totalPages == 1")
        .d-flex.justify-center
          router-link.discussions-panel__view-closed-threads.text-center.pa-1(:to="'?t=closed'" v-if="suggestClosedThreads" v-t="'group_page.view_closed_discussions'")

</template>

<style lang="sass">
.overflow-x-auto
  overflow-x: auto
</style>
