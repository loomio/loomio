<script lang="coffee">
import { some } from 'lodash'
export default
  props:
    actions: Object
    small: Boolean

  computed:
    canPerformAny: ->
      some @actions, (action) -> action.canPerform()

</script>

<template lang="pug">
.action-menu.lmo-no-print(v-if='canPerformAny')
  v-menu(offset-y)
    template(v-slot:activator="{ on, attrs }" )
      v-btn.action-menu--btn(:aria-label="$t('action_dock.more_actions')" icon :small="small" v-on="on" v-bind="attrs" @click.prevent)
        v-icon(:small="small") mdi-dots-horizontal
    v-list
      v-list-item(v-for="(action, name) in actions" :key="name" @click="action.perform()" v-if='action.canPerform()' :class="'action-dock__button--' + name")
        v-list-item-icon
          v-icon {{action.icon}}
        v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
</template>
