<script setup lang="js">
import { ref, computed } from 'vue';
import StrandLoadMore from '@/components/strand/load_more.vue';
import ReplyForm from '@/components/strand/reply_form.vue';
import IntersectionWrapper from '@/components/strand/item/intersection_wrapper';
import StemWrapper from '@/components/strand/item/stem_wrapper';
import Collapsed from '@/components/strand/item/collapsed';
import LmoUrlService from '@/shared/services/lmo_url_service';

const props = defineProps({
  loader: Object,
  collection: {
    type: Array,
    required: true
  },
  focusSelector: String
});

const parentChecked = ref(true);

const endUrl = computed(() => {
  if (!props.loader || !props.loader.discussion) { return ''; }
  return LmoUrlService.route({ model: props.loader.discussion });
});

const isFocused = (event) => {
  return props.focusSelector == `.sequenceId-${event.sequenceId || 0}` ||
    (event.eventableType === 'Comment' && props.focusSelector == `.comment-${event.eventableId || 0}`);
};

const rowClasses = (obj) => {
  if (isFocused(obj.event)) {
    return ['strand-item__row--focused', 'rounded-lg'];
  }
};
</script>

<template lang="pug">
.strand-list
  .strand-item(v-for="obj, index in collection" :key="obj.event.id" :class="{'strand-item--deep': obj.event.depth > 1}")
    //.strand-item__row(v-if="obj.missingEarlier && obj.event.depth == 1" )
    //  v-btn(:to="endUrl + '?end'") Jump to start
    .strand-item__row(v-if="obj.missingEarlier")
      strand-load-more(direction="before" :collection="collection" :index="index" :loader="loader")
    .strand-item__row(v-if="loader.collapsed[obj.event.id]")
      collapsed(:obj="obj" :loader="loader")
    .strand-item__row(v-if="!loader.collapsed[obj.event.id]")
      .strand-item__gutter(v-if="obj.event.depth > 0")
        .d-flex.justify-center
          template(v-if="loader.discussion && loader.discussion.forkedEventIds && loader.discussion.forkedEventIds.length")
            v-checkbox-btn.thread-item__is-forking( v-if="obj.event.forkingDisabled()" disabled v-model="parentChecked" )
            v-checkbox-btn.thread-item__is-forking( v-else v-model="loader.discussion.forkedEventIds" :value="obj.event.id" )
          template(v-else)
            user-avatar( :user="obj.event.actor()" :size="(obj.event.depth > 1) ? 28 : 32" no-link )
        stem-wrapper(:loader="loader" :obj="obj" :focused="isFocused(obj.event)")
      .strand-item__main
        .strand-item__main--content
          //.strand-item__row--focused-underlay(v-if="isFocused(obj.event)")
          intersection-wrapper(:loader="loader" :obj="obj" :focused="isFocused(obj.event)")
        .strand-list__children(v-if="obj.event.childCount && (!obj.eventable.isA('stance') || obj.eventable.poll().showResults())")
          strand-load-more(v-if="obj.children.length == 0" direction="children" :collection="collection" :index="index" :loader="loader")
          strand-list.flex-grow-1( :loader="loader" :collection="obj.children" :focusSelector="focusSelector" )
        reply-form(:eventId="obj.event.id")

    .strand-item__row(v-if="obj.missingAfter" )
      strand-load-more(direction="after" :obj="obj" :collection="collection" :index="index" :loader="loader")

    //.strand-item__row(v-if="obj.missingAfterCount && obj.event.depth == 1" )
    //  v-btn(:to="endUrl + '?end'") Jump to end

</template>

<style lang="sass">

.strand-item__row--focused
  padding: 12px;
  position: relative
  color: rgb(var(--v-theme-info)) !important;

.strand-item__row--focused-underlay
  position: absolute
  background: currentColor
  opacity: var(--v-activated-opacity)
  border-radius: inherit
  top: 0
  right: 0
  bottom: 0
  left: 0
  pointer-events: none

.strand-item--deep
  .strand-item__gutter
    width: 28px
    // margin-right: 4px

  .strand-item__stem
    margin-left: 14px
    margin-right: 14px

  .strand-item__circle
    // margin: 4px 0
    // padding: 4px 0
    width: 28px
    height: 28px

  .strand-item__load-more
    min-height: 28px

.strand-item__row
  display: flex
  padding-top: 4px

.strand-item__gutter
  cursor: pointer;
  display: flex
  flex-direction: column
  width: 32px
  // margin-right: 8px

.strand-item__main
  flex-grow: 1
  padding-left: 8px
  overflow: hidden
  max-width: 100%

.strand-item__stem-wrapper
  width: 32px
  height: 100%
  padding-top: 4px
  padding-bottom: 4px

.strand-item__stem
  width: 0
  height: 100%
  padding: 0 1px
  background-color: rgb(var(--v-theme-surface-light))
  margin: 0px 16px

.strand-item__gutter:hover
  .strand-item__stem
    background-color: #d0d0d0

.v-theme--dark, .v-theme--darkBlue
  .strand-item__gutter:hover
    .strand-item__stem
      background-color: rgb(var(--v-theme-surface-bright))

.strand-item__stem--broken
  background-image: linear-gradient(0deg, #dadada 25%, #ffffff 25%, #ffffff 50%, #dadada 50%, #dadada 75%, #ffffff 75%, #ffffff 100%)
  background-size: 16.00px 16.00px
  background-repeat: repeat-y

.strand-item__circle
  display: flex
  align-items: center
  justify-content: center
  width: 32px
  height: 32px
  border: 1px solid #dadada
  border-radius: 100%
  margin: 4px 0
  cursor: pointer

</style>