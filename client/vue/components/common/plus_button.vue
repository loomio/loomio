<style lang="scss">
</style>

<script lang="coffee">
Records = require 'shared/services/records'

module.exports =
  props:
    click: Function
    message: String
  methods:
    plusUser: ->
      Records.users.build(avatarKind: 'mdi-plus')
</script>

<template lang="pug">
v-list-tile.plus-button(@click='click()')
  v-list-tile-avatar
    v-icon mdi-plus
  v-list-tile-content
    v-list-tile-title(v-t='message')
</template>
