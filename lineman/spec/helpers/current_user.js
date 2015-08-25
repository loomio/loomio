window.useCurrentUser = function(user) {
  window.Loomio = { permittedParams: {'user': []},  seedRecords: [], currentUserId: user.id }
}
