<script lang="js">
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import AttachmentListItem from './attachment_list_item';

export default {
  components: {AttachmentListItem},
  props: {
    attachments: [Array, Object]
  }
};
</script>

<template>

<div class="attachment-list mb-2" v-if="attachments && attachments.length">
  <attachment-list-item v-for="attachment in attachments" :key="attachment.id" :attachment="attachment"></attachment-list-item>
</div>
</template>
