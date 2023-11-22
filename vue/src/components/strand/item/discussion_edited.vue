<script lang="js">
export default {
    props: {
      event: Object,
      eventable: Object
    }
};
</script>

<template>

<section class="strand-item__discussion-edited" id="'outcome-'+ eventable.id">
  <strand-item-headline :event="event" :eventable="eventable" dateTime:="dateTime:" event.createdAt="event.createdAt"></strand-item-headline>
  <p>{{event.recipientMessage}}</p>
</section>
</template>
