let currentMelody = null;
let isPlaying = false;

// Load melodies on page load
document.addEventListener('DOMContentLoaded', () => {
    loadMelodies();
    loadNotes();
    setupControls();
    checkPlaybackStatus();
});

// Update speed display
document.getElementById('speed').addEventListener('input', (e) => {
    document.getElementById('speed-value').textContent = parseFloat(e.target.value).toFixed(1) + 'x';
});

// Update transpose display
document.getElementById('transpose').addEventListener('input', (e) => {
    document.getElementById('transpose-value').textContent = e.target.value;
});

function loadMelodies() {
    fetch('/api/melodies')
        .then(res => res.json())
        .then(melodies => {
            const list = document.getElementById('melody-list');
            if (melodies.length === 0) {
                list.innerHTML = '<p>No melodies found</p>';
                return;
            }

            list.innerHTML = melodies.map(melody => `
                <div class="melody-card" onclick="playMelody('${melody.file}')">
                    <div class="melody-name">${melody.name}</div>
                    <div class="melody-info">
                        <span>🎵 ${melody.notes} notes</span>
                        <span>⏱️ ${melody.duration}s</span>
                    </div>
                </div>
            `).join('');
        })
        .catch(err => {
            console.error('Error loading melodies:', err);
            document.getElementById('melody-list').innerHTML = '<p>Error loading melodies</p>';
        });
}

function loadNotes() {
    fetch('/api/notes')
        .then(res => res.json())
        .then(notes => {
            const list = document.getElementById('notes-list');
            if (notes.length === 0) {
                list.innerHTML = '<p>No notes available</p>';
                return;
            }

            list.innerHTML = notes.map(note => `
                <div class="note-badge">${note}</div>
            `).join('');
        })
        .catch(err => {
            console.error('Error loading notes:', err);
            document.getElementById('notes-list').innerHTML = '<p>Error loading notes</p>';
        });
}

function playMelody(melodyFile) {
    const loopCount = parseInt(document.getElementById('loop-count').value);
    const speed = parseFloat(document.getElementById('speed').value);
    const transpose = parseInt(document.getElementById('transpose').value);

    const payload = {
        melody: melodyFile,
        loop: loopCount,
        speed: speed,
        transpose: transpose
    };

    fetch('/api/play', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Error: ' + data.error);
                return;
            }

            currentMelody = melodyFile;
            isPlaying = true;
            updateUIState();
            updatePlayingMelody();
        })
        .catch(err => console.error('Error playing melody:', err));
}

function stopPlayback() {
    fetch('/api/stop', { method: 'POST' })
        .then(() => {
            isPlaying = false;
            currentMelody = null;
            updateUIState();
            updatePlayingMelody();
        })
        .catch(err => console.error('Error stopping playback:', err));
}

function setupControls() {
    document.getElementById('stop-btn').addEventListener('click', stopPlayback);
}

function updateUIState() {
    document.getElementById('stop-btn').disabled = !isPlaying;
}

function updatePlayingMelody() {
    document.querySelectorAll('.melody-card').forEach(card => {
        card.classList.remove('playing');
    });

    if (currentMelody) {
        const cards = Array.from(document.querySelectorAll('.melody-card'));
        cards.forEach(card => {
            const onClick = card.getAttribute('onclick');
            if (onClick.includes(`'${currentMelody}'`)) {
                card.classList.add('playing');
            }
        });
    }
}

function checkPlaybackStatus() {
    setInterval(() => {
        fetch('/api/status')
            .then(res => res.json())
            .then(data => {
                isPlaying = data.playing;
                currentMelody = data.current;
                updateUIState();
                if (!isPlaying) {
                    updatePlayingMelody();
                }
            })
            .catch(err => console.error('Error checking status:', err));
    }, 1000);
}
