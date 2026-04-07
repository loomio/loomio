# frozen_string_literal: true

class Views::UserMailer::CatchUp::Headlines < Views::ApplicationMailer::Component
  include PrettyUrlHelper

  def initialize(groups:, topics_by_group_id:, recipient:, utm_hash:)
    @groups = groups
    @topics_by_group_id = topics_by_group_id
    @recipient = recipient
    @utm_hash = utm_hash
  end

  def view_template
    @groups.each do |group|
      next unless @topics_by_group_id.has_key?(group.id)

      h3 { link_to group.full_name, group_url(group, @utm_hash) }
      ul do
        @topics_by_group_id[group.id].each do |topic|
          li { link_to TranslationService.plain_text(topic.topicable, :title, @recipient), topicable_url(topic) }
        end
      end
    end
  end

  private

  def topicable_url(topic)
    if topic.topicable.is_a?(Discussion)
      discussion_url(topic.topicable)
    elsif topic.topicable.is_a?(Poll)
      polymorphic_url(topic.topicable)
    end
  end
end
