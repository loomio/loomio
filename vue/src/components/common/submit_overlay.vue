<script lang="coffee">
export default
  props:
    value: Boolean
</script>

<template lang="pug">
v-overlay.submit-overlay(:value="value")
  v-progress-circular(indeterminate size="64")
</template>
