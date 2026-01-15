#!/usr/bin/env ruby

script_dir = File.dirname(__FILE__)

if ARGV.empty?
  puts "To use run: ruby melody_player.rb <MELODY NAME>"
  exit 0
end

input = ARGV[0]
file_name = if File.exist?(input)
              input
            else
              File.join(script_dir, input)
            end

unless File.exist?(file_name)
  STDERR.puts "Melody file not found: #{file_name}"
  exit 1
end

sound_lib = File.expand_path('sound_bank', script_dir)

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

def play_note(note, sound_lib)
  path = File.join(sound_lib, "#{note}.wav")
  unless File.exist?(path)
    STDERR.puts "Warning: sound file not found: #{path}"
    return
  end
  system('afplay', path)
end

melody = parse_melody(file_name)
if melody.empty?
  STDERR.puts "No notes parsed from #{file_name}"
  exit 1
end

# compute start times for each note (cumulative start offsets)
durations = melody.map { |_, d| d }
start_times = []
start = 0.0
durations.each do |d|
  start_times << start
  start += d
end

threads = []
melody.each_with_index do |(note, _d), index|
  start_time = start_times[index]
  threads << Thread.new(start_time, note, sound_lib) do |t, n, lib|
    sleep t if t > 0
    play_note(n, lib)
  end
end

threads.each(&:join)
