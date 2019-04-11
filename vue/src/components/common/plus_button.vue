<script lang="coffee">
import Records from '@/shared/services/records'

export default
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
