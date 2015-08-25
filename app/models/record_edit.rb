class RecordEdit < ActiveRecord::Base

  belongs_to :record, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id' #duplicate author relationship for eager loading via discussion.items
  has_one    :event, as: :eventable

  validates_presence_of :author, :record

  def self.capture(record, author)
    record_edit = self.new
    record_edit.record = record
    record_edit.author = author
    record_edit.previous_values = record.changed_attributes
    record_edit.new_values = {}
    record_edit.previous_values.each_pair do |k, v|
      record_edit.new_values[k] = record.send(k)
    end
    record_edit
  end

  def self.capture!(record, author)
    record_edit = self.capture(record, author)
    record_edit.save!
    record_edit
  end
end
