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
  group.discussionPrivacyOptions === 'public_only' &&
  !group.currentUserFollowed
);

const showFollowButton = computed(() => group.currentUserFollowed || canFollow.value);

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
v-list-item.group-follow-button.px-0(
  v-if="showFollowButton"
  density="compact"
)
  v-list-item-title {{ t('group_follow.follow') }}
  v-list-item-subtitle.text-wrap {{ t('change_volume_form.catch_up_only_description', { context: t('change_volume_form.context.group') }) }}
  template(#append)
    v-switch(
      :model-value="group.currentUserFollowed"
      :aria-label="t('group_follow.follow')"
      color="primary"
      density="compact"
      hide-details
      inset
      :loading="processing"
      :disabled="processing"
      @update:model-value="toggleFollow"
    )
</template>
