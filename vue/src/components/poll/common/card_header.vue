<script lang="js">
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
      const topic = this.poll.topic();
      const group = topic.group();
      const topicable = topic.topicable();
      return map(compact([group, topicable]), model => {
        return {
          title: model.name || model.title,
          disabled: false,
          to: this.urlFor(model)
        };
      });
    }
  }
};
</script>

<template lang="pug">
.poll-common-card-header.d-flex.align-center.mr-3.ml-2.pb-2.pt-4.flex-wrap
  v-breadcrumbs.py-1.ml-n2.text-body-2(:items="groups" color="anchor")
    template(v-slot:divider)
      common-icon(name="mdi-chevron-right")
  v-spacer
  tags-display(:tags="poll.topic().tags" :group="poll.group()")
</template>

