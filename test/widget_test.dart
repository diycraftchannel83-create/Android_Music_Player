import 'package:flutter_test/flutter_test.dart';
import 'package:android_music_player/main.dart';

void main() {
  testWidgets('Android Music Player renders the home screen', (tester) async {
    await tester.pumpWidget(const AndroidMusicPlayerApp());
    expect(find.text('Android'), findsNothing);
    expect(find.text('Music Player'), findsOneWidget);
    expect(find.text('FEEL EVERY BEAT'), findsOneWidget);
    expect(find.text('Super Bass'), findsWidgets);
  });
}
