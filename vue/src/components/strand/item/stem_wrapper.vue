<script lang="js">
import Session        from '@/shared/services/session';
export default {
  props: {
    loader: Object,
    obj: Object,
    focused: Boolean,
  },
  computed: {
    isSignedIn() { return Session.isSignedIn(); },
  },

};

</script>

<template lang="pug">
.strand-item__stem-wrapper(@click.stop="loader.collapse(obj.topic_item)" :key="obj.topic_item.id")
  .strand-item__stem(:class="{'strand-item__stem--unread': (isSignedIn && obj.isUnread), 'strand-item__stem--focused': focused}")
</template>
