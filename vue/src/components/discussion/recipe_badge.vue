<script lang="coffee">
export default
  props:
    discussion: Object
    smaller: Boolean

	# mounted: ->
	# 	if @discussion.recipeUrl
	# 	Records.fetch(path: 'recipes', params: {url: @discussion.recipeUrl}).then (data) =>
	# 		console.log('recipe data', data)

</script>

<template lang='pug'>
v-chip(
  v-if="discussion.recipeUrl"
  :x-small="smaller" 
  :small="!smaller" outlined
  title="tbc"
)
  i.mdi.mdi-content-copy.mr-1
  span {{discussion.recipeUrl}}
</template>


