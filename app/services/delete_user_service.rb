class DeleteUserService
  def self.delete!(user)
    user.deactivate!
    zombie = User.create(name: I18n.t(:'user.deleted_user'),
                         email: "deleted-user-#{rand(10**10)}@example.com")
    MigrateUserService.migrate!(source: user, destination: zombie)
    user.reload.destroy
    zombie
  end
end
