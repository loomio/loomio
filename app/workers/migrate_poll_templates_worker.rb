class MigratePollTemplatesWorker
  include Sidekiq::Worker

  def perform
    Poll.where(template: true).where("group_id is not null").find_each do |p|
      pt = PollTemplate.new

      [
        :group_id,
        :author_id,
        :poll_type,
        :process_name,
        :process_subtitle,
        :title,
        :details,
        :details_format,
        :anonymous,
        :specified_voters_only,
        :notify_on_closing_soon,
        :content_locale,
        :shuffle_options,
        :hide_results,
        :chart_type,
        :min_score,
        :max_score,
        :minimum_stance_choices,
        :maximum_stance_choices,
        :dots_per_person,
        :reason_prompt,
        :stance_reason_required,
        :limit_reason_length,
        :agree_target,
        :created_at,
        :updated_at,
        :meeting_duration,
        :can_respond_maybe,
        :poll_option_name_format,
        :tags].each do |field|
        pt[field] = p.send(field)
      end

      pt[:default_duration_in_days] = 7

      pt.poll_options = p.poll_options.map do |o|
        {
          name: o.name,
          meaning: o.meaning, 
          prompt: o.prompt, 
          icon: o.icon
        }
      end

      pt.save!

    end
  end
end