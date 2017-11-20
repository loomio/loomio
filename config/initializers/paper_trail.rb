# kick specified messages to the version's item
PaperTrail::Version.send :delegate, :mailer, to: :item
PaperTrail::Version.send :delegate, :poll, to: :item
