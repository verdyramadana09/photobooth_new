import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Pastikan nama package di bawah ini sesuai dengan nama project Anda
// Jika nama project Anda bukan 'photobooth_new', silakan sesuaikan
import 'package:photobooth_new/main.dart'; 

void main() {
  testWidgets('Photobooth start screen smoke test', (WidgetTester tester) async {
    // 1. Build aplikasi Photobooth kita.
    // Kita menggunakan PhotoBoothApp sesuai dengan script main.dart sebelumnya.
    await tester.pumpWidget(const PhotoBoothApp());

    // 2. Verifikasi bahwa halaman awal (StartScreen) muncul.
    // Halaman awal kita memiliki tombol dengan teks "MULAI".
    expect(find.text('MULAI'), findsOneWidget);

    // 3. Pastikan tidak ada teks '0' (bekas template counter) di layar.
    expect(find.text('0'), findsNothing);
    
    // 4. Simulasi menekan tombol MULAI (Opsional)
    await tester.tap(find.text('MULAI'));
    await tester.pumpAndSettle();
  });
}