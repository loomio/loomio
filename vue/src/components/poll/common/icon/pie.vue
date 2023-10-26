<script lang="js">
import svg from 'svg.js';
import AppConfig from '@/shared/services/app_config';
import { sum, values, compact, keys, each } from 'lodash';

export default
{
  props: {
    slices: Array,
    size: Number
  },

  data() {
    return {
      svgEl: null,
      shapes: []
    };
  },

  computed: {
    radius() {
      return this.size / 2.0;
    }
  },

  methods: {
    arcPath(startAngle, endAngle) {
      const rad = Math.PI / 180;
      const x1 = this.radius + (this.radius * Math.cos(-startAngle * rad));
      const x2 = this.radius + (this.radius * Math.cos(-endAngle * rad));
      const y1 = this.radius + (this.radius * Math.sin(-startAngle * rad));
      const y2 = this.radius + (this.radius * Math.sin(-endAngle * rad));
      return ["M", this.radius, this.radius, "L", x1, y1, "A", this.radius, this.radius, 0, +((endAngle - startAngle) > 180), 0, x2, y2, "z"].join(' ');
    },

    draw() {
      this.shapes.forEach(shape => shape.remove());
      let start = 90;

      switch (this.slices.length) {
        case 0:
          return this.shapes.push(this.svgEl.circle(this.size).attr({
            'stroke-width': 0,
            fill: '#BBBBBB'
          })
          );
        case 1:
          return each(this.slices, option => {
            return this.shapes.push(this.svgEl.circle(this.size).attr({
              'stroke-width': 0,
              fill: option.color
            })
            );
          });
        default:
          return each(this.slices, option => {
            const angle = (360 * option.value) / 100;
            this.shapes.push(this.svgEl.path(this.arcPath(start, start + angle)).attr({
              'stroke-width': 0,
              fill: option.color
            })
            );
            return start += angle;
          });
      }
    }
  },

  watch: {
    'slices'() { this.draw(); }
  },

  mounted() {
    this.svgEl = svg(this.$el).size('100%', '100%');
    this.draw();
  },

  beforeDestroy() {
    this.svgEl.clear();
    delete this.shapes;
  }
};
</script>

<template lang="pug">
.poll-proposal-chart(:style="{width: size+'px', height: size+'px'}")
</template>
<style lang="sass">
.poll-proposal-chart
  border: 0
  margin: 0
  padding: 0
  svg
    height: 100%
    width: 100%

</style>
