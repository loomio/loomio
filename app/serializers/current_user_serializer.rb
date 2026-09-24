class CurrentUserSerializer < UserSerializer
  attributes :email, :email_change_pending, :email_catch_up_day, :selected_locale, :locale,
             :volume_email_default, :volume_push_default, :experiences,
             :email_newsletter, :is_admin, :memberships_count, :secret_token, :auto_translate,
             :legal_accepted_at, :legal_acceptance_required, :has_passkey

  def legal_acceptance_required
    object.legal_acceptance_required?
  end

  def has_passkey
    object.has_passkey?
  end

  def include_email?
    true
  end

  def include_email_hash?
    true
  end

  def include_has_password?
    true
  end

  private

  def from_scope(field)
    Array(Hash(scope)[field])
  end
end
