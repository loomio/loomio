class DateTimeInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div,
                         class: 'controls input-group date form_datetime',
                         data: {date: formatted_value,
                                'date-format' => 'yyyy-mm-dd H:ii p' }) do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat span_remove
      template.concat span_table
    end
  end

  def formatted_value
    object.send(attribute_name).strftime('%Y-%m-%d %l:%M %p').gsub('  ', ' ')
  end

  def input_html_options
    {class: 'form-control', value: formatted_value}
  end

  def span_remove
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_remove
    end
  end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  def icon_remove
    "<i class='glyphicon glyphicon-remove'></i>".html_safe
  end

  def icon_table
    "<i class='glyphicon glyphicon-th'></i>".html_safe
  end

end
