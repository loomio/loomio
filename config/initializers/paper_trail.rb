# kick the mailer message to the version's item
PaperTrail::Version.send :delegate, :mailer, to: :item
