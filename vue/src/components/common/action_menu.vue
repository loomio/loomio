<script lang="js">
import { some } from 'lodash-es';
export default {
  props: {
    actions: Object,
    small: Boolean,
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

<template>

<div class="action-menu lmo-no-print" v-if="canPerformAny">
  <v-menu offset-y="offset-y">
    <template v-slot:activator="{ on, attrs }">
      <v-btn class="action-menu--btn" :title="name" :icon="icon" :small="small" v-on="on" v-bind="attrs" @click.prevent="@click.prevent">
        <common-icon v-if="icon" :small="small" :name="menuIcon"></common-icon><span v-if="!icon">{{name}}</span>
      </v-btn>
    </template>
    <v-list>
      <template v-for="(action, name) in actions" v-if="action.canPerform()">
        <v-list-item dense="dense" v-if="!action.to" :key="name" @click="action.perform()" :class="'action-dock__button--' + name">
          <v-list-item-icon>
            <common-icon :name="action.icon"></common-icon>
          </v-list-item-icon>
          <v-list-item-title v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }"></v-list-item-title>
        </v-list-item>
        <v-list-item dense="dense" v-if="action.to" :key="name" :to="action.to()" :class="'action-dock__button--' + name">
          <v-list-item-icon>
            <common-icon :name="action.icon"></common-icon>
          </v-list-item-icon>
          <v-list-item-title v-t="{path: (action.name || 'action_dock.'+name), args: (action.nameArgs && action.nameArgs()) }"></v-list-item-title>
        </v-list-item>
      </template>
    </v-list>
  </v-menu>
</div>
</template>
