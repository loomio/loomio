<style lang="scss">
</style>

<script lang="coffee">
export default
  props:
    stanceChoice: Object
</script>

<template lang="pug">
v-layout.poll-common-stance-choice.poll-common-stance-choice--meeting
  poll-meeting-stance-icon.poll-meeting-stance-icon--thread-item(:score="stanceChoice.score")
  poll-meeting-time(:name="stanceChoice.pollOption().name")
</template>
