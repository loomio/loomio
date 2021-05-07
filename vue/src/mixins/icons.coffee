import { pickBy, identity, isEqual } from 'lodash'
import {
  MdiAccount,
  MdiAccountGroup,
  MdiAccountMultiple,
  MdiAccountMultiplePlus,
  MdiAccountSearch,
  MdiAlarmCheck,
  MdiArrowLeft,
  MdiArrowRight,
  MdiBell,
  MdiCalendar,
  MdiCalendarQuestion,
  MdiCallSplit,
  MdiCamera,
  MdiCards,
  MdiChartBar,
  MdiChartBarStacked,
  MdiChartGantt,
  MdiCheck,
  MdiCheckCircle,
  MdiChevronLeft,
  MdiChevronRight,
  MdiClockOutline,
  MdiClose,
  MdiCloseCircleOutline,
  MdiCodeBraces,
  MdiCog,
  MdiCogOutline,
  MdiCollage,
  MdiComment,
  MdiCommentMultiple,
  MdiCommentTextOutline,
  MdiDatabaseExport,
  MdiDelete,
  MdiDeleteRestore,
  MdiDirectionsFork,
  MdiDotsVertical,
  MdiDragVertical,
  MdiEarth,
  MdiEmailOutline,
  MdiEmoticonOutline,
  MdiExitRun,
  MdiExitToApp,
  MdiEye,
  MdiFacebook,
  MdiFile,
  MdiFileDocument,
  MdiFileDocumentBox,
  MdiFileExcelBox,
  MdiFilePdfBox,
  MdiFileVideo,
  MdiFileWordBox,
  MdiFlaskEmptyOffOutline,
  MdiFlaskOutline,
  MdiFolderSwapOutline,
  MdiFormatAlignCenter,
  MdiFormatAlignLeft,
  MdiFormatAlignRight,
  MdiFormatBold,
  MdiFormatHeader1,
  MdiFormatHeader2,
  MdiFormatHeader3,
  MdiFormatItalic,
  MdiFormatListBulleted,
  MdiFormatListChecks,
  MdiFormatListNumbered,
  MdiFormatPilcrow,
  MdiFormatQuoteClose,
  MdiFormatSize,
  MdiFormatStrikethrough,
  MdiFormatUnderline,
  MdiForum,
  MdiGoogle,
  MdiGoogleDrive,
  MdiHelpCircleOutline,
  MdiHistory,
  MdiImage,
  MdiInformationOutline,
  MdiKeyVariant,
  MdiLanguageMarkdownOutline,
  MdiLightbulbOnOutline,
  MdiLink,
  MdiLockOutline,
  MdiLockReset,
  MdiMagnify,
  MdiMenu,
  MdiMenuDown,
  MdiMinus,
  MdiPalette,
  MdiPaperclip,
  MdiPencil,
  MdiPin,
  MdiPinOff,
  MdiPlus,
  MdiPoll,
  MdiRefresh,
  MdiReply,
  MdiRocket,
  MdiSend,
  MdiShieldStar,
  MdiSourcePull,
  MdiTable,
  MdiTableColumnPlusAfter,
  MdiTableColumnPlusBefore,
  MdiTableColumnRemove,
  MdiTableMergeCells,
  MdiTableRemove,
  MdiTableRowPlusAfter,
  MdiTableRowPlusBefore,
  MdiTableRowRemove,
  MdiTagOutline,
  MdiTagPlus,
  MdiThumbsUpDown,
  MdiTranslate,
  MdiUnfoldMoreHorizontal,
  MdiVideo,
  MdiWeatherNight,
  MdiWebhook,
  MdiWhiteBalanceSunny,
  MdiWindowClose,
  MdiYoutube
} from '@mdi/js'

