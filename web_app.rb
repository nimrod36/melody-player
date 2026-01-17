require 'sinatra'
require 'json'
require_relative './lib/melody'
require_relative './lib/melody_player'
require_relative './lib/sound_bank'

set :root, File.dirname(__FILE__)
set :public_folder, File.join(settings.root, 'public')

# Initialize sound bank
melodies_dir = File.join(settings.root, 'melodies')
sound_bank = SoundBank.new(File.join(melodies_dir, 'sound_bank'))

# Store playback state
playback_state = {
  current: nil,
  playing: false,
  thread: nil
}

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/api/melodies' do
  melodies = []
  if Dir.exist?(melodies_dir)
    Dir.glob(File.join(melodies_dir, '*.txt')).each do |file|
      melody = Melody.new(file)
      if melody.valid?
        melodies << {
          name: File.basename(file, '.txt'),
          file: File.basename(file),
          notes: melody.notes.length,
          duration: melody.duration.round(2)
        }
      end
    end
  end
  melodies.to_json
end

get '/api/notes' do
  notes = sound_bank.available_notes
  notes.to_json
end

post '/api/play' do
  data = JSON.parse(request.body.read)
  melody_file = data['melody']
  loop_count = data['loop'].to_i.clamp(1, 10)
  speed = data['speed'].to_f.clamp(0.5, 2.0)
  transpose = data['transpose'].to_i.clamp(-12, 12)

  file_path = File.join(melodies_dir, melody_file)

  unless File.exist?(file_path)
    return { error: 'Melody file not found' }.to_json
  end

  melody = Melody.new(file_path)
  unless melody.valid?
    return { error: 'Invalid melody file' }.to_json
  end

  # Apply transformations
  notes = melody.notes
  notes = Melody.new(file_path).transpose(transpose) if transpose != 0
  if speed != 1.0
    if speed > 1.0
      notes = Melody.new(file_path).speed_up(speed)
    else
      notes = Melody.new(file_path).speed_down(1.0 / speed)
    end
  end
  melody.instance_variable_set(:@notes, notes)

  # Stop any currently playing melody
  if playback_state[:thread]&.alive?
    playback_state[:playing] = false
    playback_state[:thread].kill
  end

  playback_state[:current] = melody_file
  playback_state[:playing] = true

  # Play in background thread
  playback_state[:thread] = Thread.new do
    player = MelodyPlayer.new(sound_bank)
    loop_count.times do |i|
      break unless playback_state[:playing]
      player.play_once(melody)
    end
    playback_state[:playing] = false
  end

  { status: 'playing', melody: melody_file }.to_json
end

post '/api/stop' do
  if playback_state[:thread]&.alive?
    playback_state[:playing] = false
    playback_state[:thread].kill
  end
  { status: 'stopped' }.to_json
end

get '/api/status' do
  { playing: playback_state[:playing], current: playback_state[:current] }.to_json
end
