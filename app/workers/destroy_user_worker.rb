class DestroyUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find_by!(id: user_id)
    user.deactivate!
    user.identities.delete_all
    zombie = User.create(name: I18n.t(:'user.deleted_user'),
                         email: "deleted-user-#{SecureRandom.uuid}@example.com")
    zombie.update(deactivated_at: Time.now)
    MigrateUserWorker.new.perform(user.id, zombie.id)
    user.reload.destroy
    EventBus.broadcast 'user_destroy', user, zombie
    zombie
  end
end
