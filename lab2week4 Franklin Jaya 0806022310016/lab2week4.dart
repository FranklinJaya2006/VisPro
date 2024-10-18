class Node<T> { //Node sebagai pembangun Linked List
  T data; //sebagai penyimpan data bertipe T
  Node<T>? next; //untuk berpindah ke Node berikutnya

  Node(this.data);
}

class LinkedList<T> { //kenapa <T> karena ia adalah dapat menerima berbagai tipe data
  Node<T>? head; //Node pertama

  void add(T data) { //function menambah node
    Node<T> newNode = Node(data);
    if (head == null) {
      head = newNode;
    } else {
      Node<T> current = head!;
      while (current.next != null) {
        current = current.next!;
      }
      current.next = newNode;
    }
  }

  void remove(T data) { //function mengahapus node
    if (head == null) return;
    if (head!.data == data) {
      head = head!.next;
      return;
    }
    Node<T>? current = head;
    Node<T>? prev;
    while (current != null && current.data != data) {
      prev = current;
      current = current.next;
    }
    if (current != null) {
      prev!.next = current.next;
    }
  }

  List<T> toList() { //function pencetak
    List<T> result = [];
    Node<T>? current = head;
    while (current != null) {
      result.add(current.data);
      current = current.next;
    }
    return result;
  }
} //itu adalah single linked list

class Vertice { //class yang merepresentasikan kota kota yang dituju
  String city;
  Map<String, int> neighbors; //berfungsi mempetakan
  Vertice(this.city, this.neighbors);
}

int calculateTotalDistance(LinkedList<String> cities, Map<String, Vertice> graph) { //function yang menghitung total jarak untuk rute tertentu. Disinilah dimana akan terjadi perhitungan antar kota
  int totalDistance = 0;
  Node<String>? current = cities.head;
  Node<String>? next = current?.next;
  while (next != null) {
    totalDistance += graph[current!.data]!.neighbors[next.data]!;
    current = next;
    next = next.next;
  }
  return totalDistance;
}

void permute(LinkedList<String> cities, int start, int end, List<LinkedList<String>> result) { //ini adalah dimana seluruh kemungkinan dimasukkan
  if (start == end) {
    LinkedList<String> permutation = LinkedList<String>();
    Node<String>? current = cities.head;
    while (current != null) {
      permutation.add(current.data);
      current = current.next;
    }
    result.add(permutation);
  } else {
    for (int i = start; i <= end; i++) {
      swapNodes(cities, start, i);
      permute(cities, start + 1, end, result);
      swapNodes(cities, start, i);
    }
  }
}

void swapNodes(LinkedList<String> list, int i, int j) { //ini adalah function untuk menukar posisi posisi urutan kota yang dicoba
  if (i == j) return;
  Node<String>? prevI = null, currI = list.head;
  for (int pos = 0; pos < i; pos++) {
    prevI = currI;
    currI = currI!.next;
  }
  Node<String>? prevJ = null, currJ = list.head;
  for (int pos = 0; pos < j; pos++) {
    prevJ = currJ;
    currJ = currJ!.next;
  }
  if (prevI != null) {
    prevI.next = currJ;
  } else {
    list.head = currJ;
  }
  if (prevJ != null) {
    prevJ.next = currI;
  } else {
    list.head = currI;
  }
  Node<String>? temp = currI!.next;
  currI.next = currJ!.next;
  currJ.next = temp;
}

List<LinkedList<String>> tspWithStartAndEnd(Map<String, Vertice> graph, String startCity, String endCity) { //disinilah dimana semua rute yang mungkin, serta menghitung total jarak yang dihasilkan dan menyimpan rute rute terpendek yang ada
  LinkedList<String> cities = LinkedList<String>();
  graph.keys.where((city) => city != startCity && city != endCity).forEach(cities.add);
  
  List<LinkedList<String>> permutations = [];
  permute(cities, 0, cities.toList().length - 1, permutations);

  int minDistance = 1000000;
  List<LinkedList<String>> bestRoutes = [];
  List<Map<String, dynamic>> allRoutes = [];

  for (LinkedList<String> perm in permutations) {
    LinkedList<String> fullRoute = LinkedList<String>();
    fullRoute.add(startCity);
    Node<String>? current = perm.head;
    while (current != null) {
      fullRoute.add(current.data);
      current = current.next;
    }
    fullRoute.add(endCity);

    int currentDistance = calculateTotalDistance(fullRoute, graph);
    allRoutes.add({'route': fullRoute.toList(), 'distance': currentDistance});

    if (currentDistance < minDistance) {
      minDistance = currentDistance;
      bestRoutes = [fullRoute];
    } else if (currentDistance == minDistance) {
      bestRoutes.add(fullRoute);
    }
  }

  print("All possible routes:");
  for (var route in allRoutes) {
    print("Route: ${route['route'].join(' -> ')} | Distance: ${route['distance']}");
  }

  return bestRoutes;
}

void main() {
  Map<String, Vertice> cities = {
    'A': Vertice('A', {'B': 8, 'C': 3, 'D': 4, 'E': 10}),
    'B': Vertice('B', {'A': 8, 'C': 5, 'D': 2, 'E': 7}),
    'C': Vertice('C', {'A': 3, 'B': 5, 'D': 1, 'E': 6}),
    'D': Vertice('D', {'A': 4, 'B': 2, 'C': 1, 'E': 3}),
    'E': Vertice('E', {'A': 10, 'B': 7, 'C': 6, 'D': 3}), //penentukan jarak jarak antar kota
  };

  String startCity = 'A'; //ingin dari kota mana
  String endCity = 'A'; //ingin berakhir dimana

  List<LinkedList<String>> bestRoutes = tspWithStartAndEnd(cities, startCity, endCity);

  print("\nBest routes from $startCity to $endCity:");
  for (var route in bestRoutes) {
    print("${route.toList().join(' -> ')} | Total distance: ${calculateTotalDistance(route, cities)}");
  }
}