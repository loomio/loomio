import { computed } from 'vue';
import { approximate, exact, timeline } from '@/shared/helpers/format_time';
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import ScrollService from '@/shared/services/scroll_service';

export function useFormatDate() {
  const pollTypes = computed(() => AppConfig.pollTypes);
  const currentUser = computed(() => Session.user());
  const currentUserId = computed(() => AppConfig.currentUserId);

  const titleVisible = (visible) => {
    return EventBus.$emit('content-title-visible', visible);
  };

  const scrollTo = (selector, callback) => {
    ScrollService.scrollTo(selector, callback);
  };

  const approximateDate = (date) => {
    return approximate(date);
  };

  const exactDate = (date) => {
    return exact(date);
  };

  const timelineDate = (date) => {
    return timeline(date);
  };

  return {
    pollTypes,
    currentUser,
    currentUserId,
    titleVisible,
    scrollTo,
    approximateDate,
    exactDate,
    timelineDate
  };
}