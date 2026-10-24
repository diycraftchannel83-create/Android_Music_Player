import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const AndroidMusicPlayerApp());

const Color ink = Color(0xFF070914);
const Color panel = Color(0xFF111629);
const Color cyan = Color(0xFF16D9F5);
const Color violet = Color(0xFF9B5CFF);
const Color pink = Color(0xFFFF3DAD);

class AndroidMusicPlayerApp extends StatelessWidget {
  const AndroidMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Android Music Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: ink,
          colorScheme: ColorScheme.fromSeed(
            seedColor: cyan,
            brightness: Brightness.dark,
            surface: panel,
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: cyan,
            thumbColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            overlayColor: cyan.withValues(alpha: .14),
          ),
        ),
        home: const PlayerShell(),
      );
}

class PlayerShell extends StatefulWidget {
  const PlayerShell({super.key});
  @override
  State<PlayerShell> createState() => _PlayerShellState();
}

class _PlayerShellState extends State<PlayerShell> {
  int tab = 0;
  bool playing = false;
  bool bassEnabled = true;
  double bass = 0.72;
  final bands = <double>[0.72, 0.58, 0.43, 0.50, 0.66];
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<PlatformFile> localTracks = <PlatformFile>[];
  int currentTrack = 0;
  String? audioError;

