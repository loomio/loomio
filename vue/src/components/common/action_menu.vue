<script lang="js">
import { some } from 'lodash-es';
export default {
  props: {
    actions: Object,
    color: String,
    variant: {
      type: String,
      default: 'tonal'
    },
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
      v-btn.action-menu--btn(:title="name" :icon="icon" density="comfortable" :size="size" :variant="variant" :color="color" v-bind="props" @click.prevent)
        common-icon(v-if="icon" :size="size" :name="menuIcon" :color="color")
        span(v-if="!icon") {{name}}

    v-list
      template(v-for="(action, name) in actions")
        template(v-if="action.canPerform()")
          v-list-item(
            density="compact"
            v-if='!action.to'
            :key="name"
            @click="action.perform()"
            :class="'action-dock__button--' + name")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
          v-list-item(
            density="compact"
            v-if='action.to'
            :key="name"
            :to="action.to()"
            :class="'action-dock__button--' + name")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
</template>
