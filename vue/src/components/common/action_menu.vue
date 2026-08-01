<script setup lang="js">
import { computed } from 'vue';
import { some } from 'lodash-es';

const props = defineProps({
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
  },
  showIcon: {
    type: Boolean,
    default: false
  },
  listItem: Boolean
});

const canPerformAny = computed(() => some(props.actions, action => action.canPerform()));
</script>

<template lang="pug">
.action-menu.lmo-no-print(v-if='canPerformAny')
  v-menu(offset-y)
    template(v-slot:activator="{ props }" )
      v-list-item.action-menu--list-item(v-if="listItem" v-bind="props" :title="name" @click.stop.prevent)
        template(v-slot:prepend)
          common-icon(:name="menuIcon")
        template(v-slot:append)
          common-icon(name="mdi-chevron-down")
      v-btn.action-menu--btn.action-button(v-else :title="name" :icon="icon" density="comfortable" :size="size" :variant="variant" :color="color" v-bind="props" @click.stop.prevent)
        common-icon(v-if="icon || showIcon" :size="size" :name="menuIcon" :color="color" :class="{'mr-1': showIcon}")
        span(v-if="!icon") {{name}}

    v-list(density="compact")
      template(v-for="(action, name) in actions")
        template(v-if="action.canPerform()")
          v-list-item(
            v-if='!action.to'
            :key="name"
            @click.stop="action.perform()"
            :class="'action-dock__button--' + name")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
          v-list-item(
            v-if='action.to'
            :key="name"
            :to="action.to()"
            @click.stop
            :class="'action-dock__button--' + name")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }")
</template>
