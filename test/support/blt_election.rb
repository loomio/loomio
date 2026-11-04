# Reads elections in the BLT format used by STV counting software, so the
# STV counters can be tested against published counts.
#
#   4 2            candidates, seats
#   -3             optional withdrawn candidates (ignored here)
#   7 1 2 0        a weight, preferences by candidate number, then an
#                  optional 0
#   0              end of ballots
#   "Name" ...     one quoted name per candidate, then the election title
#
# Candidate numbers become poll option ids.
class BltElection
  Option = Struct.new(:id, :name)

  attr_reader :seats, :options, :ballots

  def self.parse(text)
    lines = text.lines.map(&:strip).reject { |line| line.empty? || line.start_with?("#") }
    candidate_count, seats = lines.shift.split.map(&:to_i)
    lines.shift if lines.first.start_with?("-")

    ballots = []
    while (line = lines.shift) != "0"
      weight, *prefs = line.split.map(&:to_i)
      prefs.pop if prefs.last == 0
      weight.times { ballots << prefs }
    end

    # A name line can carry further quoted fields, such as a party.
    names = lines.first(candidate_count).map { |line| line[/"([^"]*)"/, 1] }
    new(seats: seats, names: names, ballots: ballots)
  end

  # A small random election. Candidates have uneven popularity so that some
  # reach the quota, and ballots rank a random number of candidates so that
  # some exhaust.
  def self.random(rng)
    candidate_count = rng.rand(3..8)
    popularity = Array.new(candidate_count) { rng.rand(1..10) }
    ballots = Array.new(rng.rand(5..60)) do
      ranking = (1..candidate_count).sort_by { |cid| -rng.rand * popularity[cid - 1] }
      ranking.first(rng.rand(1..candidate_count))
    end
    names = (1..candidate_count).map { |cid| "C#{cid}" }
    new(seats: rng.rand(1...candidate_count), names: names, ballots: ballots)
  end

  def initialize(seats:, names:, ballots:)
    @seats = seats
    @options = names.each_with_index.map { |name, i| Option.new(i + 1, name) }
    @ballots = ballots
  end

  def to_blt(title = "Election")
    lines = ["#{options.size} #{seats}"]
    ballots.tally.each { |prefs, count| lines << [count, *prefs, 0].join(" ") }
    lines << "0"
    options.each { |option| lines << %("#{option.name}") }
    lines << %("#{title}")
    lines.join("\n") + "\n"
  end
end
