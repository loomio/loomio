<script lang="js">
import Session           from '@/shared/services/session';
import Records           from '@/shared/services/records';
import EventBus          from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';
import GroupService    from '@/shared/services/group_service';
import GroupCards from '@/components/group/cards.vue';
import { pickBy } from 'lodash-es';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';

const SUBPAGE_SEGMENTS = new Set(['polls', 'members', 'files', 'membership_requests', 'emails', 'tags']);

export default
{
  components: { GroupCards },
  mixins: [UrlFor, FormatDate],
  data() {
    return {
      group: null,
      activeTab: '',
      groupFetchError: null
    };
  },

  created() {
    this.init();
    EventBus.$on('signedIn', this.init);
    EventBus.$on('joinedGroup', this.init);
  },

  beforeUnmount() {
    EventBus.$off('signedIn', this.init);
    EventBus.$off('joinedGroup', this.init);
  },

  watch: {
    '$route.params.key': 'init'
  },

  computed: {
    dockActions() {
      return pickBy(GroupService.actions(this.group), v => v.dock);
    },

    menuActions() {
      return pickBy(GroupService.actions(this.group), v => v.menu);
    },

    canEditGroup() {
      return GroupAbility.canUpdate(this.group);
    },

    isOverviewRoute() {
      const segments = (this.$route?.path || '').split('/').filter(Boolean);
      return !segments.some(segment => SUBPAGE_SEGMENTS.has(segment));
    },

    showPlanBanner() {
      if (!this.group) { return false; }
      const parent = typeof this.group.parentOrSelf === 'function' ? this.group.parentOrSelf() : this.group;
      const sub = (parent || this.group).subscription || {};
      const user = typeof Session.user === 'function' ? Session.user() : null;
      const handledByOnboardingCard = this.isOverviewRoute &&
        sub.plan === 'trial' &&
        typeof this.group.isEnabled === 'function' && this.group.isEnabled() &&
        user && typeof this.group.membersInclude === 'function' && this.group.membersInclude(user) &&
        (!sub.trial_extended_at || !user.hasExperienced('hideOnboarding'));
      return !handledByOnboardingCard;
    }
  },

  methods: {
    init() {
      this.group = null;
      Records.groups.findOrFetch(this.$route.params.key).then(group => {
        this.group = group;
        if (this.group.newHost) { window.location.host = this.group.newHost; }
      }).catch(error => {
        EventBus.$emit('pageError', error);
        if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
      });
    }
  }
};

</script>

<template lang="pug">
v-main
  loading(v-if="!group")
  v-container.group-page.max-width-1024.px-2.px-sm-4(v-if="group")
    div(style="position: relative")
      v-img(
        :src="group.coverUrl"
        style="border-radius: 8px"
        max-height="256"
        cover
        eager)

      //v-img.ma-2.d-none.d-sm-block.rounded(
      //  v-if="group.logoUrl"
      //  :src="group.logoUrl"
      //  style="border-radius: 8px; position: absolute; bottom: 0"
      //  height="96"
      //  width="96"
      //  eager)
      //v-img.ma-2.d-sm-none.rounded(
      //  v-if="group.logoUrl"
      //  :src="group.logoUrl"
      //  style="border-radius: 8px; position: absolute; bottom: 0"
      //  height="48"
      //  width="48"
      //  eager)
    .d-flex.align-center.justify-space-between.flex-wrap.ga-2.my-4
      h1.text-headline-large(tabindex="-1" v-intersect="{handler: titleVisible}")
        span(v-if="group && group.parentId")
          router-link.text-high-emphasis.text-decoration-none.underline-on-hover(:to="urlFor(group.parent())")
            plain-text(:model="group.parent()" field="name")
          space
          span.text-medium-emphasis.text--lighten-1 &gt;
          space
        plain-text.group-page__name(:model="group" field="name")
      action-dock.group-page__actions(
        :model='group'
        :actions='dockActions'
        :menu-icon="canEditGroup ? 'mdi-cog' : 'mdi-dots-horizontal'"
        :menu-name="canEditGroup ? $t('common.settings') : $t('action_dock.more')"
        :menu-icon-only="false"
        menu-show-icon
        :menu-actions='menuActions')
    plan-banner(v-if="showPlanBanner" :group="group")
    formatted-text.group-page__description(
      v-if="group"
      :model="group"
      field="description")
    link-previews(:model="group")
    join-group-button(:group='group')
    group-follow-button(:group='group')
    attachment-list(:attachments="group.attachments")
    group-cards(v-if="isOverviewRoute" :group="group")
    .mt-4(v-else)
      v-btn.group-page-discussions-tab(variant="text" :to="urlFor(group, null)")
        common-icon.mr-1(name="mdi-arrow-left")
        span {{ $t('group_page.discussions') }}
    v-divider.mt-2
    router-view
</template>
