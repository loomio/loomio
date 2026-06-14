<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  action: Object,
  name: String,
  nameArgs: Object,
  color: String,
  variant: String,
  size: {
    type: String,
    default: undefined
  }
});

const { t } = useI18n();

const text = computed(() => t((props.action.name || ('action_dock.' + props.name)), (props.nameArgs || {})));
const cssClass = computed(() => `action-dock__button--${props.name}`);
</script>

<template lang="pug">
span
  v-btn.action-button.mr-1(
    v-if="action.to"
    :to="action.to()"
    :icon="action.dock == 1"
    :title="text"
    :class='cssClass'
    :color="color"
    :variant="variant"
    :density="action.dock == 1 ? 'comfortable' : 'default'"
    :size="size"
  )
    common-icon(v-if="action.dock == 1 || action.dock == 3" :size="size" :name="action.icon" :color="color")
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
  v-btn.action-button.mr-1(
    v-else
    @click.prevent="action.perform()"
    :icon="action.dock == 1"
    :title="text"
    :class='cssClass'
    :color="color"
    :size="size"
    :density="action.dock == 1 ? 'comfortable' : 'default'"
    :variant="variant"
  )
    common-icon(v-if="action.dock == 1 || action.dock == 3" :size="size" :name="action.icon" :color="color")
    span.ml-1(v-if="action.dock == 3")
    span(v-if="action.dock > 1") {{text}}
</template>
<style lang="sass">
.action-button
  text-transform: lowercase

</style>
