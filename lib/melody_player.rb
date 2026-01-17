class MelodyPlayer
  def initialize(sound_bank)
    @sound_bank = sound_bank
  end

  def play(melody, loop_count: 1)
    loop_count.times do |loop_num|
      puts "Playing loop #{loop_num + 1}/#{loop_count}..." if loop_count > 1
      play_once(melody)
    end
  end

  def play_once(melody)
    # compute start times for each note (cumulative start offsets)
    durations = melody.notes.map { |_, d| d }
    start_times = []
    start = 0.0
    durations.each do |d|
      start_times << start
      start += d
    end

    threads = []
    melody.notes.each_with_index do |(note, _d), index|
      start_time = start_times[index]
      threads << Thread.new(start_time, note) do |t, n|
        sleep t if t > 0
        @sound_bank.play_note(n)
      end
    end

    threads.each(&:join)
  end
end
