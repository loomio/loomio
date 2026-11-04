# Entry points for controllers authenticated with the server API key. These
# operations intentionally have no user actor or group-membership requirement.
class ServerMembershipService
  class InvalidParameters < StandardError; end

  def self.boolean(value)
    return true if [ true, 1, '1', 'true' ].include?(value)
    return false if [ false, 0, '0', 'false' ].include?(value)

    raise InvalidParameters, 'Expected a boolean'
  end

  # Validate the complete desired set before creating accounts or revoking
  # access. Lock affected users in the same order as the membership lifecycle;
  # account creation, invitations, removals and notifications commit together.
  def self.sync(group:, emails:, remove_absent: false)
    unless emails.is_a?(Array) && emails.all? { |email| email.is_a?(String) }
      raise InvalidParameters, 'emails must be an array of email addresses'
    end
    emails = emails.map { |email| email.strip.downcase }.uniq
    unless emails.all? { |email| email.length <= 200 && EmailValidator::EMAIL_REGEXP.match?(email) }
      raise InvalidParameters, 'emails contains an invalid email address'
    end
    remove_absent = boolean(remove_absent)
    raise Subscription::NotActive unless group.enabled?

    Membership.transaction do
      emails.sort.each { |email| User.find_or_create_by!(email: email) }

      users = User.where(email: emails)
      affected_users = User.where(id: group.memberships.select(:user_id)).or(users)
      affected_users.order(:id).with_write_lock(:id) do
        # Check after acquiring user locks so a concurrent deactivation cannot
        # finish between the account check and the membership insertion.
        if inactive_user = users.deactivated.first
          inactive_user.errors.add(:email, 'belongs to a deactivated account')
          raise ActiveRecord::RecordInvalid, inactive_user
        end

        current_emails = group.memberships.joins(:user).pluck('users.email')
        added_emails = emails - current_emails
        removed_emails = remove_absent ? current_emails - emails : []

        group.memberships.joins(:user).where(users: { email: removed_emails }).each do |membership|
          revoke(membership: membership)
        end

        if added_emails.any?
          UserInviter.check_members_limit!(parent_group: group.parent_or_self, emails: added_emails, user_ids: [])
          GroupService.invite_users(
            group: group,
            users: users.where(email: added_emails),
            group_ids: [ group.id ],
            actor: nil
          )
        end

        { added_emails: added_emails, removed_emails: removed_emails }
      end
    end
  end

  def self.revoke(membership:)
    group = Group.kept.find(membership.group_id)
    MembershipService.revoke_by_id(group.id_and_subgroup_ids, membership.user_id, nil)
  end

  # Role notifications and denormalized delegate titles belong to the same
  # transaction as the role change. Retries do not send duplicate notifications.
  def self.update(membership:, params:)
    raise InvalidParameters, 'Provide admin or delegate' if params.empty?
    attributes = params.transform_values { |value| boolean(value) }
    raise Subscription::NotActive unless membership.group.enabled?

    User.where(id: membership.user_id).with_write_lock(:id) do
      membership.reload
      raise ActiveRecord::RecordNotFound if membership.revoked_at?

      membership.update!(attributes)
      { admin: 'new_coordinator', delegate: 'new_delegate' }.each do |field, kind|
        if membership.saved_change_to_attribute?(field) && membership.public_send(field)
          NotificationService.create!(kind: kind, subject: membership, actor: nil)
        end
      end
      MembershipService.update_user_titles(membership.id) if membership.saved_change_to_delegate?
      ActiveRecord.after_all_transactions_commit do
        MessageChannelService.publish_models([ membership.user ], serializer: AuthorSerializer, group_id: membership.group_id)
      end
    end
    membership
  end
end
