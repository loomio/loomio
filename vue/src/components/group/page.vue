<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { useRoute } from 'vue-router';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import GroupService from '@/shared/services/group_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { pickBy } from 'lodash-es';

const route = useRoute();
const group = ref(null);
const groupLoadVersion = ref(0);
const activeTab = ref('');
let groupLoadRequestId = 0;

const dockActions = computed(() => pickBy(GroupService.actions(group.value), action => action.dock));
const menuActions = computed(() => pickBy(GroupService.actions(group.value), action => action.menu));
const canEditGroup = computed(() => AbilityService.canEditGroup(group.value));
const tabs = computed(() => {
  if (!group.value) return [];

  return [
    {id: 0, name: 'discussions', route: LmoUrlService.route({model: group.value})},
    {id: 1, name: 'polls', route: LmoUrlService.route({model: group.value, action: 'polls'})},
    {id: 2, name: 'members', route: LmoUrlService.route({model: group.value, action: 'members'})},
    {id: 4, name: 'files', route: LmoUrlService.route({model: group.value, action: 'files'})},
  ];
});

function routeFor(model) {
  return LmoUrlService.route({model});
}

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

// Only the latest authorization response may populate the page. Successful
// refreshes remount the routed panel so it initializes from the verified group.
async function loadGroup() {
  const requestId = ++groupLoadRequestId;
  group.value = null;

  try {
    const loadedGroup = await Records.groups.findOrFetch(route.params.key);
    if (requestId !== groupLoadRequestId) return;

    group.value = loadedGroup;
    groupLoadVersion.value += 1;
    if (loadedGroup.newHost) window.location.host = loadedGroup.newHost;
  } catch (error) {
    if (requestId !== groupLoadRequestId) return;

    EventBus.$emit('pageError', error);
    if (error.status === 403 && !Session.isSignedIn()) EventBus.$emit('openAuthModal');
  }
}

watch(() => route.params.key, loadGroup, {immediate: true});

onMounted(() => {
  EventBus.$on('signedIn', loadGroup);
  EventBus.$on('joinedGroup', loadGroup);
});

onBeforeUnmount(() => {
  groupLoadRequestId += 1;
  EventBus.$off('signedIn', loadGroup);
  EventBus.$off('joinedGroup', loadGroup);
});
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
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}")
      span(v-if="group && group.parentId")
        router-link.text-high-emphasis.text-decoration-none.underline-on-hover(:to="routeFor(group.parent())")
          plain-text(:model="group.parent()" field="name")
        space
        span.text-medium-emphasis.text--lighten-1 &gt;
        space
      plain-text.group-page__name.mr-4(:model="group" field="name")
    plan-banner(:group="group")
    formatted-text.group-page__description(
      v-if="group"
      :model="group"
      field="description")
    link-previews(:model="group")
    action-dock(
      :model='group'
      :actions='dockActions'
      :menu-icon="canEditGroup ? 'mdi-cog' : 'mdi-dots-horizontal'"
      :menu-name="canEditGroup ? $t('common.settings') : $t('action_dock.more')"
      :menu-icon-only="false"
      menu-show-icon
      :menu-actions='menuActions')
    join-group-button(:group='group')
    attachment-list(:attachments="group.attachments")
    v-divider.mt-4
    v-tabs(
      v-model="activeTab"
      background-color="transparent"
      center-active
      grow
    )
      v-tab(
        v-for="tab of tabs"
        :key="tab.id"
        :to="tab.route"
        :class="'group-page-' + tab.name + '-tab' "
      )
        //- common-icon(name="mdi-comment-multiple")
        span(v-t="'group_page.'+tab.name")
    router-view(v-slot="{ Component }")
      component(:is="Component" :key="groupLoadVersion" :group="group")
</template>

<style lang="css">
.action-dock__button--email_group {
  text-transform: none !important;
}
</style>
