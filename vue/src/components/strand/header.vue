<script lang="js">
import LmoUrlService from '@/shared/services/lmo_url_service';
import FormatDate from '@/mixins/format_date';

export default {
  mixins: [FormatDate],
  props: {
    topicable: Object
  },

  computed: {
    topic() {
      return this.topicable.topic();
    },

    group() {
      return this.topicable.group();
    },

    groups() {
      if (!this.group) { return []; }
      return this.group.parentsAndSelf().map(group => {
        return {
          title: group.name,
          disabled: false,
          to: group.id ? LmoUrlService.route({model: group}) : '/dashboard/direct_discussions'
        };
      });
    },

    tags() {
      return this.topicable.tags;
    },

    isPinned() {
      return !!this.topic.pinnedAt;
    }
  }
};
</script>

<template lang="pug">
.strand-header
  .d-flex.ml-n3.text-body-2
    v-breadcrumbs.context-panel__breadcrumbs(color="anchor" :items="groups")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    v-spacer
    tags-display(:tags="tags" :group="group")
  h1.text-h4.context-panel__heading#sequence-0.pt-2.mb-4(tabindex="-1" v-intersect="{handler: titleVisible}")
    plain-text(:model='topicable' field='title')
    i.mdi.mdi-pin-outline.context-panel__heading-pin(v-if="isPinned")
</template>

<style lang="sass">
.strand-header
  .v-breadcrumbs
    padding: 4px 10px 4px 10px
</style>
