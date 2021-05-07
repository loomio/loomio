import { pickBy, identity, isEqual } from 'lodash'
import {
  mdiAccount,
  mdiAccountGroup,
  mdiAccountMultiple,
  mdiAccountMultiplePlus,
  mdiAccountSearch,
  mdiAlarmCheck,
  mdiArrowLeft,
  mdiArrowRight,
  mdiBell,
  mdiCalendar,
  mdiCalendarQuestion,
  mdiCallSplit,
  mdiCamera,
  mdiCards,
  mdiChartBar,
  mdiChartBarStacked,
  mdiChartGantt,
  mdiCheck,
  mdiCheckCircle,
  mdiChevronLeft,
  mdiChevronRight,
  mdiClockOutline,
  mdiClose,
  mdiCloseCircleOutline,
  mdiCodeBraces,
  mdiCog,
  mdiCogOutline,
  mdiCollage,
  mdiComment,
  mdiCommentMultiple,
  mdiCommentTextOutline,
  mdiDatabaseExport,
  mdiDelete,
  mdiDeleteRestore,
  mdiDirectionsFork,
  mdiDotsVertical,
  mdiDotsHorizontal,
  mdiDragVertical,
  mdiEarth,
  mdiEmailOutline,
  mdiEmoticonOutline,
  mdiExitRun,
  mdiExitToApp,
  mdiEye,
  mdiFacebook,
  mdiFile,
  mdiFileDocument,
  mdiFileExcelBox,
  mdiFilePdfBox,
  mdiFileVideo,
  mdiFileWordBox,
  mdiFlaskEmptyOffOutline,
  mdiFlaskOutline,
  mdiFolderSwapOutline,
  mdiFormatAlignCenter,
  mdiFormatAlignLeft,
  mdiFormatAlignRight,
  mdiFormatBold,
  mdiFormatHeader1,
  mdiFormatHeader2,
  mdiFormatHeader3,
  mdiFormatItalic,
  mdiFormatListBulleted,
  mdiFormatListChecks,
  mdiFormatListNumbered,
  mdiFormatPilcrow,
  mdiFormatQuoteClose,
  mdiFormatSize,
  mdiFormatStrikethrough,
  mdiFormatUnderline,
  mdiForum,
  mdiGoogle,
  mdiGoogleDrive,
  mdiHelpCircleOutline,
  mdiHistory,
  mdiImage,
  mdiInformationOutline,
  mdiKeyVariant,
  mdiLanguageMarkdownOutline,
  mdiLightbulbOnOutline,
  mdiLink,
  mdiLockOutline,
  mdiLockReset,
  mdiMagnify,
  mdiMenu,
  mdiMenuDown,
  mdiMinus,
  mdiPalette,
  mdiPaperclip,
  mdiPencil,
  mdiPin,
  mdiPinOff,
  mdiPlus,
  mdiPoll,
  mdiRefresh,
  mdiReply,
  mdiRocket,
  mdiSend,
  mdiShieldStar,
  mdiSourcePull,
  mdiTable,
  mdiTableColumnPlusAfter,
  mdiTableColumnPlusBefore,
  mdiTableColumnRemove,
  mdiTableMergeCells,
  mdiTableRemove,
  mdiTableRowPlusAfter,
  mdiTableRowPlusBefore,
  mdiTableRowRemove,
  mdiTagOutline,
  mdiTagPlus,
  mdiThumbsUpDown,
  mdiTranslate,
  mdiUnfoldMoreHorizontal,
  mdiVideo,
  mdiWeatherNight,
  mdiWebhook,
  mdiWhiteBalanceSunny,
  mdiWindowClose,
  mdiYoutube
} from '@mdi/js'

