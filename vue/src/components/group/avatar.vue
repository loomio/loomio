<script lang="coffee">
export default
  props:
    group: Object
    size: String
  computed:
    csize: ->
      sizes = ['small', 'medium', 'large']
      if _.includes(sizes, @size)
        @size
      else
        'small'
</script>

<template lang="pug">
v-avatar(:size="56" tile)
  img(:alt="group.name" :src="group.logoUrl()")
</template>
