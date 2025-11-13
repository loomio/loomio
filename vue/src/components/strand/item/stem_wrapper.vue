<script setup lang="js">
import { computed } from 'vue';
import Session from '@/shared/services/session';

const props = defineProps({
  loader: Object,
  obj: Object,
  focused: Boolean
});

const isSignedIn = computed(() => Session.isSignedIn());
</script>

<template lang="pug">
.strand-item__stem-wrapper(@click.stop="loader.collapse(obj.event)" :key="obj.event.id")
  .strand-item__stem(:class="{'strand-item__stem--unread': (isSignedIn && obj.isUnread), 'strand-item__stem--focused': focused}")
</template>