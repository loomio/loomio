<style lang="scss">
  .action-dock {
    transition: opacity ease-in-out 0.25s;
  }
</style>
<script lang="coffee">
  module.exports =
    props:
      model: Object
      actions: Array
</script>
<template>
  <div
    layout="row"
    class="action-dock lmo-flex lmo-no-print"
  >
    <div v-for="action in actions" v-if="action.canPerform()" class="action-dock__action">
      <!-- <reactions_input class="action-dock__button--react" model="model" v-if="action.name == 'react'"></reactions_input> -->
      <v-tooltip bottom>
        <v-btn slot="activator" icon :class="`md-button--tiny action-dock__button--${action.name}`" v-if="action.name != 'react'" @click="action.perform()">
          <div v-t="'action_dock.' + action.name" class="sr-only"></div>
          <v-icon>{{action.icon}}</v-icon>
          <div v-if="action.active && action.active()" md-colors="{'color': 'warn-200'}">
            <i class="mdi mdi-alert-circle-outline mdi-16px lmo-margin-right"></i>
            <span v-t="'action_dock.' + action.name + '_active'" v-if="action.active && action.active()"></span>
          </div>
        </v-btn>
        <div v-t="'action_dock.' + action.name"></div>
      </v-tooltip>
    </div>
  </div>
</template>
