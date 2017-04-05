
void main() {
  final map = <String, String>{};

  map['1'] = 'a';
  map['2'] = 'b';
  map['1'] = null;

  print(map['1']);
}
