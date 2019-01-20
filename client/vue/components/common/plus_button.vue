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

<template>
    <div @click="click()" class="plus-button lmo-flex lmo-flex__center lmo-pointer">
      <user-avatar
        :user="plusUser()"
        :no-link="true"
        size="medium"
        :colors="{borderColor: 'accent-500', color: 'accent-500'}"
        class="lmo-margin-right"
      ></user-avatar>
      <span v-t="message"></span>
    </div>
</template>
