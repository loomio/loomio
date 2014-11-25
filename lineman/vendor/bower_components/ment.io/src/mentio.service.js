'use strict';

angular.module('mentio')
    .factory('mentioUtil', function ($window, $location, $anchorScroll, $timeout) {

        // public
        function popUnderMention (triggerCharSet, selectionEl, requireLeadingSpace) {
            var coordinates;
            var mentionInfo = getTriggerInfo(triggerCharSet, requireLeadingSpace, false);

            if (mentionInfo !== undefined) {

                if (selectedElementIsTextAreaOrInput()) {
                    coordinates = getTextAreaOrInputUnderlinePosition(document.activeElement,
                        mentionInfo.mentionPosition);
                } else {
                    coordinates = getContentEditableCaretPosition(mentionInfo.mentionPosition);
                }

                // Move the button into place.
                selectionEl.css({
                    top: coordinates.top + 'px',
                    left: coordinates.left + 'px',
                    position: 'absolute',
                    zIndex: 100,
                    display: 'block'
                });

                $timeout(function(){
                    scrollIntoView(selectionEl);
                },0);
            } else {
                selectionEl.css({
                    display: 'none'
                });
            }
        }

        function scrollIntoView(elem)
        {
            // cheap hack in px - need to check styles relative to the element
            var reasonableBuffer = 20;
            var maxScrollDisplacement = 100;
            var clientRect;
            var e = elem[0];
            while (clientRect === undefined || clientRect.height === 0) {
                clientRect = e.getBoundingClientRect();
                if (clientRect.height === 0) {
                    e = e.childNodes[0];
                    if (e === undefined || !e.getBoundingClientRect) {
                        return;
                    }
                }
            }
            var elemTop = clientRect.top;
            var elemBottom = elemTop + clientRect.height;
            if(elemTop < 0) {
                $window.scrollTo(0, $window.pageYOffset + clientRect.top - reasonableBuffer);
            } else if (elemBottom > $window.innerHeight) {
                var maxY = $window.pageYOffset + clientRect.top - reasonableBuffer;
                if (maxY - $window.pageYOffset > maxScrollDisplacement) {
                    maxY = $window.pageYOffset + maxScrollDisplacement;
                }
                var targetY = $window.pageYOffset - ($window.innerHeight - elemBottom);
                if (targetY > maxY) {
                    targetY = maxY;
                }
                $window.scrollTo(0, targetY);
            }
        }

        function selectedElementIsTextAreaOrInput () {
            var element = document.activeElement;
            if (element !== null) {
                var nodeName = element.nodeName;
                var type = element.getAttribute('type');
                return (nodeName === 'INPUT' && type === 'text') || nodeName === 'TEXTAREA';
            }
            return false;
        }

        function selectElement (targetElement, path, offset) {
            var range;
            var elem = targetElement;
            for (var i = 0; i < path.length; i++) {
                elem = elem.childNodes[path[i]];
                if (elem === undefined) {
                    return;
                }
                while (elem.length < offset) {
                    offset -= elem.length;
                    elem = elem.nextSibling;
                }
            }
            if (document.selection && document.selection.createRange) {
                // Clone the TextRange and collapse
                range = document.selection.createRange().duplicate();
                range.select(elem);
                range.selectStartOffset(offset);
                range.selectEndOffset(offset);
                range.collapse(true);
                document.selection.removeAllRanges();
                document.selection.addRange(range);
            } else if (window.getSelection) {
                var sel = window.getSelection();

                range = document.createRange();
                range.setStart(elem, offset);
                range.setEnd(elem, offset);
                range.collapse(true);
                try{sel.removeAllRanges();}catch(error){}
                sel.addRange(range);
                targetElement.focus();
            }
        }

        function pasteHtml (html, startPos, endPos) {
            var range, sel;
            if (document.selection && document.selection.createRange) {
                range = document.selection.createRange().duplicate();
                range.selectStartOffset(startPos);
                range.selectEndOffset(endPos);
                range.collapse(false);
                range.deleteContents();

                range.pasteHTML(html);
            } else if (window.getSelection) {
                sel = window.getSelection();
                range = document.createRange();
                range.setStart(sel.anchorNode, startPos);
                range.setEnd(sel.anchorNode, endPos);
                range.deleteContents();

                var el = document.createElement('div');
                el.innerHTML = html;
                var frag = document.createDocumentFragment(),
                    node, lastNode;
                while ((node = el.firstChild)) {
                    lastNode = frag.appendChild(node);
                }
                range.insertNode(frag);

                // Preserve the selection
                if (lastNode) {
                    range = range.cloneRange();
                    range.setStartAfter(lastNode);
                    range.collapse(true);
                    sel.removeAllRanges();
                    sel.addRange(range);
                }
            }
        }

        function resetSelection (targetElement, path, offset) {
            var nodeName = targetElement.nodeName;
            if (nodeName === 'INPUT' || nodeName === 'TEXTAREA') {
                if (targetElement !== document.activeElement) {
                    targetElement.focus();
                }
            } else {
                selectElement(targetElement, path, offset);
            }
        }

        // public
        function replaceMacroText (targetElement, path, offset, macros, text) {
            resetSelection(targetElement, path, offset);

            var macroMatchInfo = getMacroMatch(macros);

            if (macroMatchInfo.macroHasTrailingSpace) {
                macroMatchInfo.macroText = macroMatchInfo.macroText + '\xA0';
                text = text + '\xA0';
            }

            if (macroMatchInfo !== undefined) {
                var element = document.activeElement;
                if (selectedElementIsTextAreaOrInput()) {
                    //IE support
                    if (document.selection) {
                        element.focus();
                        var sel = document.selection.createRange();
                        sel.selectStartOffset(macroMatchInfo.macroPosition);
                        sel.selectEndOffset(macroMatchInfo.macroPosition + macroMatchInfo.macroText.length);
                        sel.text = text;
                    }
                    //MOZILLA and others
                    else {
                        var startPos = macroMatchInfo.macroPosition;
                        var endPos = macroMatchInfo.macroPosition + macroMatchInfo.macroText.length;
                        element.value = element.value.substring(0, startPos) + text +
                            element.value.substring(endPos, element.value.length);
                        element.selectionStart = startPos + text.length;
                        element.selectionEnd = startPos + text.length;
                    }
                } else {
                    pasteHtml(text, macroMatchInfo.macroPosition,
                            macroMatchInfo.macroPosition + macroMatchInfo.macroText.length);
                }
            }
        }

        // public
        function replaceTriggerText (targetElement, path, offset, triggerCharSet, text, requireLeadingSpace) {
            resetSelection(targetElement, path, offset);

            var mentionInfo = getTriggerInfo(triggerCharSet, requireLeadingSpace, true);

            if (mentionInfo !== undefined) {
                if (selectedElementIsTextAreaOrInput()) {
                    var myField = document.activeElement;
                    text = text + ' ';
                    //IE support
                    if (document.selection) {
                        myField.focus();
                        var sel = document.selection.createRange();
                        sel.selectStartOffset(mentionInfo.mentionPosition);
                        sel.selectEndOffset(mentionInfo.mentionPosition + mentionInfo.mentionText.length);
                        sel.text = text;
                    }
                    //MOZILLA and others
                    else {
                        var startPos = mentionInfo.mentionPosition;
                        var endPos = mentionInfo.mentionPosition + mentionInfo.mentionText.length + 1;
                        myField.value = myField.value.substring(0, startPos) + text +
                            myField.value.substring(endPos, myField.value.length);
                        myField.selectionStart = startPos + text.length;
                        myField.selectionEnd = startPos + text.length;
                    }
                } else {
                    // add a space to the end of the pasted text
                    text = text + '\xA0';
                    pasteHtml(text, mentionInfo.mentionPosition,
                            mentionInfo.mentionPosition + mentionInfo.mentionText.length + 1);
                }
            }
        }

        function getNodePositionInParent (elem) {
            if (elem.parentNode === null) {
                return 0;
            }
            for (var i = 0; i < elem.parentNode.childNodes.length; i++) {
                var node = elem.parentNode.childNodes[i];
                if (node === elem) {
                    return i;
                }
            }
        }

        // public
        function getMacroMatch (macros) {
            var selected, path = [], offset;

            if (selectedElementIsTextAreaOrInput()) {
                selected = document.activeElement;
            } else {
                // content editable
                var selectionInfo = getContentEditableSelectedPath();
                if (selectionInfo) {
                    selected = selectionInfo.selected;
                    path = selectionInfo.path;
                    offset = selectionInfo.offset;
                }
            }
            var effectiveRange = getTextPrecedingCurrentSelection();
            if (effectiveRange !== undefined && effectiveRange !== null) {

                var matchInfo;

                var hasTrailingSpace = false;

                if (effectiveRange.length > 0 && 
                    (effectiveRange.charAt(effectiveRange.length - 1) === '\xA0' ||
                        effectiveRange.charAt(effectiveRange.length - 1) === ' ')) {
                    hasTrailingSpace = true;
                    // strip space
                    effectiveRange = effectiveRange.substring(0, effectiveRange.length-1);
                }

                angular.forEach(macros, function (macro, c) {
                    var idx = effectiveRange.toUpperCase().lastIndexOf(c.toUpperCase());

                    if (idx >= 0 && c.length + idx === effectiveRange.length) {
                        var prevCharPos = idx - 1;
                        if (idx === 0 || effectiveRange.charAt(prevCharPos) === '\xA0' ||
                            effectiveRange.charAt(prevCharPos) === ' ' ) {

                            matchInfo = {
                                macroPosition: idx,
                                macroText: c,
                                macroSelectedElement: selected,
                                macroSelectedPath: path,
                                macroSelectedOffset: offset,
                                macroHasTrailingSpace: hasTrailingSpace
                            };
                        }
                    }
                });
                if (matchInfo) {
                    return matchInfo;
                }
            }
        }

        function getContentEditableSelectedPath() {
            // content editable
            var sel = window.getSelection();
            var selected = sel.anchorNode;
            var path = [];
            var offset;
            if (selected != null) {
                var i;
                var ce = selected.contentEditable;
                while (selected !== null && ce !== 'true') {
                    i = getNodePositionInParent(selected);
                    path.push(i);
                    selected = selected.parentNode;
                    if (selected !== null) {
                        ce = selected.contentEditable;
                    }
                }
                path.reverse();
                // getRangeAt may not exist, need alternative
                offset = sel.getRangeAt(0).startOffset;
                return {
                    selected: selected,
                    path: path,
                    offset: offset
                };
            }
        }

        // public
        function getTriggerInfo (triggerCharSet, requireLeadingSpace, menuAlreadyActive) {
            var selected, path, offset;
            if (selectedElementIsTextAreaOrInput()) {
                selected = document.activeElement;
            } else {
                // content editable
                var selectionInfo = getContentEditableSelectedPath();
                if (selectionInfo) {
                    selected = selectionInfo.selected;
                    path = selectionInfo.path;
                    offset = selectionInfo.offset;
                }
            }
            var effectiveRange = getTextPrecedingCurrentSelection();

            if (effectiveRange !== undefined && effectiveRange !== null) {
                var mostRecentTriggerCharPos = -1;
                var triggerChar;
                triggerCharSet.forEach(function(c) {
                    var idx = effectiveRange.lastIndexOf(c);
                    if (idx > mostRecentTriggerCharPos) {
                        mostRecentTriggerCharPos = idx;
                        triggerChar = c;
                    }
                });
                if (mostRecentTriggerCharPos >= 0 && 
                        (
                            mostRecentTriggerCharPos === 0 || 
                            !requireLeadingSpace ||
                            /[\xA0\s]/g.test
                            (
                                effectiveRange.substring(
                                    mostRecentTriggerCharPos - 1, 
                                    mostRecentTriggerCharPos)
                            )
                        )
                    ) 
                {
                    var currentTriggerSnippet = effectiveRange.substring(mostRecentTriggerCharPos + 1,
                        effectiveRange.length);

                    triggerChar = effectiveRange.substring(mostRecentTriggerCharPos, mostRecentTriggerCharPos+1);
                    var firstSnippetChar = currentTriggerSnippet.substring(0,1);
                    var leadingSpace = currentTriggerSnippet.length > 0 && 
                        (
                            firstSnippetChar === ' ' ||
                            firstSnippetChar === '\xA0'
                        );
                    if (!leadingSpace && (menuAlreadyActive || !(/[\xA0\s]/g.test(currentTriggerSnippet)))) {
                        return {
                            mentionPosition: mostRecentTriggerCharPos,
                            mentionText: currentTriggerSnippet,
                            mentionSelectedElement: selected,
                            mentionSelectedPath: path,
                            mentionSelectedOffset: offset,
                            mentionTriggerChar: triggerChar
                        };
                    }
                }
            }
        }

        function getTextPrecedingCurrentSelection () {
            var text;
            if (selectedElementIsTextAreaOrInput()) {
                var textComponent = document.activeElement;
                // IE version
                if (document.selection !== undefined) {
                    textComponent.focus();
                    var sel = document.selection.createRange();
                    text = sel.text;
                }
                // Mozilla version
                else if (textComponent.selectionStart !== undefined) {
                    var startPos = textComponent.selectionStart;
                    text = textComponent.value.substring(0, startPos);
                }

            } else {
                var selectedElem = window.getSelection().anchorNode; 
                if (selectedElem != null) {
                    var workingNodeContent = selectedElem.textContent;
                    var selectStartOffset = window.getSelection().getRangeAt(0).startOffset;
                    if (selectStartOffset >= 0) {
                        text = workingNodeContent.substring(0, selectStartOffset);
                    }
                }
            }
            return text;
        }

        function getContentEditableCaretPosition (selectedNodePosition) {
            var markerTextChar = '\ufeff';
            var markerTextCharEntity = '&#xfeff;';
            var markerEl, markerId = 'sel_' + new Date().getTime() + '_' + Math.random().toString().substr(2);

            var range;
            if (document.selection && document.selection.createRange) {
                // Clone the TextRange and collapse
                range = document.selection.createRange().duplicate();
                range.selectStartOffset(selectedNodePosition);
                range.selectEndOffset(selectedNodePosition);
                range.collapse(false);

                // Create the marker element containing a single invisible character by
                // creating literal HTML and insert it
                range.pasteHTML('<span id="' + markerId + '" style="position: relative;">' +
                    markerTextCharEntity + '</span>');
                markerEl = document.getElementById(markerId);
            } else if (window.getSelection) {
                var sel = window.getSelection();
                var prevRange = sel.getRangeAt(0);
                range = document.createRange();

                range.setStart(sel.anchorNode, selectedNodePosition);
                range.setEnd(sel.anchorNode, selectedNodePosition);

                range.collapse(false);

                // Create the marker element containing a single invisible character using DOM methods and insert it
                markerEl = document.createElement('span');
                markerEl.id = markerId;
                markerEl.appendChild(document.createTextNode(markerTextChar));
                range.insertNode(markerEl);
                sel.removeAllRanges();
                sel.addRange(prevRange);
            }

            var obj = markerEl;
            var coordinates = {
                left: 0,
                top: markerEl.offsetHeight
            };
            do {
                coordinates.left += obj.offsetLeft;
                coordinates.top += obj.offsetTop;
            } while (obj = obj.offsetParent);

            markerEl.parentNode.removeChild(markerEl);
            return coordinates;
        }

        function getTextAreaOrInputUnderlinePosition (element, position) {
            var properties = [
                'direction', 
                'boxSizing',
                'width', 
                'height',
                'overflowX',
                'overflowY', 
                'borderTopWidth',
                'borderRightWidth',
                'borderBottomWidth',
                'borderLeftWidth',
                'paddingTop',
                'paddingRight',
                'paddingBottom',
                'paddingLeft',
                'fontStyle',
                'fontVariant',
                'fontWeight',
                'fontStretch',
                'fontSize',
                'fontSizeAdjust',
                'lineHeight',
                'fontFamily',
                'textAlign',
                'textTransform',
                'textIndent',
                'textDecoration',
                'letterSpacing',
                'wordSpacing'
            ];

            var isFirefox = (window.mozInnerScreenX !== null);

            var div = document.createElement('div');
            div.id = 'input-textarea-caret-position-mirror-div';
            document.body.appendChild(div);

            var style = div.style;
            var computed = window.getComputedStyle ? getComputedStyle(element) : element.currentStyle;

            style.whiteSpace = 'pre-wrap';
            if (element.nodeName !== 'INPUT') {
                style.wordWrap = 'break-word'; 
            }

            // position off-screen
            style.position = 'absolute'; 
            style.visibility = 'hidden'; 

            // transfer the element's properties to the div
            properties.forEach(function (prop) {
                style[prop] = computed[prop];
            });

            if (isFirefox) {
                style.width = (parseInt(computed.width) - 2) + 'px';
                if (element.scrollHeight > parseInt(computed.height))
                    style.overflowY = 'scroll';
            } else {
                style.overflow = 'hidden'; 
            }

            div.textContent = element.value.substring(0, position);

            if (element.nodeName === 'INPUT') {
                div.textContent = div.textContent.replace(/\s/g, '\u00a0');
            }

            var span = document.createElement('span');
            span.textContent = element.value.substring(position) || '.';
            div.appendChild(span);

            var coordinates = {
                top: span.offsetTop + parseInt(computed.borderTopWidth) + span.offsetHeight,
                left: span.offsetLeft + parseInt(computed.borderLeftWidth)
            };

            var obj = element;
            do {
                coordinates.left += obj.offsetLeft;
                coordinates.top += obj.offsetTop;
            } while (obj = obj.offsetParent);

            document.body.removeChild(div);

            return coordinates;
        }

        return {
            // public
            popUnderMention: popUnderMention,
            replaceMacroText: replaceMacroText,
            replaceTriggerText: replaceTriggerText,
            getMacroMatch: getMacroMatch,
            getTriggerInfo: getTriggerInfo,
            selectElement: selectElement,




            // private: for unit testing only
            getTextAreaOrInputUnderlinePosition: getTextAreaOrInputUnderlinePosition,
            getTextPrecedingCurrentSelection: getTextPrecedingCurrentSelection,
            getContentEditableSelectedPath: getContentEditableSelectedPath,
            getNodePositionInParent: getNodePositionInParent,
            getContentEditableCaretPosition: getContentEditableCaretPosition,
            pasteHtml: pasteHtml,
            resetSelection: resetSelection,
            scrollIntoView: scrollIntoView
        };
    });
