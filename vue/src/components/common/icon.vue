<script lang="js">
import { camelCase } from 'lodash-es';
const mdiGoogle = "M21.35,11.1H12.18V13.83H18.69C18.36,17.64 15.19,19.27 12.19,19.27C8.36,19.27 5,16.25 5,12C5,7.9 8.2,4.73 12.2,4.73C15.29,4.73 17.1,6.7 17.1,6.7L19,4.72C19,4.72 16.56,2 12.1,2C6.42,2 2.03,6.8 2.03,12C2.03,17.05 6.16,22 12.25,22C17.6,22 21.5,18.33 21.5,12.91C21.5,11.76 21.35,11.1 21.35,11.1V11.1Z";
const mdiFacebook = "M12 2.04C6.5 2.04 2 6.53 2 12.06C2 17.06 5.66 21.21 10.44 21.96V14.96H7.9V12.06H10.44V9.85C10.44 7.34 11.93 5.96 14.22 5.96C15.31 5.96 16.45 6.15 16.45 6.15V8.62H15.19C13.95 8.62 13.56 9.39 13.56 10.18V12.06H16.34L15.89 14.96H13.56V21.96A10 10 0 0 0 22 12.06C22 6.53 17.5 2.04 12 2.04Z";
const mdiSlack = "M6,15A2,2 0 0,1 4,17A2,2 0 0,1 2,15A2,2 0 0,1 4,13H6V15M7,15A2,2 0 0,1 9,13A2,2 0 0,1 11,15V20A2,2 0 0,1 9,22A2,2 0 0,1 7,20V15M9,7A2,2 0 0,1 7,5A2,2 0 0,1 9,3A2,2 0 0,1 11,5V7H9M9,8A2,2 0 0,1 11,10A2,2 0 0,1 9,12H4A2,2 0 0,1 2,10A2,2 0 0,1 4,8H9M17,10A2,2 0 0,1 19,8A2,2 0 0,1 21,10A2,2 0 0,1 19,12H17V10M16,10A2,2 0 0,1 14,12A2,2 0 0,1 12,10V5A2,2 0 0,1 14,3A2,2 0 0,1 16,5V10M14,18A2,2 0 0,1 16,20A2,2 0 0,1 14,22A2,2 0 0,1 12,20V18H14M14,17A2,2 0 0,1 12,15A2,2 0 0,1 14,13H19A2,2 0 0,1 21,15A2,2 0 0,1 19,17H14Z";
const mdiMicrosoftTeams = "M19.19 8.77Q18.73 8.77 18.33 8.6 17.94 8.43 17.64 8.13 17.34 7.83 17.17 7.44 17 7.04 17 6.58 17 6.13 17.17 5.73 17.34 5.33 17.64 5.04 17.94 4.74 18.33 4.57 18.73 4.39 19.19 4.4 19.64 4.39 20.04 4.57 20.44 4.74 20.74 5.04 21.03 5.33 21.21 5.73 21.38 6.13 21.38 6.58 21.38 7.04 21.21 7.44 21.04 7.83 20.74 8.13 20.44 8.43 20.04 8.6 19.64 8.77 19.19 8.77M19.19 5.65Q18.8 5.65 18.5 5.92 18.25 6.19 18.25 6.58 18.25 6.97 18.5 7.25 18.8 7.5 19.19 7.5 19.58 7.5 19.85 7.25 20.13 7 20.13 6.58 20.13 6.19 19.85 5.92 19.58 5.65 19.19 5.65M22 10.33V15Q22 15.63 21.76 16.2 21.5 16.77 21.09 17.19 20.66 17.62 20.09 17.86 19.5 18.11 18.88 18.11 18.5 18.11 18.12 18 17.73 17.93 17.41 17.75 17.17 18.54 16.7 19.19 16.23 19.84 15.6 20.3 14.97 20.76 14.21 21 13.45 21.27 12.63 21.27 11.67 21.27 10.82 20.94 10 20.61 9.32 20 8.66 19.43 8.23 18.64 7.79 17.84 7.66 16.9H2.83Q2.5 16.9 2.24 16.65 2 16.41 2 16.07V7.73Q2 7.39 2.24 7.14 2.5 6.9 2.83 6.9H10Q9.71 6.3 9.71 5.65 9.71 5.04 9.94 4.5 10.16 4 10.56 3.58 10.96 3.19 11.5 2.96 12 2.73 12.62 2.73 13.23 2.73 13.76 2.96 14.29 3.19 14.69 3.58 15.09 4 15.31 4.5 15.54 5.04 15.54 5.65 15.54 6.25 15.31 6.79 15.09 7.32 14.69 7.71 14.29 8.11 13.76 8.34 13.23 8.57 12.62 8.57 12.47 8.57 12.31 8.55 12.16 8.53 12 8.5V9.4H21.06Q21.45 9.4 21.73 9.67 22 9.94 22 10.33M12.63 4Q12.28 4 12 4.11 11.67 4.24 11.44 4.47 11.22 4.7 11.09 5 10.96 5.31 10.96 5.65 10.96 6 11.09 6.3 11.22 6.6 11.44 6.83 11.67 7.05 12 7.19 12.28 7.32 12.63 7.32 12.97 7.32 13.27 7.19 13.57 7.05 13.8 6.83 14.03 6.6 14.16 6.3 14.3 6 14.3 5.65 14.3 5.31 14.16 5 14.03 4.7 13.8 4.47 13.57 4.24 13.27 4.11 12.97 4 12.63 4M7.78 10.18H9.66V8.62H4.34V10.18H6.22V15.18H7.78M16.38 16.27V10.65H12V16.07Q12 16.41 11.76 16.65 11.5 16.9 11.17 16.9H8.92Q9.05 17.57 9.39 18.15 9.73 18.72 10.21 19.14 10.69 19.55 11.31 19.79 11.92 20 12.63 20 13.4 20 14.08 19.73 14.76 19.43 15.28 18.92 15.79 18.41 16.08 17.73 16.38 17.05 16.38 16.27M20.75 15V10.65H17.63V16.36Q17.88 16.61 18.2 16.74 18.5 16.86 18.88 16.86 19.27 16.86 19.61 16.71 19.95 16.56 20.2 16.31 20.46 16.06 20.6 15.71 20.75 15.37 20.75 15Z";
const mdiApple = "M18.71,19.5C17.88,20.74 17,21.95 15.66,21.97C14.32,22 13.89,21.18 12.37,21.18C10.84,21.18 10.37,21.95 9.1,22C7.79,22.05 6.8,20.68 5.96,19.47C4.25,17 2.94,12.45 4.7,9.39C5.57,7.87 7.13,6.91 8.82,6.88C10.1,6.86 11.32,7.75 12.11,7.75C12.89,7.75 14.37,6.68 15.92,6.84C16.57,6.87 18.39,7.1 19.56,8.82C19.47,8.88 17.39,10.1 17.41,12.63C17.44,15.65 20.06,16.66 20.09,16.67C20.06,16.74 19.67,18.11 18.71,19.5M13,3.5C13.73,2.67 14.94,2.04 15.94,2C16.07,3.17 15.6,4.35 14.9,5.19C14.21,6.04 13.07,6.7 11.95,6.61C11.8,5.46 12.36,4.26 13,3.5Z";

