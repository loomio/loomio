<script lang="coffee">

export default
  props:
    removable: Boolean
    remove: Function
    name: String
    color: String
  data: ->
    expand: false
  computed:
    isTooLong: ->
      @name.length > 30
    displayName: ->
      if @isTooLong
        @name.substring(0, 30) + "..."
      else
        @name
</script>

<template lang="pug">
v-menu(v-model="expand" bottom='' right='' transition='scale-transition' origin='top left')
  template(v-slot:activator='{ on }')
    v-chip(v-on="isTooLong && on" :close="removable" :color="color" @click:close="remove(name)") {{displayName}}
  v-card(:style="'background-color: ' + color")
    v-card-text
      span {{name}}
</template>
