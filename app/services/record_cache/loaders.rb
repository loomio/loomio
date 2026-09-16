module RecordCache::Loaders
  class Noop < RecordCache::Loader
    def load; end
  end

  class Translation < RecordCache::Loader
    def load
      cache.merge_index(:translations_by_id, records)
    end
  end

  class Topic < RecordCache::Loader
    def load
      topic_ids = records.map(&:id)
      discussion_ids = records.filter_map { |topic| topic.topicable_id if topic.topicable_type == 'Discussion' }
      poll_ids = records.filter_map { |topic| topic.topicable_id if topic.topicable_type == 'Poll' }

      cache.add_topics(records)
      add_topic_readers(topic_ids)
      cache.add_discussions(::Discussion.where(id: discussion_ids)) if discussion_ids.any?
      if poll_ids.any?
        polls = ::Poll.where(id: poll_ids)
        cache.add_polls_options_stances_outcomes(polls)
        cache.add_reactions_for_itemables(polls)
      end
      add_groups(records.map(&:group_id).compact)
    end
  end

  class Discussion < RecordCache::Loader
    def load
      topic_ids = records.map(&:topic_id)
      cache.add_discussions(records)
      cache.add_topics(::Topic.where(id: topic_ids))
      add_topic_readers(topic_ids)
      add_groups(records.map(&:group_id).compact)
      cache.add_polls_options_stances_outcomes(::Poll.active.where(topic_id: topic_ids))
    end
  end

  class Reaction < RecordCache::Loader
    def load
      cache.add_reactions(records)
    end
  end

  class Notification < RecordCache::Loader
    def load
      cache.user_ids.concat(records.filter_map(&:actor_id))
    end
  end

  class Group < RecordCache::Loader
    def load
      add_groups(records.map(&:id))
    end
  end

  class Membership < RecordCache::Loader
    def load
      add_groups(records.map(&:group_id), memberships: false)
      cache.user_ids.concat(records.map(&:user_id))
      cache.user_ids.concat(records.filter_map(&:inviter_id))
    end
  end

  class Poll < RecordCache::Loader
    def load
      topic_ids = records.map(&:topic_id)
      topics = ::Topic.where(id: topic_ids).to_a

      add_groups(topics.map(&:group_id))
      cache.add_topics(topics)
      add_topic_readers(topic_ids)
      cache.add_discussions(::Discussion.where(topic_id: topic_ids))
      cache.add_polls_options_stances_outcomes(records)
      cache.add_reactions_for_itemables(records)
    end
  end

  class Outcome < RecordCache::Loader
    def load
      cache.add_polls(::Poll.where(id: records.map(&:poll_id)))
      cache.user_ids.concat(records.map(&:author_id))
      cache.add_reactions_for_itemables(records)
    end
  end

  class Stance < RecordCache::Loader
    def load
      cache.add_stances(records)
      cache.add_polls_options_stances_outcomes(::Poll.kept.where(id: records.map(&:poll_id)))
      cache.add_reactions_for_itemables(records)
    end
  end

  class User < RecordCache::Loader
    def load; end
  end

  class Reader < RecordCache::Loader
    def load
      cache.user_ids.concat(records.map(&:user_id))
    end
  end

  class Comment < RecordCache::Loader
    def load
      cache.add_comments(records)
      cache.add_reactions_for_itemables(records)
    end
  end

  class MembershipRequest < RecordCache::Loader
    def load
      cache.user_ids.concat(records.map(&:requestor_id))
      cache.user_ids.concat(records.filter_map(&:responder_id))
    end
  end

  class SearchResult < RecordCache::Loader
    def load
      cache.user_ids.concat(records.map(&:author_id).compact)
      cache.add_polls_options_stances_outcomes(::Poll.kept.where(id: records.map(&:poll_id)))
    end
  end

  class TopicItem < RecordCache::Loader
    def load
      cache.add_topic_items_complete(records)
    end
  end
end
