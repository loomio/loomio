<script lang="coffee">
export default
  props:
    model: Object
    field: String
  computed:
    isMd: -> @format == 'md'
    isHtml: -> @format == 'html'
    translated: ->
      @model.translation[@field]
    format: -> @model[@field+"Format"]
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
