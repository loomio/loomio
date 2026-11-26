<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { orderBy } from 'lodash-es';

import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { useBookmarks } from '@/composables/useBookmarks';

const { embedded } = defineProps({
  embedded: { type: Boolean, default: false }
});

const route = useRoute();
const { loadBookmarks } = useBookmarks();
const loading = ref(true);

const group = computed(() => (
  route.params.key ? Records.groups.fuzzyFind(route.params.key) : null
));

const bookmarks = computed(() => {
  const all = Records.bookmarks.find({userId: Session.userId, discardedAt: null});
  const filtered = group.value
    ? all.filter(b => b.groupId === group.value.id)
    : all;
  return orderBy(filtered, ['createdAt'], ['desc']);
});

const remove = (bookmark) => {
  bookmark.destroy().then(() => Flash.success('bookmarks.removed'));
};

onMounted(() => {
  if (!group.value) {
    EventBus.$emit('currentComponent', {
      titleKey: 'bookmarks.bookmarks',
      page: 'bookmarksPage'
    });
  }

  loadBookmarks().finally(() => {
    loading.value = false;
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
      h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_page.dashboard'")
      dashboard-cards

    section.bookmarks-page__loading(v-if='loading && bookmarks.length == 0')
      v-card.mb-2
        v-list(lines="two")
          loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index')

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

      v-alert.mb-2(v-else type="info" variant="tonal" :title="$t('bookmarks.empty')")
        span(v-t="'bookmarks.empty_help'")
</template>
