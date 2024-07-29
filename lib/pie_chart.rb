require 'victor'

class PieChartSVG
  SIZE = 512

  def self.from_primitives(scores, colors)
    slices = []
    scores.each_with_index do |v, i|
      slices << {value: (v.to_f / scores.sum) * 100, color: colors[i]}
    end
    draw(slices)
  end

  def self.from_poll(p)
    draw(pie_slices(p))
  end

  def self.arc_path(start_angle, end_angle)
    radius = SIZE/2
    rad = Math::PI / 180;
    x1 = radius + (radius * Math.cos(-start_angle * rad));
    x2 = radius + (radius * Math.cos(-end_angle * rad));
    y1 = radius + (radius * Math.sin(-start_angle * rad));
    y2 = radius + (radius * Math.sin(-end_angle * rad));
    return ["M", radius, radius, "L", x1, y1, "A", radius, radius, 0, (((end_angle - start_angle) > 180) ? 1 : 0), 0, x2, y2, "z"].join(' ');
  end

  def self.pie_slices(poll)
    results = PollService.calculate_results(poll, poll.poll_options)
    results.filter { |r| r[poll.chart_column] }.map do |r|
      {value: r[poll.chart_column], color: r[:color] }
    end
  end

  def self.draw(slices)
    svg = Victor::SVG.new(width: SIZE, height: SIZE)
    case slices.length
    when 0
      svg.circle cx: SIZE/2, cy: SIZE/2, r: SIZE/2, fill: 'grey'
    when 1
      svg.circle cx: SIZE/2, cy: SIZE/2, r: SIZE/2, fill: slices[0][:color]
    else
      start = 90
      slices.each do |slice|
        angle = (360 * slice[:value]) / 100
        svg.path d: arc_path(start, start+angle), stroke_width: 0, fill: slice[:color]
        start += angle
      end
    end
    svg
  end
end
