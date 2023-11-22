<script lang="js">
export default {
  props: {
    score: Number,
    size: {
      type: Number,
      default: 30
    }
  }
};
</script>

<template>

<v-avatar class="poll-meeting-stance-icon" left="left" :size="size"><img class="poll-common-form__icon" src="/img/abstain.svg" v-if="score == 1"/><img class="poll-common-form__icon" src="/img/agree.svg" v-if="score == 2"/></v-avatar>
</template>
