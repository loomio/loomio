<style lang="scss">
</style>

<script lang="coffee">
module.exports =
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

<template>
    <div :class="'group-avatar lmo-box--' + size" aria-hidden="true">
      <img :class="'lmo-box--' + csize" :alt="group.name" :src="group.logoUrl()">
    </div>
</template>
