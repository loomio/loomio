<script lang="coffee">
export default
  props:
    discussion: Object
    close: Function
</script>
<template lang="pug">
v-card
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline Move Comments
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    span Select the discussion you want to move these comments to
</template>
