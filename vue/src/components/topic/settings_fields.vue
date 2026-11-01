<script setup>
import { useI18n } from 'vue-i18n';

const { model, kind } = defineProps({
  model: { type: Object, required: true },
  kind: { type: String, required: true, validator: value => ['discussion', 'poll'].includes(value) }
});
const { t } = useI18n();
</script>

<template>
  <div class="topic-settings-fields">
    <v-checkbox
      v-if="kind === 'discussion'"
      v-model="model.pollsOneAtATime"
      class="topic-settings__single-poll"
      :label="t('thread_arrangement_form.only_one_poll_at_a_time')"
      hide-details
    />
    <template v-else>
      <v-checkbox
        v-model="model.allowComments"
        class="topic-settings__comments"
        :label="t('thread_arrangement_form.allow_comments')"
        :hint="t('thread_arrangement_form.allow_comments_description')"
        persistent-hint
      />
      <v-checkbox
        v-model="model.allowReactions"
        class="topic-settings__reactions"
        :label="t('thread_arrangement_form.allow_reactions')"
        :hint="t('thread_arrangement_form.allow_reactions_description')"
        persistent-hint
      />
    </template>
    <v-checkbox
      v-model="model.attachmentsAdminOnly"
      class="topic-settings__attachments-admin-only"
      :label="t('thread_arrangement_form.only_admins_can_add_attachments')"
      hide-details
    />
    <div class="text-body-large mt-4 pb-2">{{ t('thread_arrangement_form.comment_length_max') }}</div>
    <div class="text-body-medium pb-4 text-medium-emphasis">{{ t('thread_arrangement_form.comment_length_max_description') }}</div>
    <v-number-input
      v-model="model.commentLengthMax"
      class="topic-settings__comment-length"
      :aria-label="t('thread_arrangement_form.comment_length_max')"
      :hint="t('thread_arrangement_form.comment_length_max_hint')"
      placeholder="e.g. 500"
      persistent-hint
      :min="1"
      control-variant="hidden"
    />
  </div>
</template>