  Future<void> pickTracks() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true, withData: false);
      if (result == null) return;
      final valid = result.files.where((f) => f.path != null).toList();
      if (!mounted) return;
      setState(() { localTracks.addAll(valid); audioError = null; });
      if (localTracks.isNotEmpty && audioPlayer.audioSource == null) await playTrack(0);
    } catch (e) {
      if (mounted) setState(() => audioError = 'Tidak dapat membuka file audio: $e');
    }
  }

  Future<void> playTrack(int index) async {
    if (localTracks.isEmpty) { await pickTracks(); return; }
    final safeIndex = index.clamp(0, localTracks.length - 1);
    final path = localTracks[safeIndex].path;
    if (path == null) return;
    try {
      await audioPlayer.setFilePath(path);
      if (!mounted) return;
      setState(() { currentTrack = safeIndex; playing = true; audioError = null; });
      await audioPlayer.play();
    } catch (e) {
      if (mounted) setState(() => audioError = 'Gagal memutar audio: $e');
    }
  }

  Future<void> togglePlayback() async {
    if (localTracks.isEmpty) { await pickTracks(); return; }
    if (audioPlayer.playing) {
      await audioPlayer.pause();
      if (mounted) setState(() => playing = false);
    } else {
      if (audioPlayer.audioSource == null) { await playTrack(currentTrack); }
      else { await audioPlayer.play(); if (mounted) setState(() => playing = true); }
    }
  }

  @override
  void dispose() { audioPlayer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _equalizer(),
      _bassPage(),
      _library(),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: tab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0C1020),
        indicatorColor: cyan.withValues(alpha: .15),
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.equalizer_rounded), label: 'Equalizer'),
          NavigationDestination(icon: Icon(Icons.graphic_eq_rounded), label: 'Super Bass'),
          NavigationDestination(icon: Icon(Icons.library_music_rounded), label: 'Library'),
        ],
      ),
    );
  }

  Widget _home() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(colors: [cyan, violet, pink]),
              ),
              child: const Icon(Icons.graphic_eq_rounded, color: ink, size: 29),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANDROID', style: TextStyle(fontSize: 12, letterSpacing: 3, color: cyan, fontWeight: FontWeight.w800)),
                Text('Music Player', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              ],
            )),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          ]),
          const SizedBox(height: 28),
          const Text('FEEL EVERY BEAT', style: TextStyle(color: cyan, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Your sound.\nYour rules.', style: TextStyle(fontSize: 34, height: 1.12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _visualizer(),
          const SizedBox(height: 20),
          _nowPlaying(),
          const SizedBox(height: 26),
          const _SectionTitle('Quick sound controls', 'TUNE'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _featureCard(Icons.equalizer_rounded, 'Equalizer', '5-band tuning', violet, () => setState(() => tab = 1))),
            const SizedBox(width: 12),
            Expanded(child: _featureCard(Icons.speaker_rounded, 'Super Bass', 'Deep low end', cyan, () => setState(() => tab = 2))),
          ]),
          const SizedBox(height: 24),
          const _SectionTitle('Recently played', 'VIEW ALL'),
          const SizedBox(height: 12),
          _track('Electric Storm', 'Wins', Icons.bolt_rounded, violet),
          _track('The Best Thing in My Life', 'Wins', Icons.nightlight_round, pink),
          _track('Ranah Minang Tacinto', 'Wins', Icons.waves_rounded, cyan),
        ],
      );

  Widget _visualizer() => Container(
        height: 142,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF17214A), Color(0xFF17102E), Color(0xFF0B1825)],
          ),
          border: Border.all(color: cyan.withValues(alpha: .25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(27, (i) {
            final h = 18.0 + ((i * 17 + 11) % 79);
            return Container(
              width: 5, height: h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [cyan, violet, pink],
                ),
                boxShadow: [BoxShadow(color: violet.withValues(alpha: .2), blurRadius: 8)],
              ),
            );
          }),
        ),
      );

  Widget _nowPlaying() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [violet, pink]),
              ),
              child: const Icon(Icons.music_note_rounded, size: 34),
            ),
            const SizedBox(width: 13),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Electric Storm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Wins • Demo track', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded, color: pink)),
          ]),
          const SizedBox(height: 8),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('1:28', style: TextStyle(color: Colors.white54, fontSize: 11)),
            Text('4:32', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
          Slider(value: .34, onChanged: (_) {}),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.shuffle_rounded, color: Colors.white54)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous_rounded, size: 34)),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [cyan, violet]),
              ),
              child: IconButton(
                onPressed: togglePlayback,
                icon: Icon(audioPlayer.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: ink, size: 32),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next_rounded, size: 34)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.repeat_rounded, color: Colors.white54)),
          ]),
        ]),
      );

  Widget _equalizer() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _PageHeading('Powerful Equalizer', 'Fine-tune your sound'),
          const SizedBox(height: 22),
          _presetChips(),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: List.generate(5, (i) => Expanded(
                child: Column(children: [
                  Text(['+6', '+3', '0', '+3', '+6'][i], style: const TextStyle(color: cyan, fontSize: 11)),
                  SizedBox(
                    height: 230,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        min: 0, max: 1, value: bands[i],
                        onChanged: (v) => setState(() => bands[i] = v),
                      ),
                    ),
                  ),
                  Text(['60 Hz', '230 Hz', '910 Hz', '3.6 kHz', '14 kHz'][i],
                    style: const TextStyle(fontSize: 10, color: Colors.white70)),
                ]),
              )),
            ),
          ),
          const SizedBox(height: 18),
          const Text('PRESETS', style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 11)),
          const SizedBox(height: 12),
          Wrap(spacing: 9, runSpacing: 9, children: ['Normal', 'Super Bass', 'Rock', 'Pop', 'Jazz', 'Vocal', 'Classical', 'Electronic']
            .map((s) => ActionChip(
              label: Text(s),
              avatar: Icon(Icons.graphic_eq_rounded, size: 16, color: s == 'Super Bass' ? cyan : violet),
              backgroundColor: panel,
              side: BorderSide(color: s == 'Super Bass' ? cyan : Colors.white12),
              onPressed: () => setState(() {
                final values = s == 'Super Bass' ? [0.95, 0.84, 0.53, 0.45, 0.5] :
                    s == 'Rock' ? [0.85, 0.72, 0.42, 0.75, 0.86] :
                    s == 'Vocal' ? [0.35, 0.48, 0.82, 0.77, 0.55] : [0.5, 0.5, 0.5, 0.5, 0.5];
                for (var i = 0; i < bands.length; i++) { bands[i] = values[i]; }
              }),
            )).toList()),
          const SizedBox(height: 20),
          const _InfoNote('Design preview', 'Equalizer sliders and presets are UI controls in this design foundation. They do not yet process audio until connected to a playback engine and Android DSP effects.'),
        ],
      );

  Widget _bassPage() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _PageHeading('Super Bass', 'Deep bass. Clean sound.'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(colors: [Color(0xFF102A4A), Color(0xFF20113F), Color(0xFF180F2C)]),
              border: Border.all(color: cyan.withValues(alpha: .25)),
            ),
            child: Column(children: [
              Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cyan.withValues(alpha: .8), width: 2),
                  boxShadow: [BoxShadow(color: cyan.withValues(alpha: .15), blurRadius: 28, spreadRadius: 8)],
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFF263C6A), Color(0xFF080B16)]),
                    border: Border.all(color: violet, width: 3),
                  ),
                  child: const Icon(Icons.speaker_rounded, size: 82, color: cyan),
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Super Bass', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Bass boost control design'),
                value: bassEnabled,
                activeThumbColor: cyan,
                onChanged: (v) => setState(() => bassEnabled = v),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Intensity', style: TextStyle(color: Colors.white70)),
                Text('${(bass * 100).round()}%', style: const TextStyle(color: cyan, fontWeight: FontWeight.bold)),
              ]),
              Slider(value: bass, onChanged: bassEnabled ? (v) => setState(() => bass = v) : null),
            ]),
          ),
          const SizedBox(height: 18),
          const _InfoNote('Powerful, not distorted', 'The intended implementation should apply bass enhancement through supported Android audio effects, with level limits to reduce clipping and distortion.'),
        ],
      );

  Widget _library() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _PageHeading('Your Library', 'Play audio files stored on your device'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: pickTracks,
            icon: const Icon(Icons.library_add_rounded),
            label: const Text('Add music files'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
          if (audioError != null) ...[
            const SizedBox(height: 12),
            _InfoNote('Audio message', audioError!),
          ],
          const SizedBox(height: 18),
          if (localTracks.isEmpty)
            const _InfoNote('Your library is empty', 'Tap Add music files and select audio files from your device. Playback works for selected local files; equalizer DSP and background playback are not connected yet.')
          else
            ...List.generate(localTracks.length, (i) {
              final track = localTracks[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: panel,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  leading: Icon(i == currentTrack ? Icons.equalizer_rounded : Icons.music_note_rounded, color: i == currentTrack ? cyan : violet),
                  title: Text(track.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(track.extension?.toUpperCase() ?? 'AUDIO'),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: cyan, size: 30),
                    onPressed: () => playTrack(i),
                  ),
                  onTap: () => playTrack(i),
                ),
              );
            }),
        ],
      );

  Widget _presetChips() => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)),
        child: const Row(children: [
          Icon(Icons.tune_rounded, color: cyan),
          SizedBox(width: 12),
          Expanded(child: Text('Custom preset', style: TextStyle(fontWeight: FontWeight.bold))),
          Icon(Icons.keyboard_arrow_down_rounded),
        ]),
      );

  Widget _featureCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: .25))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ]),
        ),
      );

  Widget _track(String title, String artist, IconData icon, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .17), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            const Icon(Icons.play_circle_fill_rounded, color: cyan, size: 30),
          ]),
        ),
      );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading(this.title, this.subtitle);
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.white54)),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.action);
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
        Text(action, style: const TextStyle(fontSize: 10, color: cyan, letterSpacing: 1.4)),
      ]);
}

class _InfoNote extends StatelessWidget {
  const _InfoNote(this.title, this.body);
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: cyan, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: Colors.white70, height: 1.45)),
        ]),
      );
}
