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
.topic-item__stem-wrapper(@click.stop="loader.collapse(obj.topic_item)" :key="obj.topic_item.id")
  .topic-item__stem(:class="{'topic-item__stem--unread': (isSignedIn && obj.isUnread), 'topic-item__stem--focused': focused}")
</template>