export default
  computed:
    $icons: ->
      'mdi-account': mdiAccount
      'mdi-account-group': mdiAccountGroup
      'mdi-account-multiple': mdiAccountMultiple
      'mdi-account-multiple-plus': mdiAccountMultiplePlus
      'mdi-account-search': mdiAccountSearch
      'mdi-alarm-check': mdiAlarmCheck
      'mdi-arrow-left': mdiArrowLeft
      'mdi-arrow-right': mdiArrowRight
      'mdi-bell': mdiBell
      'mdi-calendar': mdiCalendar
      'mdi-calendar-question': mdiCalendarQuestion
      'mdi-call-split': mdiCallSplit
      'mdi-camera': mdiCamera
      'mdi-cards': mdiCards
      'mdi-chart-bar': mdiChartBar
      'mdi-chart-bar-stacked': mdiChartBarStacked
      'mdi-chart-gantt': mdiChartGantt
      'mdi-check': mdiCheck
      'mdi-check-circle': mdiCheckCircle
      'mdi-chevron-left': mdiChevronLeft
      'mdi-chevron-right': mdiChevronRight
      'mdi-clock-outline': mdiClockOutline
      'mdi-close': mdiClose
      'mdi-close-circle-outline': mdiCloseCircleOutline
      'mdi-code-braces': mdiCodeBraces
      'mdi-cog': mdiCog
      'mdi-cog-outline': mdiCogOutline
      'mdi-collage': mdiCollage
      'mdi-comment': mdiComment
      'mdi-comment-multiple': mdiCommentMultiple
      'mdi-comment-text-outline': mdiCommentTextOutline
      'mdi-database-export': mdiDatabaseExport
      'mdi-delete': mdiDelete
      'mdi-delete-restore': mdiDeleteRestore
      'mdi-directions-fork': mdiDirectionsFork
      'mdi-dots-vertical': mdiDotsVertical
      'mdi-dots-horizontal': mdiDotsHorizontal
      'mdi-drag-vertical': mdiDragVertical
      'mdi-earth': mdiEarth
      'mdi-email-outline': mdiEmailOutline
      'mdi-emoticon-outline': mdiEmoticonOutline
      'mdi-exit-run': mdiExitRun
      'mdi-exit-to-app': mdiExitToApp
      'mdi-eye': mdiEye
      'mdi-facebook': mdiFacebook
      'mdi-file': mdiFile
      'mdi-file-document': mdiFileDocument
      'mdi-file-excel-box': mdiFileExcelBox
      'mdi-file-pdf-box': mdiFilePdfBox
      'mdi-file-video': mdiFileVideo
      'mdi-file-word-box': mdiFileWordBox
      'mdi-flask-empty-off-outline': mdiFlaskEmptyOffOutline
      'mdi-flask-outline': mdiFlaskOutline
      'mdi-folder-swap-outline': mdiFolderSwapOutline
      'mdi-format-align-center': mdiFormatAlignCenter
      'mdi-format-align-left': mdiFormatAlignLeft
      'mdi-format-align-right': mdiFormatAlignRight
      'mdi-format-bold': mdiFormatBold
      'mdi-format-header-1': mdiFormatHeader1
      'mdi-format-header-2': mdiFormatHeader2
      'mdi-format-header-3': mdiFormatHeader3
      'mdi-format-italic': mdiFormatItalic
      'mdi-format-list-bulleted': mdiFormatListBulleted
      'mdi-format-list-checks': mdiFormatListChecks
      'mdi-format-list-numbered': mdiFormatListNumbered
      'mdi-format-pilcrow': mdiFormatPilcrow
      'mdi-format-quote-close': mdiFormatQuoteClose
      'mdi-format-size': mdiFormatSize
      'mdi-format-strikethrough': mdiFormatStrikethrough
      'mdi-format-underline': mdiFormatUnderline
      'mdi-forum': mdiForum
      'mdi-google': mdiGoogle
      'mdi-google-drive': mdiGoogleDrive
      'mdi-help-circle-outline': mdiHelpCircleOutline
      'mdi-history': mdiHistory
      'mdi-image': mdiImage
      'mdi-information-outline': mdiInformationOutline
      'mdi-key-variant': mdiKeyVariant
      'mdi-language-markdown-outline': mdiLanguageMarkdownOutline
      'mdi-lightbulb-on-outline': mdiLightbulbOnOutline
      'mdi-link': mdiLink
      'mdi-lock-outline': mdiLockOutline
      'mdi-lock-reset': mdiLockReset
      'mdi-magnify': mdiMagnify
      'mdi-menu': mdiMenu
      'mdi-menu-down': mdiMenuDown
      'mdi-minus': mdiMinus
      'mdi-palette': mdiPalette
      'mdi-paperclip': mdiPaperclip
      'mdi-pencil': mdiPencil
      'mdi-pin': mdiPin
      'mdi-pin-off': mdiPinOff
      'mdi-plus': mdiPlus
      'mdi-poll': mdiPoll
      'mdi-refresh': mdiRefresh
      'mdi-reply': mdiReply
      'mdi-rocket': mdiRocket
      'mdi-send': mdiSend
      'mdi-shield-star': mdiShieldStar
      'mdi-source-pull': mdiSourcePull
      'mdi-table': mdiTable
      'mdi-table-column-plus-after': mdiTableColumnPlusAfter
      'mdi-table-column-plus-before': mdiTableColumnPlusBefore
      'mdi-table-column-remove': mdiTableColumnRemove
      'mdi-table-merge-cells': mdiTableMergeCells
      'mdi-table-remove': mdiTableRemove
      'mdi-table-row-plus-after': mdiTableRowPlusAfter
      'mdi-table-row-plus-before': mdiTableRowPlusBefore
      'mdi-table-row-remove': mdiTableRowRemove
      'mdi-tag-outline': mdiTagOutline
      'mdi-tag-plus': mdiTagPlus
      'mdi-thumbs-up-down': mdiThumbsUpDown
      'mdi-translate': mdiTranslate
      'mdi-unfold-more-horizontal': mdiUnfoldMoreHorizontal
      'mdi-video': mdiVideo
      'mdi-weather-night': mdiWeatherNight
      'mdi-webhook': mdiWebhook
      'mdi-white-balance-sunny': mdiWhiteBalanceSunny
      'mdi-window-close': mdiWindowClose
      'mdi-youtube': mdiYoutube
