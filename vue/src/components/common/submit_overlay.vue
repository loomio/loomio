<script lang="js">
export default {
  props: {
    value: Boolean
  }
};
</script>

<template>

<v-overlay class="submit-overlay" :value="value">
  <v-progress-circular indeterminate="indeterminate" size="64"></v-progress-circular>
</v-overlay>
</template>
