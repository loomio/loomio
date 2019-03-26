<style lang="scss">
.poll-meeting-stance-icon {
  display:flex;
  align-items: center;
  justify-content: center;

  img {
    margin: auto;
    width: 30px;
  }
}

.poll-meeting-stance-icon--thread-item {
  margin-right: 12px;
  img {
    max-width:20px;
  }
}
</style>

<script lang="coffee">
module.exports =
  props:
    score: Number
    threadItem: Object
</script>

<template lang="pug">
.poll-meeting-stance-icon
  img.poll-common-form__icon(src="/img/abstain.svg", v-if="score == 1")
  img.poll-common-form__icon(src="/img/agree.svg", v-if="score == 2")
</template>
