class PublicResponsePolicy < ApplicationPolicy
  RESPONSES = %i[
    boot_version
  ].freeze

  def show?
    RESPONSES.include?(record)
  end
end
