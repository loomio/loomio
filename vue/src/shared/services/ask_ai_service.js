/**
 * AskAiService
 *
 * Frontend helper for calling the Ask AI endpoint to generate a response
 * based on a discussion's context.
 *
 * Usage:
 *   import AskAiService from '@/shared/services/ask_ai_service';
 *   const { answer } = await AskAiService.ask(discussionId, optionalPrompt);
 *
 * Backend endpoint:
 *   POST /api/v1/ask_ai
 *   Params: { discussion_id: Number, prompt?: String }
 *   Returns: { answer: String, model?: String, usage?: Object, id?: String }
 */

import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import Session from '@/shared/services/session';
import { marked } from 'marked';
import { customRenderer, options as markedOptions } from '@/shared/helpers/marked';

export default new class AskAiService {
  /**
   * Request AI-extracted poll options for a discussion.
   * targetOrId can be a number (discussion id) or an object { discussion_id, max }.
   * Returns: { options: Array<{name: string, meaning?: string}> }
   */
  async askOptions(discussionId, max = 30) {
    try {
      const result = await Records.remote.post('ask_ai/options', { discussion_id: discussionId, max: max });
      const options = (result && result.options) || [];
      return { options };
    } catch (e) {
      const status = e && (e.status || e.statusCode);
      let messageKey;

      switch (status) {
        case 401:
        case 403:
          messageKey = 'ask_ai.errors.unauthorized';
          break;
        case 404:
          messageKey = 'ask_ai.errors.not_found';
          break;
        case 429:
          messageKey = 'ask_ai.messages.too_many_requests';
          break;
        case 502:
          messageKey = 'ask_ai.errors.bad_gateway';
          break;
        case 503:
          messageKey = 'ask_ai.errors.service_unavailable';
          break;
        default:
          messageKey = 'ask_ai.messages.failed';
      }

      Flash.error(messageKey);
      throw e;
    }
  }

  /**
   * Request an AI-generated response for a discussion.
   * @param {number|object} discussionOrId - Discussion id or Discussion model with id
   * @param {string} prompt - Optional prompt text. Defaults to defaultPrompt().
   * @returns {Promise<{answer: string, model?: string, usage?: object, id?: string}>}
   */
  async ask(target, prompt, opts = {}) {
    try {
      const result = await Records.remote.post('ask_ai', {
        ...target,
        prompt
      });

      if (!result || typeof result.answer !== 'string') {
        throw new Error('Empty response from Ask AI');
      }

      const prefFormat = (opts && opts.format) || Session.defaultFormat();

      if (prefFormat === 'html') {
        const raw = String(result.answer || '').trim();
        const looksLikeHtml = /<\/?[a-z][\s\S]*>/i.test(raw);
        if (!looksLikeHtml) {
          marked.setOptions(Object.assign({ renderer: customRenderer() }, markedOptions));
          result.answer = marked(raw);
        } else {
          result.answer = raw;
        }
        result.format = 'html';
      } else {
        // Preserve markdown/plain text
        result.answer = String(result.answer || '');
        result.format = 'md';
      }

      return result;
    } catch (e) {
      // Expect backend to handle auth and visibility errors with proper codes
      // Display a generic flash error and rethrow for the caller to handle UI specifics
      Flash.error('common.something_went_wrong');
      throw e;
    }
  }

  /**
   * Request AI poll scaffold (title, details, options) from a discussion.
   * targetOrId can be a number (discussion id) or an object { discussion_id, max, prompt }.
   * @param {number|object} targetOrId
   * @param {{max?: number, prompt?: string}} opts
   * @returns {Promise<{title: string, details: (string|null), options: Array<{name: string, meaning?: string}>}>}
   */
  async askScaffold(target, prompt) {

    try {
      const result = await Records.remote.post('ask_ai/scaffold', { ...target, prompt: prompt, max: 30 });
      const title = (result && (result.title ?? result['title'])) || '';
      const details = (result && (result.details ?? result['details'])) || null;
      const options = (result && (result.options ?? result['options'])) || [];
      return { title, details, options };
    } catch (e) {
      const status = e && (e.status || e.statusCode);
      let messageKey;

      switch (status) {
        case 401:
        case 403:
          messageKey = 'ask_ai.errors.unauthorized'; break;
        case 404:
          messageKey = 'ask_ai.errors.not_found'; break;
        case 429:
          messageKey = 'ask_ai.messages.too_many_requests'; break;
        case 502:
          messageKey = 'ask_ai.errors.bad_gateway'; break;
        case 503:
          messageKey = 'ask_ai.errors.service_unavailable'; break;
        default:
          messageKey = 'ask_ai.messages.failed';
      }

      Flash.error(messageKey);
      throw e;
    }
  }
}();
