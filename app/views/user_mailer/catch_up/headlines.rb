# frozen_string_literal: true

class Views::UserMailer::CatchUp::Headlines < Views::ApplicationMailer::Base
  include PrettyUrlHelper

  def initialize(groups:, discussions_by_group_id:, recipient:, utm_hash:)
    @groups = groups
    @discussions_by_group_id = discussions_by_group_id
    @recipient = recipient
    @utm_hash = utm_hash
  end

  def view_template
    @groups.each do |group|
      next unless @discussions_by_group_id.has_key?(group.id)

      h3 { link_to group.full_name, group_url(group, @utm_hash) }
      ul do
        @discussions_by_group_id[group.id].each do |discussion|
          li { link_to TranslationService.plain_text(discussion, :title, @recipient), discussion_url(discussion) }
        end
      end
    end
  end
end
