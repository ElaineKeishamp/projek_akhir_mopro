// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pastikan jalur ini benar
import 'package:projek_mopro/main.dart'; 

void main() {
  testWidgets('Campus Store loads and displays key text', (WidgetTester tester) async {
    // Membangun widget utama aplikasi kita, yaitu CampusStoreApp
    await tester.pumpWidget(const CampusStoreApp()); // <-- DIGANTI DARI MyApp()

    // Verifikasi bahwa teks merek (Brand) aplikasi terlihat di layar
    expect(find.text('CampusStore'), findsOneWidget);

    // Verifikasi bahwa bagian pencarian (Search) terlihat
    expect(find.byType(TextField), findsOneWidget);
    
    // Verifikasi bahwa setidaknya satu elemen navigasi terlihat (misalnya Beranda)
    expect(find.text('Beranda'), findsOneWidget);

    // Verifikasi bahwa teks diskon terlihat
    expect(find.text('Diskon Mahasiswa!'), findsOneWidget);

    // Anda bisa menambahkan test lain di sini, misalnya untuk memastikan produk pertama tampil
    // Contoh: expect(find.text('MacBook Air M2 - Grey'), findsOneWidget);
  });
}