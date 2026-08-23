<script setup lang="js">
import { ref, computed } from 'vue';
import StrandLoadMore from '@/components/strand/load_more.vue';
import ReplyForm from '@/components/strand/reply_form.vue';
import IntersectionWrapper from '@/components/topic_items/intersection_wrapper';
import StemWrapper from '@/components/topic_items/stem_wrapper';
import Collapsed from '@/components/topic_items/collapsed';
const props = defineProps({
  loader: Object,
  collection: {
    type: Array,
    required: true
  },
  focusSelector: String
});

const parentChecked = ref(true);

const isFocused = (topic_item) => {
  return props.focusSelector == `.sequenceId-${topic_item.sequenceId || 0}` ||
    (topic_item.itemableType === 'Comment' && props.focusSelector == `.comment-${topic_item.itemableId || 0}`);
};

</script>

<template lang="pug">
.strand-list
  .topic-item(v-for="obj, index in collection" :key="obj.topic_item.id" :class="{'topic-item--deep': obj.topic_item.depth > 1}")
    .topic-item__row(v-if="obj.missingEarlier")
      strand-load-more(direction="before" :collection="collection" :index="index" :loader="loader")
    v-expand-transition
      .topic-item__row(v-if="loader.collapsed[obj.topic_item.id]")
        collapsed(:obj="obj" :loader="loader")
    v-expand-transition
      .topic-item__row(v-if="!loader.collapsed[obj.topic_item.id]")
        .topic-item__gutter(v-if="obj.topic_item.depth > 0")
          .d-flex.justify-center
            template(v-if="loader.topic.selectedTopicItemIds && loader.topic.selectedTopicItemIds.length")
              v-checkbox-btn.thread-item__is-forking( v-if="obj.topic_item.moveSelectionDisabled()" disabled v-model="parentChecked" )
              v-checkbox-btn.thread-item__is-forking( v-else v-model="loader.topic.selectedTopicItemIds" :value="obj.topic_item.id" )
            template(v-else)
              .topic-item__gutter-toggle(@click="loader.collapse(obj.topic_item)")
                user-avatar.topic-item__gutter-avatar( :user="obj.topic_item.actor()" :size="(obj.topic_item.depth > 1) ? 28 : 32" no-link )
                .topic-item__gutter-collapse
                  common-icon(name="mdi-unfold-less-horizontal")
          stem-wrapper(:loader="loader" :obj="obj" :focused="isFocused(obj.topic_item)")
        .topic-item__main
          .topic-item__main--content
            intersection-wrapper(:loader="loader" :obj="obj" :focused="isFocused(obj.topic_item)")
          .strand-list__children(v-if="obj.topic_item.childCount && (!obj.itemable.isA('stance') || obj.itemable.poll().showResults())")
            strand-load-more(v-if="obj.children.length == 0" direction="children" :collection="collection" :index="index" :loader="loader")
            strand-list.flex-grow-1( :loader="loader" :collection="obj.children" :focusSelector="focusSelector" )
          reply-form(:topicItemId="obj.topic_item.id")

    .topic-item__row(v-if="obj.missingAfter" )
      strand-load-more(direction="after" :obj="obj" :collection="collection" :index="index" :loader="loader")

    //.topic-item__row(v-if="obj.missingAfterCount && obj.topic_item.depth == 1" )
    //  v-btn(:to="endUrl + '?end'") Jump to end

</template>

<style>
.topic-item--deep .topic-item__gutter {
  width: 28px;
}
.topic-item--deep .topic-item__stem {
  margin-left: 14px;
  margin-right: 14px;
}
.topic-item--deep .topic-item__circle {
  width: 28px;
  height: 28px;
}
.topic-item--deep .topic-item__load-more {
  min-height: 28px;
}

.topic-item__row {
  display: flex;
  padding-top: 4px;
}

.topic-item__gutter {
  cursor: pointer;
  display: flex;
  flex-direction: column;
  width: 32px;
}

.topic-item__main {
  flex-grow: 1;
  padding-left: 8px;
  overflow: hidden;
  max-width: 100%;
}

.topic-item__stem-wrapper {
  width: 32px;
  height: 100%;
  padding-top: 4px;
  padding-bottom: 4px;
}

.topic-item__stem {
  width: 0;
  height: 100%;
  padding: 0 1px;
  background-color: rgb(var(--v-theme-surface-light));
  margin: 0px 16px;
}

.topic-item__gutter:hover .topic-item__stem {
  background-color: #d0d0d0;
}

.v-theme--dark .topic-item__gutter:hover .topic-item__stem {
  background-color: rgb(var(--v-theme-surface-bright));
}

.topic-item__stem--broken {
  background-image: linear-gradient(0deg, #dadada 25%, #ffffff 25%, #ffffff 50%, #dadada 50%, #dadada 75%, #ffffff 75%, #ffffff 100%);
  background-size: 16px 16px;
  background-repeat: repeat-y;
}

.topic-item__circle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border: 1px solid #dadada;
  border-radius: 100%;
  margin: 4px 0;
  cursor: pointer;
}

.topic-item__gutter-toggle {
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.topic-item__gutter-collapse {
  display: none;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
}

.topic-item--deep .topic-item__gutter-collapse {
  width: 28px;
  height: 28px;
}

.topic-item__gutter:hover .topic-item__gutter-avatar {
  display: none;
}
.topic-item__gutter:hover .topic-item__gutter-collapse {
  display: flex;
}
</style>
