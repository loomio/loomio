<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';

const { group } = defineProps({
  group: { type: Object, required: true }
});

const { t } = useI18n();
const processing = ref(false);

const canFollow = computed(() =>
  Session.isSignedIn() &&
  Session.user().emailVerified &&
  !Session.user().membershipFor(group) &&
  group.discussionPrivacyOptions === 'public_only'
);

const toggleFollow = () => {
  processing.value = true;
  const wasFollowing = group.currentUserFollowed;
  const request = wasFollowing ? Records.groups.unfollow(group) : Records.groups.follow(group);
  request
    .then(() => Flash.success(wasFollowing ? 'group_follow.unfollowed' : 'group_follow.followed'))
    .finally(() => { processing.value = false; });
};
</script>

<template lang="pug">
v-btn.group-follow-button.my-4(
  v-if="canFollow"
  variant="tonal"
  color="primary"
  :loading="processing"
  :prepend-icon="group.currentUserFollowed ? 'mdi-email-check-outline' : 'mdi-email-plus-outline'"
  @click="toggleFollow"
) {{ t(group.currentUserFollowed ? 'group_follow.unfollow' : 'group_follow.follow') }}
</template>
