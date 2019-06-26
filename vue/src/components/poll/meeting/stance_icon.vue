<script lang="coffee">
export default
  props:
    score: Number
    size:
      type: Number
      default: 30
</script>

<template lang="pug">
v-avatar.poll-meeting-stance-icon(left :size="size")
  img.poll-common-form__icon(src="/img/abstain.svg" v-if="score == 1")
  img.poll-common-form__icon(src="/img/agree.svg" v-if="score == 2")
</template>
