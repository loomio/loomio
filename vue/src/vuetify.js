import {createApp}  from 'vue';
import {createVuetify} from 'vuetify';
import Session from '@/shared/services/session';

const app = createApp()
const vuetify = createVuetify({
  iconfont: 'mdi',
  theme: {
    dark: false,
    options: {
      customProperties: true
    }
  }
});
 
import colors from 'vuetify/lib/util/colors';

const useDarkMode = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
