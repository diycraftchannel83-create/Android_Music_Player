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
  bool surroundEnabled = true;
  bool effectsEnabled = true;
  double surroundWidth = 0.70;
  double bass = 0.72;
  final bands = <double>[0.72, 0.58, 0.43, 0.50, 0.66, 0.58, 0.72];
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
    final safeIndex = index.clamp(0, localTracks.length - 1).toInt();
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(colors: [cyan, violet, pink]),
                boxShadow: [BoxShadow(color: violet.withValues(alpha: .25), blurRadius: 18)],
              ),
              child: const Icon(Icons.music_note_rounded, color: ink, size: 30),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANDROID', style: TextStyle(fontSize: 11, letterSpacing: 3, color: cyan, fontWeight: FontWeight.w800)),
                Text('Music Player', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              ],
            )),
            IconButton(onPressed: pickTracks, icon: const Icon(Icons.search_rounded)),
            IconButton(onPressed: () => setState(() => tab = 2), icon: const Icon(Icons.tune_rounded, color: cyan)),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF171D46), Color(0xFF160D2A), Color(0xFF071824)]),
              border: Border.all(color: cyan.withValues(alpha: .25)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FEEL EVERY BEAT', style: TextStyle(color: cyan, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text('Your sound. Your rules.', style: TextStyle(fontSize: 24, height: 1.1, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              SizedBox(height: 48, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(25, (i) => Container(width: 4, height: 10 + ((i * 17 + 11) % 38).toDouble(), decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [cyan, violet, pink])))))),
              const SizedBox(height: 8),
              const Row(children: [
                Icon(Icons.equalizer_rounded, color: violet, size: 18), SizedBox(width: 5),
                Text('POWERFUL EQ', style: TextStyle(fontSize: 9, letterSpacing: 1.1)),
                SizedBox(width: 14),
                Icon(Icons.speaker_rounded, color: cyan, size: 18), SizedBox(width: 5),
                Text('SUPER BASS', style: TextStyle(fontSize: 9, letterSpacing: 1.1)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _libraryPill(Icons.music_note_rounded, 'Songs', true, () => setState(() => tab = 3)),
              _libraryPill(Icons.album_rounded, 'Albums', false, () => setState(() => tab = 3)),
              _libraryPill(Icons.person_rounded, 'Artists', false, () => setState(() => tab = 3)),
              _libraryPill(Icons.folder_rounded, 'Folders', false, () => setState(() => tab = 3)),
            ]),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Recently Played', 'SEE ALL'),
          const SizedBox(height: 12),
          SizedBox(
            height: 142,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _albumCard('The Journey', 'Wins', Icons.wb_twilight_rounded, [const Color(0xFFFF8A45), violet]),
              _albumCard('Electric Storm', 'Wins', Icons.bolt_rounded, [const Color(0xFF087CFF), violet]),
              _albumCard('Ujian Hidup', 'Wins', Icons.nightlight_round, [const Color(0xFF126D9B), const Color(0xFF172344)]),
              _albumCard('Ranah Minang', 'Wins', Icons.waves_rounded, [const Color(0xFF13B8A6), const Color(0xFF14335C)]),
            ]),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Playlists', 'SEE ALL'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _playlistCard('Favorites', '42 songs', Icons.favorite_rounded, pink)),
            const SizedBox(width: 10),
            Expanded(child: _playlistCard('Rock', '68 songs', Icons.music_video_rounded, violet)),
            const SizedBox(width: 10),
            Expanded(child: _playlistCard('Electronic', '54 songs', Icons.graphic_eq_rounded, cyan)),
          ]),
          const SizedBox(height: 22),
          const _SectionTitle('Now Playing', 'OPEN PLAYER'),
          const SizedBox(height: 10),
          _nowPlaying(),
          if (audioError != null) ...[
            const SizedBox(height: 10),
            _InfoNote('Playback message', audioError!),
          ],
        ],
      );

  Widget _libraryPill(IconData icon, String label, bool selected, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? violet.withValues(alpha: .2) : panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? violet : Colors.white10),
            ),
            child: Row(children: [
              Icon(icon, size: 17, color: selected ? cyan : Colors.white70),
              const SizedBox(width: 7),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  Widget _albumCard(String title, String artist, IconData icon, List<Color> colors) =>
      Container(
        width: 112,
        margin: const EdgeInsets.only(right: 11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              width: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                border: Border.all(color: Colors.white12),
              ),
              child: Stack(children: [
                Positioned(right: -8, bottom: -12, child: Icon(icon, size: 80, color: Colors.white.withValues(alpha: .16))),
                Center(child: Icon(icon, size: 37, color: Colors.white)),
              ]),
            ),
          ),
          const SizedBox(height: 7),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text(artist, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ]),
      );

  Widget _playlistCard(String title, String count, IconData icon, Color color) =>
      Expanded(
        child: InkWell(
          onTap: () => setState(() => tab = 3),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withValues(alpha: .25)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 10),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Text(count, style: const TextStyle(fontSize: 9, color: Colors.white54)),
            ]),
          ),
        ),
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
              children: List.generate(7, (i) => Expanded(
                child: Column(children: [
                  Text(['+6', '+4', '+2', '0', '+2', '+4', '+6'][i], style: const TextStyle(color: cyan, fontSize: 11)),
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
                  Text(['60', '230', '910', '3.6k', '7k', '14k', '16k'][i],
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
                final values = s == 'Super Bass' ? [0.95, 0.90, 0.68, 0.48, 0.45, 0.48, 0.52] :
                    s == 'Rock' ? [0.88, 0.78, 0.40, 0.68, 0.82, 0.86, 0.88] :
                    s == 'Vocal' ? [0.34, 0.42, 0.72, 0.88, 0.84, 0.68, 0.58] : [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
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
          const _PageHeading('Bass & Effects', 'Powerful low end. Immersive sound.'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102A4A), Color(0xFF20113F), Color(0xFF080D1B)]),
              border: Border.all(color: cyan.withValues(alpha: .25)),
            ),
            child: Column(children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Super Bass', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Deep low-frequency emphasis'),
                value: bassEnabled,
                activeThumbColor: cyan,
                onChanged: (v) => setState(() => bassEnabled = v),
              ),
              const SizedBox(height: 10),
              Container(
                width: 190, height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [cyan.withValues(alpha: .20), violet.withValues(alpha: .08), Colors.transparent]),
                  border: Border.all(color: cyan.withValues(alpha: .55), width: 2),
                  boxShadow: [BoxShadow(color: cyan.withValues(alpha: .12), blurRadius: 30, spreadRadius: 5)],
                ),
                child: Container(
                  margin: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFF31456F), Color(0xFF080B16)]),
                    border: Border.all(color: violet, width: 3),
                  ),
                  child: const Icon(Icons.speaker_rounded, size: 88, color: cyan),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Bass intensity', style: TextStyle(color: Colors.white70)),
                Text('${(bass * 100).round()}%', style: const TextStyle(color: cyan, fontWeight: FontWeight.bold)),
              ]),
              Slider(value: bass, onChanged: bassEnabled ? (v) => setState(() => bass = v) : null),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
            child: Column(children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('3D Surround', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Wider stereo soundstage'),
                value: surroundEnabled,
                activeThumbColor: cyan,
                onChanged: (v) => setState(() => surroundEnabled = v),
              ),
              const Icon(Icons.surround_sound_rounded, size: 72, color: violet),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Width', style: TextStyle(color: Colors.white70)),
                Text('${(surroundWidth * 100).round()}%', style: const TextStyle(color: cyan)),
              ]),
              Slider(value: surroundWidth, onChanged: surroundEnabled ? (v) => setState(() => surroundWidth = v) : null),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Audio Effects', style: TextStyle(fontWeight: FontWeight.bold)),
                value: effectsEnabled,
                activeThumbColor: cyan,
                onChanged: (v) => setState(() => effectsEnabled = v),
              ),
              Row(children: [
                _effectDial('Reverb', 30, violet),
                _effectDial('Chorus', 20, cyan),
                _effectDial('Flanger', 15, pink),
                _effectDial('Delay', 10, violet),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          const _InfoNote('Audio processing status', 'These controls now match the reference design. The local player works, but bass boost, surround, reverb, chorus, flanger and delay remain visual controls until native Android audio effects are connected and tested.'),
        ],
      );

  Widget _effectDial(String label, int amount, Color color) => Expanded(
        child: Column(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: .75), width: 3),
              gradient: const RadialGradient(colors: [Color(0xFF1B2540), Color(0xFF080B16)]),
            ),
            child: Icon(Icons.tune_rounded, color: color, size: 21),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10)),
          Text('$amount%', style: TextStyle(fontSize: 10, color: color)),
        ]),
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
