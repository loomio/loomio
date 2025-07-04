<script lang="js">
import svg from 'svg.js';
import AppConfig from '@/shared/services/app_config';
import { take, map, max, each} from 'lodash-es';

export default {
    props: {
      size: Number,
      poll: Object
    },
    data() {
      return {
        svgEl: null,
        shapes: []
      };
    },
    computed: {
      stanceCounts() { return this.poll.stanceCounts; },
      scoreData() {
        return take(map(this.stanceCounts, (score, index) => ({
          color: AppConfig.pollColors.poll[index],
          index,
          score
        })), 5);
      },
      scoreMaxValue() {
        return max(map(this.scoreData, data => data.score));
      }
    },
    methods: {
      draw() {
        if ((this.scoreData.length > 0) && (this.scoreMaxValue > 0)) {
          this.drawChart();
        } else {
          this.drawPlaceholder();
        }
      },
      drawPlaceholder() {
        each(this.shapes, shape => shape.remove());
        const barHeight = this.size / 3;
        const barWidths = {
          0: this.size,
          1: (2 * this.size) / 3,
          2: this.size / 3
        };
        each(barWidths, (width, index) => {
          this.svgEl.rect(width, barHeight - 2)
              .fill("#ebebeb")
              .x(0)
              .y(index * barHeight);
        });
      },
      drawChart() {
        each(this.shapes, shape => shape.remove());
        const barHeight = this.size / this.scoreData.length;
        map(this.scoreData, scoreDatum => {
          const barWidth = max([(this.size * scoreDatum.score) / this.scoreMaxValue, 2]);
          return this.svgEl.rect(barWidth, barHeight-2)
              .fill(scoreDatum.color)
              .x(0)
              .y(scoreDatum.index * barHeight);
        });
      }
    },
    watch: {
      stanceCounts() {
        this.draw();
      }
    },
    mounted() {
      this.svgEl = svg(this.$refs.svg).size('100%', '100%');
      this.draw();
    }
};
</script>

<template lang="pug">
.bar-chart(ref="svg" :style="{height: size+'px', width: size+'px'}")
</template>

<style lang="sass">
.bar-chart
	border: 0
	margin: 0
	padding: 0
	svg
		height: 100%
		width: 100%

</style>
