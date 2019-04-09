import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
# import AbilityService from '@/shared/services/ability_service'
# import LmoUrlService  from '@/shared/services/lmo_url_service'
# import ModalService   from '@/shared/services/modal_service'

import { hardReload } from '@/shared/helpers/window'

# A series of actions relating to updating the current user, such as signing in
# or changing the app's locale
export signIn = (data, userId, afterSignIn) =>
    Records.import(data)
    Session.signIn(userId)
    AppConfig.pendingIdentity = data.pending_identity
    afterSignIn() if typeof afterSignIn is 'function'

export signOut = ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

export getProviderIdentity = ->
    validProviders = _.map(AppConfig.identityProviders, 'name')
    AppConfig.pendingIdentity if _.includes(validProviders, AppConfig.pendingIdentity.identity_type)
