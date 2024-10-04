import 'dart:io';
import 'dart:async';
import 'dart:math';

void main() async {
  // Menghapus layar di awal
  clearScreen();

  // Mengatur jumlah kembang api yang diminta pengguna
  stdout.write("Masukkan jumlah kembang api: ");
  int jumlahKembangApi = int.parse(stdin.readLineSync()!);

  // Membuat daftar warna untuk kembang api
  List<String> colors = [
    '\x1B[41m', // Merah
    '\x1B[42m', // Hijau
    '\x1B[44m', // Biru
    '\x1B[43m', // Kuning
    '\x1B[45m', // Ungu
    '\x1B[46m', // Cyan
  ];

  // Mengatur lebar terminal
  int lebarTerminal = stdout.terminalColumns;

  // Untuk setiap kembang api
  for (int i = 0; i < jumlahKembangApi; i++) {
    // Memilih warna latar belakang secara acak
    String backgroundColor = colors[Random().nextInt(colors.length)];

    // Mengatur latar belakang sebelum menampilkan kembang api
    fillScreenWithBackground(backgroundColor);

    // Menentukan posisi kembang api
    int posisiTengah;
    if (i == 0) {
      posisiTengah = lebarTerminal ~/ 2; // Kembang api pertama selalu di tengah
    } else {
      posisiTengah = Random().nextInt(lebarTerminal); // Posisi acak untuk kembang api berikutnya
    }

    // Menentukan posisi ledakan acak
    int ledakanPosisi = Random().nextInt(stdout.terminalLines - 5) + 5; // Ketinggian ledakan acak di atas 5

    // Memilih warna untuk ledakan
    String explosionColor = colors[Random().nextInt(colors.length)];

    // Animasi kembang api
    await tampilkanKembangApi(backgroundColor, explosionColor, posisiTengah, ledakanPosisi);
  }

  // Menampilkan pesan "HBD Ano" menggunakan bintang setelah semua kembang api
  await printMessage();

  // Mengatur kembali warna latar belakang
  print('\x1B[0m'); // Reset warna
}

// Fungsi untuk menghapus layar
void clearScreen() {
  stdout.write('\x1B[2J\x1B[H'); // Menghapus terminal dan kembali ke awal
}

// Fungsi untuk mengisi layar dengan latar belakang
void fillScreenWithBackground(String color) {
  final int height = stdout.terminalLines;

  for (int y = 0; y < height; y++) {
    stdout.write('$color${' ' * stdout.terminalColumns}\x1B[0m'); // Mengatur warna latar belakang
  }
}

// Fungsi untuk menampilkan animasi kembang api
Future<void> tampilkanKembangApi(String backgroundColor, String explosionColor, int posisiTengah, int ledakanPosisi) async {
  int tinggiTerminal = stdout.terminalLines; // Tinggi terminal
  int posisiKembangApi = tinggiTerminal; // Posisi awal kembang api

  // Menggerakkan kembang api dari paling bawah ke atas
  while (posisiKembangApi > ledakanPosisi) {
    stdout.write('\x1B[2J\x1B[H'); // Menghapus terminal dan kembali ke awal
    for (int j = 0; j < posisiKembangApi; j++) {
      print(' '); // Spasi untuk posisi kembang api
    }
    // Menampilkan kembang api
    print('${' ' * posisiTengah}$backgroundColor*'); // Menampilkan bintang di posisi tengah
    await Future.delayed(Duration(milliseconds: 200)); // Delay untuk animasi
    posisiKembangApi--; // Mengurangi posisi kembang api
  }

  // Memanggil fungsi explode untuk menampilkan ledakan
  await explode(posisiTengah, ledakanPosisi, backgroundColor); // Menggunakan warna latar belakang saat meledak

  // Menghapus ledakan
  stdout.write('\x1B[2J\x1B[H'); // Menghapus terminal dan kembali ke awal
}

// Fungsi untuk menampilkan pola ledakan
Future<void> explode(int x, int y, String color) async {
  final List<List<int>> explosionPattern = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], [0, 1],
    [1, -1], [1, 0], [1, 1]
  ];

  for (int i = 0; i < 3; i++) {
    for (final offset in explosionPattern) {
      int drawX = x + offset[1] * (i + 1);
      int drawY = y + offset[0] * (i + 1);
      drawFirework(drawX, drawY, '*', color);  // Menggambar kembang api dengan warna latar belakang
    }
    await Future.delayed(Duration(milliseconds: 200));
  }
}

// Fungsi untuk menggambar kembang api
void drawFirework(int x, int y, String symbol, String color) {
  // Mengatur posisi kembang api di terminal
  stdout.write('\x1B[${y + 1};${x + 1}H'); // Mengatur posisi kursor
  print('$color$symbol'); // Mencetak kembang api
}

// Fungsi untuk mencetak pesan "HBD Ano" menggunakan karakter * dengan animasi dari bawah
Future<void> printMessage() async {
  List<String> messageLines = [
    ' h   *   ****   ****      *****   *     *   *****',
    ' *   *   *   *  *   *    *     *  **    *  *     *',
    ' *   *   *   *  *   *    *     *  * *   *  *     *',
    ' *****   ****   *   *    *******  *  *  *  *     *',
    ' *   *   *   *  *   *    *     *  *   * *  *     *',
    ' *   *   *   *  *   *    *     *  *    **  *     *',
    ' *   *   ****   ****     *     *  *     *   *****',
  ];

  int centerX = (stdout.terminalColumns ~/ 2) - (messageLines[0].length ~/ 2); // Mengatur posisi tengah horizontal
  int centerY = (stdout.terminalLines ~/ 2) - (messageLines.length ~/ 2); // Mengatur posisi tengah vertikal

  // Menampilkan pesan "HBD Ano" di tengah
  for (int i = 0; i < messageLines.length; i++) {
    stdout.write('\x1B[${centerY + i};${centerX + 1}H'); // Mengatur posisi kursor untuk pesan
    print(messageLines[i]); // Mencetak setiap baris pesan
    await Future.delayed(Duration(milliseconds: 500)); // Delay antara setiap baris
  }

  // Menunggu sebentar sebelum menghapus pesan
  await Future.delayed(Duration(seconds: 3));
  clearScreen(); // Menghapus layar setelah menampilkan pesan
}