import {
  mdiAccount,
  mdiAccountGroup,
  mdiAccountMultiple,
  mdiAccountMultiplePlus,
  mdiAccountSearch,
  mdiAlarmCheck,
  mdiArchiveOutline,
  mdiArrowDown,
  mdiArrowLeft,
  mdiArrowRight,
  mdiArrowUp,
  mdiArrowUpDown,
  mdiBell,
  mdiBellOff,
  mdiBellOutline,
  mdiBellRingOutline,
  mdiBookOpenPageVariant,
  mdiCalendar,
  mdiCallSplit,
  mdiCamera,
  mdiCancel,
  mdiCarConvertible,
  mdiChartBar,
  mdiChatProcessing,
  mdiCheck,
  mdiCheckCircle,
  mdiCheckboxBlankOutline,
  mdiCheckboxMarked,
  mdiCheckboxMarkedOutline,
  mdiChevronDown,
  mdiChevronLeft,
  mdiChevronRight,
  mdiChevronUp,
  mdiClockOutline,
  mdiClose,
  mdiCloseCircleOutline,
  mdiCodeBraces,
  mdiCog,
  mdiCogOutline,
  mdiCommentMultiple,
  mdiCommentPlusOutline,
  mdiCommentTextOutline,
  mdiContentCopy,
  mdiCreditCardOutline,
  mdiDiscord,
  mdiDatabaseArrowRightOutline,
  mdiDatabaseExport,
  mdiDelete,
  mdiDeleteCircle,
  mdiDeleteOutline,
  mdiDeleteRestore,
  mdiDotsHorizontal,
  mdiDotsVertical,
  mdiDrag,
  mdiDuck,
  mdiDragVertical,
  mdiEarth,
  mdiEmail,
  mdiEmailOutline,
  mdiEmoticonOutline,
  mdiExitRun,
  mdiExitToApp,
  mdiEye,
  mdiEyeOff,
  mdiFaceAgent,
  mdiFile,
  mdiFilePdfBox,
  mdiFileWordBox,
  mdiFileVideo,
  mdiFlagCheckered,
  mdiFolderSwapOutline,
  mdiFormatAlignCenter,
  mdiFormatAlignLeft,
  mdiFormatAlignRight,
  mdiFormatHeader1,
  mdiFormatHeader2,
  mdiFormatHeader3,
  mdiFormatBold,
  mdiFormatItalic,
  mdiFormatListBulleted,
  mdiFormatListNumbered,
  mdiFormatPilcrow,
  mdiFormatQuoteClose,
  mdiFormatStrikethrough,
  mdiFormatUnderline,
  mdiFormatVerticalAlignCenter,
  mdiFormatVerticalAlignTop,
  mdiForum,
  mdiHelp,
  mdiHelpCircleOutline,
  mdiHistory,
  mdiImage,
  mdiInformationOutline,
  mdiKeyVariant,
  mdiLanguageMarkdownOutline,
  mdiLink,
  mdiLinkVariant,
  mdiLockOutline,
  mdiLockReset,
  mdiMagnify,
  mdiMagnifyMinusOutline,
  mdiMagnifyPlusOutline,
  mdiMapSearch,
  mdiMatrix,
  mdiMenu,
  mdiMenuDown,
  mdiMicrophone,
  mdiMinus,
  mdiOpenInNew,
  mdiPalette,
  mdiPaperclip,
  mdiPauseCircle,
  mdiPencil,
  mdiPin,
  mdiPinOff,
  mdiPinOutline,
  mdiPlus,
  mdiPoll,
  mdiPrinterOutline,
  mdiRadioboxBlank,
  mdiRadioboxMarked,
  mdiRefresh,
  mdiReply,
  mdiRobot,
  mdiRocket,
  mdiSend,
  mdiShieldStar,
  mdiStar,
  mdiStarFace,
  mdiTable,
  mdiTableColumnPlusAfter,
  mdiTableColumnPlusBefore,
  mdiTableColumnRemove,
  mdiTableMergeCells,
  mdiTableRemove,
  mdiTableRowPlusAfter,
  mdiTableRowPlusBefore,
  mdiTableRowRemove,
  mdiTag,
  mdiTagOutline,
  mdiThumbsUpDown,
  mdiTranslate,
  mdiUnfoldMoreHorizontal,
  mdiVideo,
  mdiWeatherNight,
  mdiWebhook,
  mdiWhiteBalanceSunny,
  mdiWindowClose,
  mdiYoutube
} from '@mdi/js';

