<script lang="js">
export default {
  props: {
    stance: Object
  }
};
</script>

<template>

<div class="poll-common-change-your-vote">
  <v-subheader v-t="'poll_common.your_response'"></v-subheader>
  <poll-common-stance :stance="stance"></poll-common-stance>
</div>
</template>
