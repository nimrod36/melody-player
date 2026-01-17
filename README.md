# Melody Player - Enhanced Version

A modular melody player with CLI and web interface built in Ruby.

## Project Structure

```
joytunes/
├── lib/
│   ├── melody.rb           # Melody parsing and manipulation
│   ├── melody_player.rb    # Playback engine
│   └── sound_bank.rb       # Sound file management
├── bin/
│   └── melody_player       # Enhanced CLI script
├── melodies/
│   ├── *.txt              # Melody files
│   └── sound_bank/        # WAV audio files
├── public/
│   ├── index.html         # Web UI
│   ├── css/style.css      # Styling
│   └── js/app.js          # Frontend logic
├── web_app.rb             # Sinatra web server
└── Gemfile
```

## Setup

### Prerequisites
- Ruby 2.7+
- Sinatra gem

### Installation

1. Add gems to Gemfile if needed:
```bash
bundle add sinatra
```

2. Install dependencies:
```bash
bundle install
```

## Usage

### CLI (Command Line Interface)

```bash
ruby bin/melody_player <MELODY_FILE> [OPTIONS]
```

#### Options:
- `-l, --list` - List available notes in sound bank
- `--loop N` - Play melody N times (default: 1)
- `--speed FACTOR` - Play at speed (1.0=normal, 2.0=double, 0.5=half)
- `--transpose SEMITONES` - Transpose by semitones (-12 to +12)
- `-h, --help` - Show help message

#### Examples:

```bash
# Play a melody once
ruby bin/melody_player MelodyGOT.txt

# Play with transformations
ruby bin/melody_player MelodyHappyBirthday.txt --loop 2 --speed 1.5 --transpose 2

# List available notes
ruby bin/melody_player --list

# Play from full path
ruby bin/melody_player /path/to/melody.txt
```

### Web Interface

1. Start the server:
```bash
ruby web_app.rb
```

2. Open your browser:
```
http://localhost:4567
```

3. Features:
   - Browse all available melodies
   - Play/stop melodies
   - Adjust playback speed (0.5x to 2.0x)
   - Transpose melodies (-12 to +12 semitones)
   - Loop playback (1-10 times)
   - View available notes
   - Real-time playback status

## Melody File Format

Melody files are plain text with notes and durations:

```
C4:0.5 D4:0.5 E4:0.5 F4:0.5
G4:1.0 G4:1.0
```

Each note is `NOTE:DURATION` where:
- `NOTE`: Note name (C, C#, D, D#, etc.) + octave (0-8)
- `DURATION`: Duration in seconds

## Class Overview

### Melody
- `parse_melody(file)` - Parse melody file
- `transpose(semitones)` - Transpose notes
- `speed_up(factor)` - Speed up playback
- `speed_down(factor)` - Slow down playback

### MelodyPlayer
- `play(melody, loop_count)` - Play melody with loops
- `play_once(melody)` - Play once (threaded playback)

### SoundBank
- `play_note(note)` - Play a note WAV file
- `available_notes()` - List all notes
- `note_exists?(note)` - Check if note exists

## Adding New Melodies

1. Create a `.txt` file in `melodies/` directory
2. Format: `NOTE:DURATION NOTE:DURATION ...`
3. Ensure corresponding `.wav` files exist in `melodies/sound_bank/`

## Adding New Sounds

1. Add `.wav` files to `melodies/sound_bank/`
2. Name format: `NOTE.wav` (e.g., `C4.wav`, `D#5.wav`)
3. Files are automatically detected by the app

## Future Enhancements

- MIDI file support
- Audio file export
- Melody composition editor
- Playlist management
- Real-time MIDI input
- Multiple instrument support
- Audio visualization
- User accounts and melody sharing