const webex = 'M21.78 7.376c.512 1.181.032 2.644-1.11 3.106-2.157.888-3-1.295-3-1.295-.236-.55-.727-1.496-1.335-1.496-.204 0-.503 0-.94.844-.229.443-.434 1.185-.616 1.84l-.09.32c-.373-1.587-.821-3.454-1.536-4.816-.195-.38-.42-.74-.673-1.08a5.135 5.135 0 0 1 1.743-1.337 4.891 4.891 0 0 1 2.112-.463c1.045 0 2.765.338 4.227 2.227.167.206.317.424.448.654.278.441.52.904.726 1.383l.043.113zM.02 8.4C-.15 7.105.8 5.845 1.953 5.755c1.794-.157 2.36 1.385 2.455 1.89l.022.137c.07.44.29 1.838.48 2.744.078.4.244 1.013.353 1.416l.006.022.026.092c.11.4.232.799.362 1.193.185.548.399 1.085.641 1.61.47.955.93 1.45 1.367 1.45.203 0 .512 0 .96-.878.283-.59.512-1.208.684-1.845.373 1.598.811 3.128 1.495 4.456.205.406.444.794.715 1.16a5.124 5.124 0 0 1-1.742 1.338 4.88 4.88 0 0 1-2.112.461c-1.548 0-3.727-.698-5.339-4.005a22.407 22.407 0 0 1-1.078-2.824 26.848 26.848 0 0 1-.693-2.656 48.56 48.56 0 0 1-.215-1.114C.191 9.603.074 8.872.02 8.4zm22.047-2.645-.202-.022h-.052c.222.392.421.797.597 1.215l.053.113c.322.76.346 1.614.068 2.391a3.079 3.079 0 0 1-1.552 1.749 2.93 2.93 0 0 1-1.228.28 3.115 3.115 0 0 1-.854-.135c-.299 1.182-.768 2.634-1.195 3.511-.427.877-.93 1.451-1.378 1.451-.192 0-.501 0-.95-.877a10.746 10.746 0 0 1-.683-1.845 38.722 38.722 0 0 1-.396-1.575 12.67 12.67 0 0 1-.136-.598l-.002-.01c-.406-1.778-.865-3.645-1.655-5.142A8.263 8.263 0 0 0 11.52 4.8a5.136 5.136 0 0 0-1.748-1.34A4.892 4.892 0 0 0 7.654 3c-1.036 0-2.754.338-4.217 2.228.466.223.867.562 1.164.984.305.433.499.933.565 1.458.076.563.256 1.654.47 2.688l.001.007c.021.11.042.221.073.342.126-.34.25-.642.38-.955l.112-.271.128-.293c.235-.55.726-1.496 1.324-1.496.213 0 .513 0 .95.844.296.606.532 1.239.706 1.89.138.507.276 1.047.394 1.587.04.148.07.296.101.444l.006.028c.427 1.879.875 3.69 1.644 5.187.159.317.34.622.545.911.15.215.31.422.48.62 1.27 1.45 2.733 1.8 3.843 1.8 1.548 0 3.738-.698 5.35-4.006.822-1.7 1.515-4.208 1.772-5.48.256-1.27.449-2.419.534-3.115.04-.307.023-.618-.051-.918-.075-.299-.205-.579-.382-.825a2.247 2.247 0 0 0-.653-.607 2.143 2.143 0 0 0-.826-.296z';

