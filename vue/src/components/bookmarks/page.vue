<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { intersection, orderBy, uniq } from 'lodash-es';

import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { useBookmarks } from '@/composables/useBookmarks';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';

const { embedded } = defineProps({
  embedded: { type: Boolean, default: false }
});

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const { loadBookmarks } = useBookmarks();
const isLoading = ref(true);

const group = computed(() => (
  route.params.key ? Records.groups.fuzzyFind(route.params.key) : null
));

const subgroupsFilter = computed({
  get: () => (group.value && group.value.subgroupsCount > 0 && ['mine', 'all'].includes(route.query?.subgroups) ? route.query.subgroups : null),
  set: (val) => {
    const query = { ...route.query };
    if (!val) { delete query.subgroups; } else { query.subgroups = val; }
    router.replace({ query });
  }
});

const allowedGroupIds = computed(() => {
  if (!group.value) { return null; }
  if (subgroupsFilter.value === 'all') { return group.value.organisationIds(); }
  if (subgroupsFilter.value === 'mine') {
    return uniq([group.value.id].concat(intersection(group.value.organisationIds(), Session.user().groupIds())));
  }
  return [group.value.id];
});

const bookmarks = computed(() => {
  const all = Records.bookmarks.find({userId: Session.userId, discardedAt: null});
  const filtered = allowedGroupIds.value
    ? all.filter(b => allowedGroupIds.value.includes(b.groupId))
    : all;
  return orderBy(filtered, ['createdAt'], ['desc']);
});

const remove = (bookmark) => {
  bookmark.destroy().then(() => Flash.success('bookmarks.removed'));
};

onMounted(() => {
  if (!embedded && !group.value) {
    EventBus.$emit('currentComponent', {
      titleKey: 'bookmarks.bookmarks',
      page: 'bookmarksPage'
    });
  }

  loadBookmarks().finally(() => {
    isLoading.value = false;
  });
});

const titleVisible = (visible) => {
  EventBus.$emit('content-title-visible', visible);
};
</script>

<template lang="pug">
component(:is="embedded ? 'div' : 'v-main'")
  component(:is="embedded ? 'div' : 'v-container'" :class="embedded ? 'bookmarks-page pt-2' : 'bookmarks-page max-width-1024 px-2 px-sm-4'")
    template(v-if="!embedded")
      h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}") {{ t('dashboard_page.dashboard') }}
      dashboard-cards

    .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2(v-if="group")
      subgroups-filter-menu(:group="group" :selected="subgroupsFilter" @select="subgroupsFilter = $event")

    v-card.mb-2(v-if='isLoading && bookmarks.length == 0' variant="flat")
      loading

    template(v-else)
      v-card.mb-2(v-if='bookmarks.length > 0')
        v-list(lines="two")
          v-list-item.bookmarks-page__bookmark(
            v-for="bookmark in bookmarks"
            :key="bookmark.id"
            :to="bookmark.url"
          )
            template(v-slot:prepend)
              common-icon(:name="bookmark.icon()")
            v-list-item-title {{ bookmark.title }}
            v-list-item-subtitle {{ $t('bookmarks.subtitle', {type: bookmark.typeLabel(), name: bookmark.authorName}) }}
            template(v-slot:append)
              v-btn.bookmarks-page__remove(
                icon
                variant="text"
                :title="$t('action_dock.remove_bookmark')"
                @click.prevent.stop="remove(bookmark)"
              )
                common-icon(name="mdi-bookmark-remove-outline")

      v-alert.mb-2(v-else type="info" variant="tonal" :title="t('bookmarks.empty')")
        span {{ t('bookmarks.empty_help') }}
</template>
