<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { filter, debounce, truncate, first, last, some, drop, omit} from 'lodash'

export default
  {}

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(:permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="transparent" floating)
  | polls nav
</template>
<style lang="sass">
</style>
