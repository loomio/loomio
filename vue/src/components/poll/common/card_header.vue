<script lang="js">
import AbilityService from '@/shared/services/ability_service';
import { map, compact  } from 'lodash-es';
import UrlFor from '@/mixins/url_for';

export default
{
  mixins: [UrlFor],
  props: {
    poll: Object
  },

  computed: {
    groups() {
      return map(compact([(this.poll.groupId && this.poll.group()), (this.poll.discussionId && this.poll.discussion())]), model => {
        if (model.isA('discussion')) {
          return {
            title: model.name || model.title,
            disabled: false,
            to: this.urlFor(model)+'/'+this.poll.createdEvent().sequenceId
          };
        } else {
          return {
            title: model.name || model.title,
            disabled: false,
            to: this.urlFor(model)
          };
        }
      });
    }
  }
};
</script>

<template lang="pug">
.poll-common-card-header.d-flex.align-center.mr-3.ml-2.pb-2.pt-4.flex-wrap
  v-breadcrumbs.py-1.ml-n2.text-body-medium(:items="groups" color="anchor")
    template(v-slot:divider)
      common-icon(name="mdi-chevron-right")
  v-spacer
  tags-display(:tags="poll.tags" :group="poll.group()")
</template>

