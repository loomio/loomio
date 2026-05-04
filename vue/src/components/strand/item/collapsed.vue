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
  Records.fetch({path: `events/${props.obj.event.id}/descendant_authors`}).then(data => {
    userIds.value = (data.users || []).map(u => u.id);
  });
});
</script>

<template lang="pug">
.d-flex.align-center(:class="[`positionKey-${obj.event.positionKey}`, `sequenceId-${obj.event.sequenceId}`]")
  .strand-item__circle.mr-2(v-if="loader.collapsed[obj.event.id]" @click.stop="loader.expand(obj.event)")
    common-icon(name="mdi-arrow-split-horizontal")
  .strand-item__collapsed-headline(@click="loader.expand(obj.event)")
    strand-item-headline.text-medium-emphasis(:event="obj.event" :eventable="obj.eventable" collapsed)
  .strand-item__descendant-avatars(v-if="users.length")
    user-avatar.strand-item__descendant-avatar(v-for="user in users" :key="user.id" :user="user" :size="24" no-link)
</template>

<style lang="sass">
.strand-item__collapsed-headline
  flex-shrink: 0
  cursor: pointer
  // when collapsed, clicking anything in the headline expands rather than
  // navigating to the user's profile etc.
  a
    pointer-events: none
.strand-item__descendant-avatars
  display: flex
  flex: 1
  min-width: 0
  overflow: hidden
  margin-left: 8px
.strand-item__descendant-avatar:not(:first-child)
  margin-left: -8px
</style>
