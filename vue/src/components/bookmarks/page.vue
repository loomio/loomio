<script setup lang="js">
import { ref, onMounted } from 'vue';
import { orderBy } from 'lodash-es';

import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { watchRecords } = useWatchRecords();

const bookmarks = ref([]);
const loading = ref(true);

const findRecords = () => {
  bookmarks.value = orderBy(
    Records.bookmarks.find({userId: Session.userId, discardedAt: null}),
    ['createdAt'],
    ['desc']
  );
};

const remove = (bookmark) => {
  bookmark.destroy().then(() => Flash.success('bookmarks.removed'));
};

watchRecords({
  collections: ['bookmarks'],
  query: () => findRecords()
});

onMounted(() => {
  EventBus.$emit('currentComponent', {
    titleKey: 'bookmarks.bookmarks',
    page: 'bookmarksPage'
  });

  Records.bookmarks.fetch({}).finally(() => {
    loading.value = false;
    findRecords();
  });
});

const titleVisible = (visible) => {
  EventBus.$emit('content-title-visible', visible);
};
</script>

<template lang="pug">
v-main
  v-container.bookmarks-page.max-width-1024.px-0.px-sm-3
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'bookmarks.bookmarks'")

    section.bookmarks-page__loading(v-if='loading && bookmarks.length == 0')
      v-card.mb-2
        v-list(lines="two")
          loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index')

    template(v-else)
      v-card.mb-2(v-if='bookmarks.length > 0')
        v-list(lines="two")
          v-list-item(
            v-for="bookmark in bookmarks"
            :key="bookmark.id"
            :to="bookmark.url"
          )
            template(v-slot:prepend)
              common-icon(:name="bookmark.icon()")
            v-list-item-title {{ bookmark.title }}
            v-list-item-subtitle {{ $t('bookmarks.subtitle', {type: bookmark.typeLabel(), name: bookmark.authorName}) }}
            template(v-slot:append)
              v-btn(
                icon
                variant="text"
                :title="$t('action_dock.remove_bookmark')"
                @click.prevent.stop="remove(bookmark)"
              )
                common-icon(name="mdi-bookmark-remove-outline")

      v-alert.mb-2(v-else type="info" variant="tonal" :title="$t('bookmarks.empty')")
        span(v-t="'bookmarks.empty_help'")
</template>
