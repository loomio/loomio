class DecodeHtmlEntitiesInEventRecipientMessage < ActiveRecord::Migration[6.1]
  def change
    Event.where.not(custom_fields: {}).find_each do |e|
      next unless e.recipient_message.present?
      fields = e.custom_fields

      fields['recipient_message'] = CGI.unescapeHTML(fields['recipient_message'])
      # puts "was: #{e.recipient_message}, now: #{fields['recipient_message']}"
      e.update_columns(custom_fields: fields)
    end
  end
end
