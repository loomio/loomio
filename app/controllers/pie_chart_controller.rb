require_relative Rails.root.join('lib/pie_chart_svg')

class PieChartController < ApplicationController
  HEX_COLOR = /\A[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?\z/
  MAX_SLICES = 50

  def show
    raw_scores = params[:scores].to_s.split(',')
    raw_colors = params[:colors].to_s.split(',')
    return head :bad_request if raw_scores.empty? || raw_scores.length > MAX_SLICES
    return head :bad_request unless raw_colors.all? { |c| HEX_COLOR.match?(c) }

    scores = raw_scores.map { |s| [ s.to_i, 0 ].max }
    colors = raw_colors.map { |c| "##{c}" }

    svg = PieChartSvg.from_primitives(scores, colors)

    Tempfile.create([ 'pie_chart', '.svg' ]) do |file|
      file.write(svg.render)
      file.flush

      send_data(render_svg_to_png(file), type: 'image/png', disposition: 'inline')
    end
  end

  private

  def render_svg_to_png(svg_file)
    if ENV['HOTCELL_ROOT'].present?
      Tempfile.create([ 'pie_chart', '.png' ], binmode: true) do |output|
        File.open(svg_file.path, 'rb') do |readable|
          File.open(output.path, 'wb') do |writable|
            HotCellSvgToPng.perform_in_hotcell([ readable ], [ writable ])
          end
        end
        File.binread(output.path)
      end
    else
      png = ImageProcessing::MiniMagick.source(svg_file).loader(background: 'none').convert('png').call
      begin
        File.binread(png.path)
      ensure
        png.close!
      end
    end
  end
end
