/* <![CDATA[ */
/* File:        linkify.js
 * Version:     20101010_1000
 * Copyright:   (c) 2010 Jeff Roberson - http://jmrware.com
 * MIT License: http://www.opensource.org/licenses/mit-license.php
 *
 * Summary: This script linkifys http URLs on a page.
 *
 * Usage:   See demonstration page: linkify.html
 */
function linkify(text) {
    /* Here is a commented version of the regex (in PHP string format):
    $url_pattern = '/# Rev:20100913_0900 github.com\/jmrware\/LinkifyURL
    # Match http & ftp URL that is not already linkified.
      # Alternative 1: URL delimited by (parentheses).
      (\()                     # $1  "(" start delimiter.
      ((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&\'()*+,;=:\/?#[\]@%]+)  # $2: URL.
      (\))                     # $3: ")" end delimiter.
    | # Alternative 2: URL delimited by [square brackets].
      (\[)                     # $4: "[" start delimiter.
      ((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&\'()*+,;=:\/?#[\]@%]+)  # $5: URL.
      (\])                     # $6: "]" end delimiter.
    | # Alternative 3: URL delimited by {curly braces}.
      (\{)                     # $7: "{" start delimiter.
      ((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&\'()*+,;=:\/?#[\]@%]+)  # $8: URL.
      (\})                     # $9: "}" end delimiter.
    | # Alternative 4: URL delimited by <angle brackets>.
      (<|&(?:lt|\#60|\#x3c);)  # $10: "<" start delimiter (or HTML entity).
      ((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&\'()*+,;=:\/?#[\]@%]+)  # $11: URL.
      (>|&(?:gt|\#62|\#x3e);)  # $12: ">" end delimiter (or HTML entity).
    | # Alternative 5: URL not delimited by (), [], {} or <>.
      (                        # $13: Prefix proving URL not already linked.
        (?: ^                  # Can be a beginning of line or string, or
        | [^=\s\'"\]]          # a non-"=", non-quote, non-"]", followed by
        ) \s*[\'"]?            # optional whitespace and optional quote;
      | [^=\s]\s+              # or... a non-equals sign followed by whitespace.
      )                        # End $13. Non-prelinkified-proof prefix.
      ( \b                     # $14: Other non-delimited URL.
        (?:ht|f)tps?:\/\/      # Required literal http, https, ftp or ftps prefix.
        [a-z0-9\-._~!$\'()*+,;=:\/?#[\]@%]+ # All URI chars except "&" (normal*).
        (?:                    # Either on a "&" or at the end of URI.
          (?!                  # Allow a "&" char only if not start of an...
            &(?:gt|\#0*62|\#x0*3e);                  # HTML ">" entity, or
          | &(?:amp|apos|quot|\#0*3[49]|\#x0*2[27]); # a [&\'"] entity if
            [.!&\',:?;]?        # followed by optional punctuation then
            (?:[^a-z0-9\-._~!$&\'()*+,;=:\/?#[\]@%]|$)  # a non-URI char or EOS.
          ) &                  # If neg-assertion true, match "&" (special).
          [a-z0-9\-._~!$\'()*+,;=:\/?#[\]@%]* # More non-& URI chars (normal*).
        )*                     # Unroll-the-loop (special normal*)*.
        [a-z0-9\-_~$()*+=\/#[\]@%]  # Last char can\'t be [.!&\',;:?]
      )                        # End $14. Other non-delimited URL.
    /imx';
    */
    var url_pattern = /(\()((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&'()*+,;=:\/?#[\]@%]+)(\))|(\[)((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&'()*+,;=:\/?#[\]@%]+)(\])|(\{)((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&'()*+,;=:\/?#[\]@%]+)(\})|(<|&(?:lt|#60|#x3c);)((?:ht|f)tps?:\/\/[a-z0-9\-._~!$&'()*+,;=:\/?#[\]@%]+)(>|&(?:gt|#62|#x3e);)|((?:^|[^=\s'"\]])\s*['"]?|[^=\s]\s+)(\b(?:ht|f)tps?:\/\/[a-z0-9\-._~!$'()*+,;=:\/?#[\]@%]+(?:(?!&(?:gt|#0*62|#x0*3e);|&(?:amp|apos|quot|#0*3[49]|#x0*2[27]);[.!&',:?;]?(?:[^a-z0-9\-._~!$&'()*+,;=:\/?#[\]@%]|$))&[a-z0-9\-._~!$'()*+,;=:\/?#[\]@%]*)*[a-z0-9\-_~$()*+=\/#[\]@%])/img;
    var url_replace = '$1$4$7$10$13<a href="$2$5$8$11$14">$2$5$8$11$14</a>$3$6$9$12';
    return text.replace(url_pattern, url_replace);
}
function linkify_html(text) {
    text = text.replace(/&amp;apos;/g, '&#39;'); // IE does not handle &apos; entity!
    /* Here is a commented version of the regex (in PHP string format):
    $section_html_pattern = '%# Rev:20100913_0900 github.com/jmrware/LinkifyURL
    # Section text into HTML <A> tags  and everything else.
      (                              # $1: Everything not HTML <A> tag.
        [^<]+(?:(?!<a\b)<[^<]*)*     # non A tag stuff starting with non-"<".
      |      (?:(?!<a\b)<[^<]*)+     # non A tag stuff starting with "<".
      )                              # End $1.
    | (                              # $2: HTML <A...>...</A> tag.
        <a\b[^>]*>                   # <A...> opening tag.
        [^<]*(?:(?!</a\b)<[^<]*)*    # A tag contents.
        </a\s*>                      # </A> closing tag.
      )                              # End $2:
    %ix';
    */
    section_html_pattern = /([^<]+(?:(?!<a\b)<[^<]*)*|(?:(?!<a\b)<[^<]*)+)|(<a\b[^>]*>[^<]*(?:(?!<\/a\b)<[^<]*)*<\/a\s*>)/ig;
    return text.replace(section_html_pattern, _linkify_html_callback);
}
function _linkify_html_callback(m0, m1, m2) {
    if (m2) return m2;
    return linkify(m1);
}
function prepare_linkification() {
    if (!document.getElementsByTagName) return;
    var elems = document.getElementsByTagName('*');
    for (var i = 0; i < elems.length; i++) {
        if (elems[i].className && (/\blinkify\b/.test(elems[i].className))) {
            elems[i].onclick = onclick_linkify;
            elems[i].title = 'Click to linkify URLs in this element.';
        }
    }
    elems = null;
}
function onclick_linkify() {
    this.onclick = null; // disable further clicks on this element.
    this.innerHTML = linkify_html(this.innerHTML);
    this.className = this.className.replace(/\blinkify\b/, 'linkified');
    this.setAttribute('title','All matching URLs here have been linkified.');
    analyse_links(this);
    return false;
}
function analyse_links(elem) {
    if (!document.getElementsByTagName) return false;
    var href;
    var re_paren = /\([^()[\]]*\)/g;
    var re_brack = /\[[^()[\]]*\]/g;
    var links = elem.getElementsByTagName('a');
    for (var i = 0; i < links.length; i++) {
        links[i].onclick = onclick_dummylink; // Disable links.
        href = links[i].getAttribute('href');
        href = href.replace(/%28/g, '('); // Convert URI encoding to
        href = href.replace(/%29/g, ')'); // actual chars for analysis.
        href = href.replace(/%5B/ig, '['); // (Firefox 2 converts ()[]
        href = href.replace(/%5D/ig, ']'); // to %28,%29,%5B and %5D).
        // Check for (parentheses) and [square brackets] mis-matching.
        for (var done = false; !done ; ) {
            done = true; // Assume no more nested () or [].
            while (href.search(re_paren) != -1) {
                href = href.replace(re_paren, "", href);
                done = false; // We're not done yet.
            } // Removing innermost (parentheses groups)...
            while (href.search(re_brack) != -1) {
                href = href.replace(re_brack, "", href);
                done = false; // We're not done yet.
            } // Removing innermost [square bracket groups]...
        } // All matched groups removed. No "()[]" should remain.
        if (/[()[\]]/.test(href)) { // Any "()[]" left? Flag as unbalanced.
            links[i].title = 'This link has unbalanced parentheses or square brackets.';
            links[i].className = 'unbalanced';
        } else { // Else balanced (parentheses) and [square brackets].
            links[i].title = 'This link has no unbalanced parentheses or square brackets.';
            links[i].className = 'balanced';
        }
    }
    links = null;
    return false;
}
function onclick_dummylink() {
    alert("This is a dummy link.");
    return false;
}
window.onload = prepare_linkification;
/* ]]> */
