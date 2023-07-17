class AddPollTemplateKeyAndIdToPolls < ActiveRecord::Migration[7.0]
  def change
    add_column :polls, :poll_template_id, :integer
    add_column :polls, :poll_template_key, :string
    Poll.update_all("poll_template_key = poll_type")
    Poll.where(poll_type: ['check']).each do |p|
      p.tags << 'Sense check'
    end
    Poll.where(poll_type: ['check']).update_all(poll_type: 'proposal')
  end
end
