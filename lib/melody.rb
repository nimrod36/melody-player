class Melody
  attr_reader :notes, :file_name

  def initialize(file_name)
    @file_name = file_name
    @notes = parse_melody(file_name)
  end

  def valid?
    !@notes.empty?
  end

  def duration
    @notes.sum { |_, d| d }
  end

  def transpose(semitones)
    note_map = {
      'C' => 0, 'C#' => 1, 'D' => 2, 'D#' => 3, 'E' => 4, 'F' => 5,
      'F#' => 6, 'G' => 7, 'G#' => 8, 'A' => 9, 'A#' => 10, 'B' => 11
    }
    reverse_map = note_map.invert

    @notes.map do |(note, duration)|
      transposed = transpose_note(note, semitones, note_map, reverse_map)
      [transposed, duration]
    end
  end

  def speed_up(factor)
    @notes.map { |(note, duration)| [note, duration / factor] }
  end

  def speed_down(factor)
    @notes.map { |(note, duration)| [note, duration * factor] }
  end

  private

  def parse_melody(file_name)
    note_time_arr = []
    File.foreach(file_name) do |line|
      line.split.each do |note_time|
        note, time = note_time.split(':', 2)
        next unless note && time
        begin
          dur = Float(time)
        rescue ArgumentError
          next
        end
        note_time_arr << [note, dur]
      end
    end
    note_time_arr
  end

  def transpose_note(note, semitones, note_map, reverse_map)
    match = note.match(/^([A-G]#?)(\d)$/)
    return note unless match

    note_name, octave = match.captures
    base_val = note_map[note_name]
    return note unless base_val

    new_val = (base_val + semitones) % 12
    new_octave = octave.to_i + ((base_val + semitones) / 12)
    new_note_name = reverse_map[new_val]

    "#{new_note_name}#{new_octave}"
  end
end
