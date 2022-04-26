<script lang="coffee">
import { some } from 'lodash'
export default
  props:
    actions: Object
    small: Boolean
    icon: Boolean
    name: String

  computed:
    canPerformAny: ->
      some @actions, (action) -> action.canPerform()

</script>

<template lang="pug">
.action-menu.lmo-no-print(v-if='canPerformAny')
  v-menu(offset-y)
    template(v-slot:activator="{ on, attrs }" )
      v-btn.action-menu--btn(:title="name" :icon="icon" :small="small" v-on="on" v-bind="attrs" @click.prevent)
        v-icon(v-if="icon" :small="small") mdi-dots-horizontal
        span(v-if="!icon") {{name}}

    v-list
      template(v-for="(action, name) in actions" v-if="action.canPerform()")
        v-list-item(
          v-if='!action.to'
          :key="name"
          @click="action.perform()"
          :class="'action-dock__button--' + name")
          v-list-item-icon
            v-icon {{action.icon}}
          v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
        v-list-item(
          v-if='action.to'
          :key="name"
          :to="action.to"
          :class="'action-dock__button--' + name")
          v-list-item-icon
            v-icon {{action.icon}}
          v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
</template>
