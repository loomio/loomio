class UpdatePollOptionAttributes < ActiveRecord::Migration[6.1]
  def change
    Poll.where(poll_type: 'proposal').update_all(poll_option_name_format: 'i18n')
    Poll.where(poll_type: 'count').update_all(poll_option_name_format: 'i18n')
    Poll.where(poll_type: 'meeting').update_all(poll_option_name_format: 'iso8601')
  end
end
