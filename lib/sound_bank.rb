class SoundBank
  def initialize(sound_lib_path)
    @sound_lib = sound_lib_path
  end

  def play_note(note)
    path = File.join(@sound_lib, "#{note}.wav")
    unless File.exist?(path)
      warn "Warning: sound file not found: #{path}"
      return false
    end
    system('afplay', path)
    true
  end

  def available_notes
    return [] unless Dir.exist?(@sound_lib)
    Dir.glob(File.join(@sound_lib, '*.wav')).map { |f| File.basename(f, '.wav') }.sort
  end

  def note_exists?(note)
    File.exist?(File.join(@sound_lib, "#{note}.wav"))
  end
end
