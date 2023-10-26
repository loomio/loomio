/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import EventBus from '@/shared/services/event_bus';

export default opts => EventBus.$emit('openModal', opts);
