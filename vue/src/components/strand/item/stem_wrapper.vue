<script lang="js">
export default {
  props: {
    loader: Object,
    obj: Object,
  },
  methods: {
    isFocused(event) {
      return ((event.depth === 1) && (event.position === this.loader.focusAttrs.position)) ||
      (event.positionKey === this.loader.focusAttrs.positionKey) ||
      (event.sequenceId === this.loader.focusAttrs.sequenceId) ||
      ((event.eventableType === 'Comment') && (event.eventableId === this.loader.focusAttrs.commentId));
    }
  }
};

</script>

<template lang="pug">
.strand-item__stem-wrapper(@click.stop="loader.collapse(obj.event)" :key="obj.event.id")
  .strand-item__stem(:class="{'strand-item__stem--unread': obj.isUnread, 'strand-item__stem--focused': isFocused(obj.event)}")
</template>
