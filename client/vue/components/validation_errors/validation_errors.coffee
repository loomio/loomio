module.exports =
  props:
    subject: Object
    field: String
  template:
    """
    <div class="lmo-validation-error">
      <label v-if="subject.errors[field]" for="field + '-error'" class="md-container-ignore md-no-float lmo-validation-error__message">
        <span>{{subject.errors[field].join(', ')}}</span>
      </label>
    </div>
    """
