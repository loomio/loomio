import TopicAbility from '@/shared/abilities/topic_ability';

export default {
  // Records outside a thread, and threads or polls not yet in one, accept
  // files. Everything inside a thread follows the thread's attachment rule.
  canAttach(record) {
    const kind = record.constructor.singular;
    if (!['discussion', 'poll', 'comment', 'stance', 'outcome'].includes(kind)) { return true; }
    if (['discussion', 'poll'].includes(kind) && !record.topicId) { return true; }
    const topic = kind === 'outcome' ? record.poll().topic() : record.topic();
    return TopicAbility.canAttachFiles(topic);
  }
};