export default
  data: ->
    icons:
      'mdi-account': MdiAccount
      'mdi-account-group': MdiAccountGroup
      'mdi-account-multiple': MdiAccountMultiple
      'mdi-account-multiple-plus': MdiAccountMultiplePlus
      'mdi-account-search': MdiAccountSearch
      'mdi-alarm-check': MdiAlarmCheck
      'mdi-arrow-left': MdiArrowLeft
      'mdi-arrow-right': MdiArrowRight
      'mdi-bell': MdiBell
      'mdi-calendar': MdiCalendar
      'mdi-calendar-question': MdiCalendarQuestion
      'mdi-call-split': MdiCallSplit
      'mdi-camera': MdiCamera
      'mdi-cards': MdiCards
      'mdi-chart-bar': MdiChartBar
      'mdi-chart-bar-stacked': MdiChartBarStacked
      'mdi-chart-gantt': MdiChartGantt
      'mdi-check': MdiCheck
      'mdi-check-circle': MdiCheckCircle
      'mdi-chevron-left': MdiChevronLeft
      'mdi-chevron-right': MdiChevronRight
      'mdi-clock-outline': MdiClockOutline
      'mdi-close': MdiClose
      'mdi-close-circle-outline': MdiCloseCircleOutline
      'mdi-code-braces': MdiCodeBraces
      'mdi-cog': MdiCog
      'mdi-cog-outline': MdiCogOutline
      'mdi-collage': MdiCollage
      'mdi-comment': MdiComment
      'mdi-comment-multiple': MdiCommentMultiple
      'mdi-comment-text-outline': MdiCommentTextOutline
      'mdi-database-export': MdiDatabaseExport
      'mdi-delete': MdiDelete
      'mdi-delete-restore': MdiDeleteRestore
      'mdi-directions-fork': MdiDirectionsFork
      'mdi-dots-vertical': MdiDotsVertical
      'mdi-drag-vertical': MdiDragVertical
      'mdi-earth': MdiEarth
      'mdi-email-outline': MdiEmailOutline
      'mdi-emoticon-outline': MdiEmoticonOutline
      'mdi-exit-run': MdiExitRun
      'mdi-exit-to-app': MdiExitToApp
      'mdi-eye': MdiEye
      'mdi-facebook': MdiFacebook
      'mdi-file': MdiFile
      'mdi-file-document': MdiFileDocument
      'mdi-file-document-box': MdiFileDocumentBox
      'mdi-file-excel-box': MdiFileExcelBox
      'mdi-file-pdf-box': MdiFilePdfBox
      'mdi-file-video': MdiFileVideo
      'mdi-file-word-box': MdiFileWordBox
      'mdi-flask-empty-off-outline': MdiFlaskEmptyOffOutline
      'mdi-flask-outline': MdiFlaskOutline
      'mdi-folder-swap-outline': MdiFolderSwapOutline
      'mdi-format-align-center': MdiFormatAlignCenter
      'mdi-format-align-left': MdiFormatAlignLeft
      'mdi-format-align-right': MdiFormatAlignRight
      'mdi-format-bold': MdiFormatBold
      'mdi-format-header-1': MdiFormatHeader1
      'mdi-format-header-2': MdiFormatHeader2
      'mdi-format-header-3': MdiFormatHeader3
      'mdi-format-italic': MdiFormatItalic
      'mdi-format-list-bulleted': MdiFormatListBulleted
      'mdi-format-list-checks': MdiFormatListChecks
      'mdi-format-list-numbered': MdiFormatListNumbered
      'mdi-format-pilcrow': MdiFormatPilcrow
      'mdi-format-quote-close': MdiFormatQuoteClose
      'mdi-format-size': MdiFormatSize
      'mdi-format-strikethrough': MdiFormatStrikethrough
      'mdi-format-underline': MdiFormatUnderline
      'mdi-forum': MdiForum
      'mdi-google': MdiGoogle
      'mdi-google-drive': MdiGoogleDrive
      'mdi-help-circle-outline': MdiHelpCircleOutline
      'mdi-history': MdiHistory
      'mdi-image': MdiImage
      'mdi-information-outline': MdiInformationOutline
      'mdi-key-variant': MdiKeyVariant
      'mdi-language-markdown-outline': MdiLanguageMarkdownOutline
      'mdi-lightbulb-on-outline': MdiLightbulbOnOutline
      'mdi-link': MdiLink
      'mdi-lock-outline': MdiLockOutline
      'mdi-lock-reset': MdiLockReset
      'mdi-magnify': MdiMagnify
      'mdi-menu': MdiMenu
      'mdi-menu-down': MdiMenuDown
      'mdi-minus': MdiMinus
      'mdi-palette': MdiPalette
      'mdi-paperclip': MdiPaperclip
      'mdi-pencil': MdiPencil
      'mdi-pin': MdiPin
      'mdi-pin-off': MdiPinOff
      'mdi-plus': MdiPlus
      'mdi-poll': MdiPoll
      'mdi-refresh': MdiRefresh
      'mdi-reply': MdiReply
      'mdi-rocket': MdiRocket
      'mdi-send': MdiSend
      'mdi-shield-star': MdiShieldStar
      'mdi-source-pull': MdiSourcePull
      'mdi-table': MdiTable
      'mdi-table-column-plus-after': MdiTableColumnPlusAfter
      'mdi-table-column-plus-before': MdiTableColumnPlusBefore
      'mdi-table-column-remove': MdiTableColumnRemove
      'mdi-table-merge-cells': MdiTableMergeCells
      'mdi-table-remove': MdiTableRemove
      'mdi-table-row-plus-after': MdiTableRowPlusAfter
      'mdi-table-row-plus-before': MdiTableRowPlusBefore
      'mdi-table-row-remove': MdiTableRowRemove
      'mdi-tag-outline': MdiTagOutline
      'mdi-tag-plus': MdiTagPlus
      'mdi-thumbs-up-down': MdiThumbsUpDown
      'mdi-translate': MdiTranslate
      'mdi-unfold-more-horizontal': MdiUnfoldMoreHorizontal
      'mdi-video': MdiVideo
      'mdi-weather-night': MdiWeatherNight
      'mdi-webhook': MdiWebhook
      'mdi-white-balance-sunny': MdiWhiteBalanceSunny
      'mdi-window-close': MdiWindowClose
      'mdi-youtube': MdiYoutube
