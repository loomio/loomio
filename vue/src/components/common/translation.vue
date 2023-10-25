<script lang="js">
export default {
  props: {
    model: Object,
    field: String
  },
  computed: {
    isMd() { return this.format === 'md'; },
    isHtml() { return this.format === 'html'; },
    translated() {
      return this.model.translation[this.field];
    },
    format() {
      // not all fields this is being used for has a corresponding _format column, for example, discussion.title
      // in the situation in which there is no _format column, fall back to html
      if (this.model[this.field+"Format"]) {
        return this.model[this.field+"Format"];
      } else {
        return 'html';
      }
    }
  }
}
</script>

<template lang="pug">
.translation
  .translated-body(v-if="isMd" v-marked='translated')
  .translated-body(v-if="isHtml" v-html='translated')
</template>
<style lang="sass">
.translation__body
	font-style: italic
.lmo-h1
	.translation__body
		p
			margin: 0
</style>
