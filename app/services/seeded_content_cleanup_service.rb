# Removes the example discussions and polls that Loomio created for new groups
# before automatic example content was retired in August 2023. Title matching
# identifies the seeded records, while activity checks preserve anything that
# members subsequently edited, commented on, voted in, or reacted to.
module SeededContentCleanupService
  CREATED_BEFORE = Date.new(2023, 8, 5)
  DELETE_BATCH_SIZE = 200

  HELPER_BOT_EMAILS = %w[
    contact@loom.io
    contact@loomio.com
    contact@loomio.org
    notifications@loomio.com
  ].freeze

  DISCUSSION_TITLES = [
    "How to use Loomio",
    "How To Use Loomio",
    "Intro to Loomio",
    "Comment utiliser Loomio",
    "Cómo usar Loomio",
    "Wie man Loomio benutzt",
    "Como utilizar o Loomio",
    "Come usare Loomio",
    "如何使用 Loomio",
    "Welcome! Please introduce yourself",
    "Bienvenue ! N'hésitez pas à vous présenter",
    "Bienvenue ! N'hésitez pas à vous présenter",
    "Bienvenid@! Por favor  preséntate al grupo",
    "Willkommen! Bitte stelle dich kurz vor",
    "Bem-vindo! Por favor, apresente-se",
    "Example Discussion: Welcome and introduction to Loomio",
    "Discusión de ejemplo: Bienvenida e introducción a Loomio",
    "Exemple de Discussion : Bienvenue et introduction sur Loomio",
    "Hoe gebruik je Loomio",
    "Como Utilizar o Loomio",
    "Benvenuto/a! Presentati",
    "Welkom! Stel jezelf alsjeblieft voor",
    "歡迎！請自我介紹",
    "Wie man Loomio benutzen kann",
    "Exemple de Discussion : Bienvenue et introduction à Loomio",
    "Discussão de exemplo: Boas vindas e Introdução ao Loomio",
    "討論範例: 歡迎並介紹 Loomio",
    "Jak korzystać z Loomio",
    "Beispieldiskussion: Willkommen und Einführung zu Loomio",
    "Як використовувати Loomio",
    "Velkommen, introducér dig selv",
    "איך להשתמש בלומיו",
    "Sådan bruger du Loomio",
    "Welcome and Introduction to Loomio!",
    "Вітаємо! Розкажіть про себе",
    "Példa téma: Üdvözlet és bevezetés a Loomióba",
    "Discussione Esempio: Benvenuto e introduzione a Loomio",
    "Exemple de discussió: Benvinguda i introducció a Loomio.",
    "Jak používat Loomio",
    "Vítejte! Prosím, představte se",
    "Voorbeeld Discussie: Welkom en introductie tot Loomio",
    "Πως να χρησιμοποιείς το Loomio",
    "Example Discussion: Welcome and introduction to Loomio!",
    "كيفية استخدام لوميو",
    "Diskussionsexempel: Välkommen och en introduktion till Loomio",
    "Hogyan kell használni a Loomio-t?",
    "Loomio Nasıl Kullanılır",
    "ברוך הבא! אנא הצג את עצמך",
    "Παράδειγμα Συζήτησης: Καλώς Ήρθατε και συστηθείτε στο Loomio",
    "Eksempeldiskussion: Velkommen og introduktion til Loomio",
    "Ukázková diskuze: Přivítání a úvod do Loomio"
  ].freeze

  DISCUSSION_TITLE_PREFIXES = [
    "Welcome to ", "Bienvenue dans ", "Bienvenida/o a ", "Bem-vindo ao ",
    "Willkommen bei ", "歡迎來到 ", "Benvenuto su ", "Welkom bij ",
    "Καλωσήλθες στην ομάδα ", "أهلا بك في ", "Benvingut a ",
    "Vítejte v ", "Запрашаем у "
  ].freeze
  DISCUSSION_TITLE_SUFFIXES = [ " grubuna hoşgeldiniz" ].freeze

  POLL_TITLES = [
    "Demonstration proposal",
    "Have any questions about using Loomio?",
    "Proposition de démonstration",
    "Demonstration proposal: let’s go!",
    "We should have a holiday on the moon!",
    "Propuesta de demostración",
    "¿Tienes alguna pregunta acerca de cómo usar Loomio?",
    "Demo-Vorschlag",
    "Vous avez des questions sur l'utilisation de Loomio ?",
    "Proposta de demonstração",
    "Propuesta de demostración: Aquí vamos!  ",
    "Proposta dimostrativa",
    "Proposition de démonstration: c'est parti!",
    "¡Deberíamos irnos de vacaciones a la luna!",
    "Proposition de démonstration: c’est parti!",
    "提案範例",
    "Proposta demonstração: vamos lá!",
    "Hast du Fragen zur Verwendung von Loomio?",
    "Demonstratievoorstel",
    "Versuchsvorschlag: letz gouuu!",
    "Demonstratie voorstel",
    "Masz pytania dotyczące korzystania z Loomio?",
    "Heb je vragen over het gebruik van Loomio?",
    "Приклад пропозиції",
    "Nous devrions passer nos vacances sur la Lune !",
    "有任何關於使用 Loomio 的問題嗎？",
    "示範提案：走吧！",
    "Demonstrations forslag",
    "Proposta di prova: andiamo!",
    "Ukázkový návrh",
    "Nós devíamos passar as férias na lua!",
    "הדגמת הצעה",
    "Bemutató javaslat",
    "Dovremmo andare in vacanza sulla Luna!",
    "مقترح تجريبي: هيا بنا! ",
    "We should have a holiday on the moon",
    "Wir sollten Urlaub auf dem Mond machen!",
    "Hauríem d'anar de vacances a la Lluna!",
    "We zouden een vakantie op de maan moeten houden!",
    "Deberíamos irnos de vacaciones a la luna!",
    "Demo önerisi: Haydi gidelim!",
    "Proposta de demostració: som-hi!",
    "Menjünk nyaralni a Holdra!",
    "您應該去月球度個假！",
    "Ми маємо відпочивати на місяці!",
    "Vi borde åka på semester till månen!",
    "Ay üzerinde bir tatil yapmalıyız!",
    "Tem alguma dúvida sobre como usar o Loomio?",
    "How is your experience with Loomio so far?"
  ].freeze

  def self.audit
    result = {
      discussions: candidate_discussions.distinct.count,
      polls: candidate_polls.distinct.count
    }
    puts "Seeded discussions eligible for deletion: #{result[:discussions]}"
    puts "Seeded polls eligible for deletion:       #{result[:polls]}"
    result
  end

  # Topics are destroyed in bounded transactions so dependent records, counter
  # caches, and search documents are removed together without paying for one
  # database commit per topic. Polls embedded in an eligible discussion are
  # removed with that discussion's topic.
  def self.delete!(limit: nil, batch_size: DELETE_BATCH_SIZE, content_type: nil, shard_count: 1, shard_index: 0)
    unless [ nil, "discussions", "polls" ].include?(content_type)
      raise ArgumentError, "content_type must be discussions or polls"
    end
    unless shard_count.positive? && shard_index.between?(0, shard_count - 1)
      raise ArgumentError, "shard_index must be between 0 and shard_count - 1"
    end

    discussion_scope = shard(
      candidate_discussions,
      record_type: "Discussion",
      count: shard_count,
      index: shard_index
    )
    poll_scope = shard(
      candidate_polls,
      record_type: "Poll",
      count: shard_count,
      index: shard_index
    )
    discussion_ids = content_type == "polls" ? [] : discussion_scope.order(:id).limit(limit).pluck(:id)
    poll_ids = content_type == "discussions" ? [] : poll_scope.order(:id).limit(limit).pluck(:id)
    discussions_deleted = 0
    polls_deleted = 0

    PaperTrail.request(enabled: false) do
      discussion_ids.each_slice(batch_size) do |ids|
        Discussion.transaction do
          discussions_by_id = discussion_scope.where(id: ids).lock.index_by(&:id)
          ids.each do |id|
            discussion = discussions_by_id[id]
            next unless discussion

            discussion.topic.destroy!
            discussions_deleted += 1
          end
        end
      end

      poll_ids_remaining = Poll.where(id: poll_ids).pluck(:id)
      polls_deleted = poll_ids.length - poll_ids_remaining.length
      poll_ids_remaining.each_slice(batch_size) do |ids|
        Poll.transaction do
          polls_by_id = poll_scope.where(id: ids).lock.index_by(&:id)
          ids.each do |id|
            poll = polls_by_id[id]
            next unless poll

            if poll.topic.topicable_type == "Poll" && poll.topic.topicable_id == poll.id
              poll.topic.destroy!
            else
              poll.destroy!
            end
            polls_deleted += 1
          end
        end
      end
    end

    result = { discussions: discussions_deleted, polls: polls_deleted }
    puts "Deleted #{result[:discussions]} seeded discussions and #{result[:polls]} seeded polls"
    result
  end

  def self.candidate_discussions
    scope = Discussion.joins(topic: :group)
      .where("discussions.created_at < ?", CREATED_BEFORE)
      .where(discussions: { discarded_at: nil }, topics: { discarded_at: nil })
      .where(discussion_title_condition)
    scope = without_additional_topic_activity(
      scope,
      record_type: "Discussion",
      record_table: "discussions",
      root_kind: "new_discussion"
    )
    scope = without_additional_votes(scope)
    scope = without_anonymous_votes(scope)
    scope = without_outcomes(scope)
    scope = without_member_reactions(scope, record_type: "Discussion")
    scope = without_poll_reactions(scope)
    scope = without_member_edits(scope, item_type: "Discussion", record_table: "discussions")
    scope = without_attached_poll_edits(scope)
    scope.where(<<~SQL.squish, poll_titles: POLL_TITLES)
      NOT EXISTS (
        SELECT 1 FROM polls attached_polls
        WHERE attached_polls.topic_id = topics.id
          AND attached_polls.title NOT IN (:poll_titles)
      )
    SQL
  end

  def self.candidate_polls
    scope = Poll.joins(:topic)
      .where("polls.created_at < ?", CREATED_BEFORE)
      .where(polls: { title: POLL_TITLES, discarded_at: nil }, topics: { discarded_at: nil })
    scope = without_additional_topic_activity(
      scope,
      record_type: "Poll",
      record_table: "polls",
      root_kind: "poll_created"
    )
    scope = without_additional_votes(scope)
    scope = without_anonymous_votes(scope)
    scope = without_outcomes(scope)
    scope = without_member_reactions(scope, record_type: "Poll")
    scope = without_poll_reactions(scope)
    scope = without_member_edits(scope, item_type: "Poll", record_table: "polls")
    scope
  end

  def self.discussion_title_condition
    clauses = [ "discussions.title IN (?)" ]
    binds = [ DISCUSSION_TITLES ]
    DISCUSSION_TITLE_PREFIXES.each do |prefix|
      clauses << "discussions.title = CONCAT(CAST(? AS text), groups.name)"
      binds << prefix
    end
    DISCUSSION_TITLE_SUFFIXES.each do |suffix|
      clauses << "discussions.title = CONCAT(groups.name, CAST(? AS text))"
      binds << suffix
    end
    [ clauses.join(" OR "), *binds ]
  end

  def self.without_additional_topic_activity(scope, record_type:, record_table:, root_kind:)
    record_id = case record_table
    when "discussions" then "discussions.id"
    when "polls" then "polls.id"
    else raise ArgumentError, "unsupported record table"
    end
    condition = ActiveRecord::Base.sanitize_sql_array([ <<~SQL.squish, helper_bot_ids: helper_bot_ids, record_type: record_type, root_kind: root_kind ])
      NOT EXISTS (
        SELECT 1 FROM topic_items
        WHERE topic_items.topic_id = topics.id
          AND topic_items.user_id IS NOT NULL
          AND topic_items.user_id NOT IN (:helper_bot_ids)
          AND NOT (
            topic_items.itemable_type = :record_type
            AND topic_items.itemable_id = RECORD_ID
            AND topic_items.kind = :root_kind
          )
      )
    SQL
    scope.where(Arel.sql(condition.sub("RECORD_ID", record_id)))
  end

  def self.without_additional_votes(scope)
    scope.where(<<~SQL.squish, helper_bot_ids: helper_bot_ids)
      NOT EXISTS (
        SELECT 1 FROM polls activity_polls
        JOIN stances ON stances.poll_id = activity_polls.id
        WHERE activity_polls.topic_id = topics.id
          AND stances.cast_at IS NOT NULL
          AND (stances.participant_id IS NULL OR stances.participant_id NOT IN (:helper_bot_ids))
      )
    SQL
  end

  def self.without_anonymous_votes(scope)
    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM polls anonymous_polls
        JOIN anonymous_ballots ON anonymous_ballots.poll_id = anonymous_polls.id
        WHERE anonymous_polls.topic_id = topics.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM polls anonymous_polls
        JOIN anonymous_poll_voters ON anonymous_poll_voters.poll_id = anonymous_polls.id
        WHERE anonymous_polls.topic_id = topics.id
          AND anonymous_poll_voters.ballot_submitted = TRUE
      )
    SQL
  end

  def self.without_outcomes(scope)
    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM polls outcome_polls
        JOIN outcomes ON outcomes.poll_id = outcome_polls.id
        WHERE outcome_polls.topic_id = topics.id
      )
    SQL
  end

  def self.without_member_reactions(scope, record_type:)
    record_id = case record_type
    when "Discussion" then "discussions.id"
    when "Poll" then "polls.id"
    else raise ArgumentError, "unsupported record type"
    end
    condition = ActiveRecord::Base.sanitize_sql_array([ <<~SQL.squish, helper_bot_ids: helper_bot_ids, record_type: record_type ])
      NOT EXISTS (
        SELECT 1 FROM topic_items reaction_items
        JOIN reactions
          ON reactions.reactable_type = reaction_items.itemable_type
         AND reactions.reactable_id = reaction_items.itemable_id
        WHERE reaction_items.topic_id = topics.id
          AND reactions.user_id NOT IN (:helper_bot_ids)
      )
      AND NOT EXISTS (
        SELECT 1 FROM reactions
        WHERE reactions.user_id NOT IN (:helper_bot_ids)
          AND reactions.reactable_type = :record_type
          AND reactions.reactable_id = RECORD_ID
      )
    SQL
    scope.where(Arel.sql(condition.sub("RECORD_ID", record_id)))
  end

  def self.without_poll_reactions(scope)
    scope.where(<<~SQL.squish, helper_bot_ids: helper_bot_ids)
      NOT EXISTS (
        SELECT 1 FROM polls activity_polls
        JOIN reactions
          ON reactions.reactable_type = 'Poll'
         AND reactions.reactable_id = activity_polls.id
        WHERE activity_polls.topic_id = topics.id
          AND reactions.user_id NOT IN (:helper_bot_ids)
      )
      AND NOT EXISTS (
        SELECT 1 FROM polls activity_polls
        JOIN stances ON stances.poll_id = activity_polls.id
        JOIN reactions
          ON reactions.reactable_type = 'Stance'
         AND reactions.reactable_id = stances.id
        WHERE activity_polls.topic_id = topics.id
          AND reactions.user_id NOT IN (:helper_bot_ids)
      )
      AND NOT EXISTS (
        SELECT 1 FROM polls activity_polls
        JOIN outcomes ON outcomes.poll_id = activity_polls.id
        JOIN reactions
          ON reactions.reactable_type = 'Outcome'
         AND reactions.reactable_id = outcomes.id
        WHERE activity_polls.topic_id = topics.id
          AND reactions.user_id NOT IN (:helper_bot_ids)
      )
    SQL
  end

  def self.without_member_edits(scope, item_type:, record_table:)
    record_id = case record_table
    when "discussions" then "discussions.id"
    when "polls" then "polls.id"
    else raise ArgumentError, "unsupported record table"
    end
    condition = ActiveRecord::Base.sanitize_sql_array([ <<~SQL.squish, helper_bot_ids: helper_bot_ids, item_type: item_type ])
      NOT EXISTS (
        SELECT 1 FROM versions
        WHERE versions.item_type = :item_type
          AND versions.item_id = RECORD_ID
          AND versions.event = 'update'
          AND versions.whodunnit IS NOT NULL
          AND versions.whodunnit NOT IN (:helper_bot_ids)
      )
    SQL
    scope.where(Arel.sql(condition.sub("RECORD_ID", record_id)))
  end

  def self.without_attached_poll_edits(scope)
    scope.where(<<~SQL.squish, helper_bot_ids: helper_bot_ids)
      NOT EXISTS (
        SELECT 1 FROM versions
        JOIN polls edited_polls
          ON versions.item_type = 'Poll'
         AND versions.item_id = edited_polls.id
        WHERE edited_polls.topic_id = topics.id
          AND versions.event = 'update'
          AND versions.whodunnit IS NOT NULL
          AND versions.whodunnit NOT IN (:helper_bot_ids)
      )
    SQL
  end

  def self.helper_bot_ids
    @helper_bot_ids ||= User.where(email: HELPER_BOT_EMAILS).pluck(:id).presence || [ -1 ]
  end

  def self.shard(scope, record_type:, count:, index:)
    return scope if count == 1

    condition = case record_type
    when "Discussion" then "MOD(COALESCE(topics.group_id, discussions.id), ?) = ?"
    when "Poll" then "MOD(COALESCE(topics.group_id, polls.id), ?) = ?"
    else raise ArgumentError, "unsupported record type"
    end
    scope.where(condition, count, index)
  end

  private_class_method :discussion_title_condition, :without_additional_topic_activity,
                       :without_additional_votes, :without_anonymous_votes,
                       :without_outcomes, :without_member_reactions,
                       :without_poll_reactions, :without_member_edits,
                       :without_attached_poll_edits, :helper_bot_ids, :shard
end
