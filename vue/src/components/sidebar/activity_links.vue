<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';

const { unread = 0, votes = 0, basePath, includeSubgroupsUnread = false, includeSubgroupsVotes = false } = defineProps({
  unread: { type: Number, default: 0 },
  votes: { type: Number, default: 0 },
  basePath: { type: String, required: true },
  includeSubgroupsUnread: { type: Boolean, default: false },
  includeSubgroupsVotes: { type: Boolean, default: false }
});

const { t } = useI18n();
const router = useRouter();

const cleanBasePath = computed(() => basePath.replace(/\/+$/, ''));
const unreadHref = computed(() => `${cleanBasePath.value}?unread=1${includeSubgroupsUnread ? '&subgroups=mine' : ''}`);
const votesHref = computed(() => `${cleanBasePath.value}/polls?status=vote${includeSubgroupsVotes ? '&subgroups=mine' : ''}`);

function go(path) {
  router.push(path);
}
</script>

<template lang="pug">
v-list-item-subtitle.text-caption(v-if="unread > 0 || votes > 0")
  a.sidebar__activity-link.text-decoration-none.underline-on-hover(
    v-if="unread > 0"
    :href="unreadHref"
    @click.prevent.stop="go(unreadHref)"
  ) {{ t('dashboard_cards.unread_count', { count: unread }) }}
  span.mx-1(v-if="unread > 0 && votes > 0") ·
  a.sidebar__activity-link.text-decoration-none.underline-on-hover(
    v-if="votes > 0"
    :href="votesHref"
    @click.prevent.stop="go(votesHref)"
  ) {{ t('sidebar.votes_count', { count: votes }, votes) }}
</template>

<style scoped>
.sidebar__activity-link {
  color: inherit;
}
</style>
