class AddTryLoomioToPracticeThreadTemplates < ActiveRecord::Migration[8.0]
  def up
    DiscussionTemplate.where(key: 'practice_thread').find_each do |dt|
      unless dt.poll_template_keys_or_ids.include?('try_loomio')
        dt.update_column(:poll_template_keys_or_ids, dt.poll_template_keys_or_ids + ['try_loomio'])
      end
    end
  end

  def down
    DiscussionTemplate.where(key: 'practice_thread').find_each do |dt|
      if dt.poll_template_keys_or_ids.include?('try_loomio')
        dt.update_column(:poll_template_keys_or_ids, dt.poll_template_keys_or_ids - ['try_loomio'])
      end
    end
  end
end
