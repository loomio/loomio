<script lang="coffee">
import UrlFor from '@/mixins/url_for'
export default
  mixins: [UrlFor]
  props:
    group: Object
</script>

<template lang="pug">
.group-cover-image
  v-parallax(height="200" :src="group.coverUrl()")
    v-layout(align-center column justify-center)
     h1.display-1.group-cover-image__text
       span(v-if="group.parent()")
         router-link(:to="urlFor(group.parent())") {{group.parent().name}}
         | &nbsp;
         | &gt;
         | &nbsp;
       span {{group.name}}
</template>
<style lang="scss">
.group-cover-image__text {
  text-shadow: 0px 0px 8px rgba(0,0,0,1);
}
</style>