export default {
  props: {
    color: {
      type: String,
      default: undefined,
    },
    density:  {
      type: String,
      default: undefined
    },
    disabled:  {
      type: Boolean,
      default: false
    },
    left:  {
      type: Boolean,
      default: false
    },
    light:  {
      type: Boolean,
      default: false
    },
    right:  {
      type: Boolean,
      default: false
    },
    size: {
      type: [Number, String],
      default: 'default'
    },
    tag: String,
    name: String
  },

  data() {
    return {
      mdiAccount,
      mdiAccountGroup,
      mdiAccountMultiple,
      mdiAccountMultiplePlus,
      mdiAccountSearch,
      mdiAlarmCheck,
      mdiArchiveOutline,
      mdiArrowDown,
      mdiArrowLeft,
      mdiArrowRight,
      mdiArrowUp,
      mdiArrowUpDown,
      mdiBell,
      mdiBellOff,
      mdiBellOutline,
      mdiBellRingOutline,
      mdiBookOpenPageVariant,
      mdiCalendar,
      mdiCallSplit,
      mdiCamera,
      mdiCancel,
      mdiCarConvertible,
      mdiChartBar,
      mdiChatProcessing,
      mdiCheck,
      mdiCheckCircle,
      mdiCheckboxBlankOutline,
      mdiCheckboxMarked,
      mdiCheckboxMarkedOutline,
      mdiChevronDown,
      mdiChevronLeft,
      mdiChevronRight,
      mdiChevronUp,
      mdiClockOutline,
      mdiClose,
      mdiCloseCircleOutline,
      mdiCodeBraces,
      mdiCog,
      mdiCogOutline,
      mdiCommentMultiple,
      mdiCommentPlusOutline,
      mdiCommentTextOutline,
      mdiContentCopy,
      mdiCreditCardOutline,
      mdiDatabaseArrowRightOutline,
      mdiDatabaseExport,
      mdiDiscord,
      mdiDelete,
      mdiDeleteCircle,
      mdiDeleteOutline,
      mdiDeleteRestore,
      mdiDotsHorizontal,
      mdiDotsVertical,
      mdiDrag,
      mdiDragVertical,
      mdiDuck,
      mdiEarth,
      mdiEmail,
      mdiEmailOutline,
      mdiEmoticonOutline,
      mdiExitRun,
      mdiExitToApp,
      mdiEye,
      mdiEyeOff,
      mdiFaceAgent,
      mdiFile,
      mdiFilePdfBox,
      mdiFileWordBox,
      mdiFileVideo,
      mdiFlagCheckered,
      mdiFolderSwapOutline,
      mdiFormatAlignCenter,
      mdiFormatAlignLeft,
      mdiFormatAlignRight,
      mdiFormatHeader1,
      mdiFormatHeader2,
      mdiFormatHeader3,
      mdiFormatBold,
      mdiFormatItalic,
      mdiFormatListBulleted,
      mdiFormatListNumbered,
      mdiFormatPilcrow,
      mdiFormatQuoteClose,
      mdiFormatStrikethrough,
      mdiFormatUnderline,
      mdiFormatVerticalAlignCenter,
      mdiFormatVerticalAlignTop,
      mdiForum,
      mdiGoogle,
      mdiFacebook,
      mdiSlack,
      mdiMicrosoftTeams,
      mdiApple,
      mdiHelp,
      mdiHelpCircleOutline,
      mdiHistory,
      mdiImage,
      mdiInformationOutline,
      mdiKeyVariant,
      mdiLanguageMarkdownOutline,
      mdiLink,
      mdiLinkVariant,
      mdiLockOutline,
      mdiLockReset,
      mdiMagnify,
      mdiMagnifyMinusOutline,
      mdiMagnifyPlusOutline,
      mdiMapSearch,
      mdiMatrix,
      mdiMenu,
      mdiMenuDown,
      mdiMicrophone,
      mdiMicrosoftTeams,
      mdiMinus,
      mdiOpenInNew,
      mdiPalette,
      mdiPaperclip,
      mdiPauseCircle,
      mdiPencil,
      mdiPin,
      mdiPinOff,
      mdiPinOutline,
      mdiPlus,
      mdiPoll,
      mdiPrinterOutline,
      mdiRadioboxBlank,
      mdiRadioboxMarked,
      mdiRefresh,
      mdiReply,
      mdiRobot,
      mdiRocket,
      mdiSend,
      mdiShieldStar,
      mdiSlack,
      mdiStar,
      mdiStarFace,
      mdiTable,
      mdiTableColumnPlusAfter,
      mdiTableColumnPlusBefore,
      mdiTableColumnRemove,
      mdiTableMergeCells,
      mdiTableRemove,
      mdiTableRowPlusAfter,
      mdiTableRowPlusBefore,
      mdiTableRowRemove,
      mdiTag,
      mdiTagOutline,
      mdiThumbsUpDown,
      mdiTranslate,
      mdiUnfoldMoreHorizontal,
      mdiVideo,
      mdiWeatherNight,
      mdiWebhook,
      mdiWhiteBalanceSunny,
      mdiWindowClose,
      mdiYoutube,
      webex
    };
  },

  methods: {
    iconSVG() {
      if (this.name) {
        return this[camelCase(this.name)]
      } else {
        return undefined
      }
    }
  },
};
</script>

<template lang="pug">
v-icon(
  :class="{'text-medium-emphasis': color == undefined}"
  :color="color"
  :density="density"
  :left="left"
  :light="light"
  :right="right"
  :tag="tag"
  :size="size"
) {{ iconSVG() }}
</template>
