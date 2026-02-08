# frozen_string_literal: true

class Views::Groups::ExportTable < Views::Base
  def initialize(name:, records:, fields:, exporter:)
    @name = name
    @records = records
    @fields = fields
    @exporter = exporter
  end

  def view_template
    h2 { plain "#{@name} (#{@records.length})" }
    if @records.length > 0
      table do
        thead do
          @fields.each do |field|
            th { plain @exporter.field_names.fetch(field) { field }.humanize }
          end
        end
        tbody do
          @records.each do |record|
            tr do
              @fields.each do |field|
                td { plain record.send(field).to_s }
              end
            end
          end
        end
      end
    end
  end
end
