<script setup>
import { ref, computed, onMounted } from 'vue';
import Records from '@/shared/services/records';

const props = defineProps({
  loader: Object,
  obj: Object
});

const userIds = ref([]);

const users = computed(() => userIds.value.map(id => Records.users.find(id)).filter(Boolean));

onMounted(() => {
  Records.fetch({path: `topic_items/${props.obj.topic_item.id}/descendant_authors`}).then(data => {
    userIds.value = (data.users || []).map(u => u.id);
  });
});
</script>

<template lang="pug">
.d-flex.align-center(:class="[`positionKey-${obj.topic_item.positionKey}`, `sequenceId-${obj.topic_item.sequenceId}`]")
  .strand-item__circle.mr-2(v-if="loader.collapsed[obj.topic_item.id]" @click.stop="loader.expand(obj.topic_item)")
    common-icon(name="mdi-unfold-more-horizontal")
  .strand-item__collapsed-headline(@click="loader.expand(obj.topic_item)")
    strand-item-headline.text-medium-emphasis(:topic_item="obj.topic_item" :itemable="obj.itemable" collapsed)
  .strand-item__descendant-avatars(v-if="users.length")
    user-avatar.strand-item__descendant-avatar(v-for="user in users" :key="user.id" :user="user" :size="24" no-link)
</template>

<style>
.strand-item__collapsed-headline {
  flex-shrink: 0;
  cursor: pointer;
}
.strand-item__collapsed-headline a {
  pointer-topic_items: none;
}

.strand-item__descendant-avatars {
  display: flex;
  flex: 1;
  min-width: 0;
  overflow: hidden;
  margin-left: 8px;
}

.strand-item__descendant-avatar:not(:first-child) {
  margin-left: -8px;
}
</style>
