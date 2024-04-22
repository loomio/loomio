require_relative Rails.root.join('lib/pie_chart')

class PieChartController < ApplicationController
  def show
    scores = params[:scores].split(',').map(&:to_i)
    colors = params[:colors].split(',').map {|c| "##{c}"}

    svg = PieChartSVG.from_primitives(scores, colors)

    name = scores.join() + colors.join()

    file = Tempfile.new('name')
    file.write(svg.render)
    file.rewind

    png = ImageProcessing::MiniMagick
    .source(file)
    .convert("png")
    .call

    file.unlink

    send_file(png, type: 'image/png', disposition: 'inline')
  end
end
