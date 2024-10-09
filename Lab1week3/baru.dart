import 'dart:async';
import 'dart:io';
import 'dart:math';

// Node untuk Linked List
class Node {
  String data;
  Node? next;
  Node(this.data);
}

// Linked List
class LinkedList {
  Node? head;

  void append(String data) {
    Node newNode = Node(data);
    if (head == null) {
      head = newNode;
    } else {
      Node? current = head;
      while (current?.next != null) {
        current = current?.next;
      }
      current?.next = newNode;
    }
  }

  // Method untuk mendapatkan data dari Linked List
  String getListData() {
    String result = '';
    Node? current = head;
    while (current != null) {
      result += current.data;
      current = current.next;
    }
    return result;
  }
}

// Fungsi untuk menghasilkan warna latar belakang acak
String randomBackgroundColor() {
  List<String> colors = [
    '\x1B[40m', // Hitam
    '\x1B[41m', // Merah
    '\x1B[42m', // Hijau
    '\x1B[43m', // Kuning
    '\x1B[44m', // Biru
    '\x1B[45m', // Magenta
    '\x1B[46m', // Cyan
    '\x1B[47m'  // Putih
  ];
  final rand = Random();
  return colors[rand.nextInt(colors.length)];
}

void main() {
  LinkedList list = LinkedList();
  String name = 'Franklin Jaya';
  for (int i = 0; i < name.length; i++) {
    list.append(name[i]);
  }

  int width = stdout.terminalColumns;
  int position = 0;
  int row = 0;
  String displayLine = '';
  String currentColor = randomBackgroundColor();

  // Fungsi untuk membersihkan terminal
  void clearScreen() {
    if (Platform.isWindows) {
      stdout.write(Process.runSync('cls', [], runInShell: true).stdout);
    } else {
      stdout.write(Process.runSync('clear', [], runInShell: true).stdout);
    }
  }

  // Fungsi untuk menampilkan nama dengan jejak
  void displayName() {
    clearScreen();
    
    if (row % 2 == 0) {
      // Baris genap: dari kiri ke kanan
      displayLine += name;
      stdout.writeln('$currentColor${displayLine.padRight(width)}\x1B[0m');
    } else {
      // Baris ganjil: dari kanan ke kiri
      displayLine = name + displayLine;
      stdout.writeln('$currentColor${displayLine.padLeft(width)}\x1B[0m');
    }

    position += name.length;

    // Periksa apakah posisi telah melebihi lebar terminal
    if (position > width) {
      row++;
      displayLine = '';
      position = 0;
      currentColor = randomBackgroundColor(); // Ganti warna untuk baris baru
    }

    // Atur batasan untuk row
    if (row >= 2) {
      row = 0;
      displayLine = '';
      position = 0;
      currentColor = randomBackgroundColor(); // Ganti warna setiap 2 baris
    }

    // Cetak nilai row untuk debug
    print('Row: $row');
  }

  // Timer untuk menjalankan animasi secara berulang
  Timer.periodic(Duration(milliseconds: 150), (timer) {
    displayName();
  });
}
