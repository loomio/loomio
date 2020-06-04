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
    format: ->
      # not all fields this is being used for has a corresponding _format column, for example, discussion.title
      # in the situation in which there is no _format column, fall back to html
      if @model[@field+"Format"]
        @model[@field+"Format"]
      else
        'html'
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
