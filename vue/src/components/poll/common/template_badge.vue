<script lang="js">
export default {
  props: {
    poll: Object,
    smaller: Boolean
  }
};
</script>

<template>

<v-chip v-if="poll.template" :x-small="smaller" :small="!smaller" outlined="outlined" :title="$t('templates.this_is_a_template_for_new_poll')"><i class="mdi mdi-content-copy mr-1"></i><span v-t="'common.template'"></span></v-chip>
</template>


