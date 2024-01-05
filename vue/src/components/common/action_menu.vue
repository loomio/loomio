<script lang="js">
import { some } from 'lodash-es';
export default {
  props: {
    actions: Object,
    size: {
      type: String,
      default: 'default'
    },
    icon: Boolean,
    name: String,
    menuIcon: { 
      type: String,
      default: 'mdi-dots-horizontal'
    }
  },

  computed: {
    canPerformAny() {
      return some(this.actions, action => action.canPerform());
    }
  }
}
</script>

<template lang="pug">
.action-menu.lmo-no-print(v-if='canPerformAny')
  v-menu(offset-y)
    template(v-slot:activator="{ props }" )
      v-btn.action-menu--btn(:title="name" :icon="icon" :size="size" variant="text" v-bind="props" @click.prevent)
        common-icon(v-if="icon" :size="size" :name="menuIcon")
        span(v-if="!icon") {{name}}

    v-list
      template(v-for="(action, name) in actions")
        v-list-item(
          dense
          v-if='!action.to'
          :key="name"
          @click="action.perform()"
          :class="'action-dock__button--' + name")
          template(v-slot:prepend)
            common-icon(:name="action.icon")
          v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
        v-list-item(
          dense
          v-if='action.to'
          :key="name"
          :to="action.to()"
          :class="'action-dock__button--' + name")
          template(v-slot:prepend)
            common-icon(:name="action.icon")
          v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
</template>
