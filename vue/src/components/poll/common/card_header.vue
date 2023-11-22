<script lang="js">
import AbilityService from '@/shared/services/ability_service';
import { map, compact  } from 'lodash-es';

export default
{
  props: {
    poll: Object
  },

  computed: {
    groups() {
      return map(compact([(this.poll.groupId && this.poll.group()), (this.poll.discussionId && this.poll.discussion())]), model => {
        if (model.isA('discussion')) {
          return {
            text: model.name || model.title,
            disabled: false,
            to: this.urlFor(model)+'/'+this.poll.createdEvent().sequenceId
          };
        } else {
          return {
            text: model.name || model.title,
            disabled: false,
            to: this.urlFor(model)
          };
        }
      });
    }
  }
};
</script>

<template>

<div class="poll-common-card-header d-flex align-center mr-3 ml-2 pb-2 pt-4 flex-wrap">
  <v-breadcrumbs :items="groups">
    <template v-slot:divider="v-slot:divider">
      <common-icon name="mdi-chevron-right"></common-icon>
    </template>
  </v-breadcrumbs>
  <v-spacer></v-spacer>
  <tags-display :tags="poll.tags" :group="poll.group()"></tags-display>
</div>
</template>

<style lang="sass">
.poll-common-card-header
  .v-breadcrumbs
    padding: 0px 10px
</style>
