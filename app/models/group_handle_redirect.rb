class GroupHandleRedirect < ApplicationRecord
  belongs_to :group

  validates :handle, presence: true, uniqueness: true
  validate :handle_is_not_current_group_handle
  validate :handle_is_not_current_handle_of_any_group

  before_validation :parameterize_handle

  private

  def parameterize_handle
    self.handle = handle.to_s.strip.parameterize.presence if handle.present?
  end

  def handle_is_not_current_group_handle
    errors.add(:handle, :taken) if group&.handle == handle
  end

  def handle_is_not_current_handle_of_any_group
    errors.add(:handle, :taken) if Group.where(handle: handle).where.not(id: group_id).exists?
  end
end
