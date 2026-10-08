// Prints how many roadmap tasks are done, partly done and left.
//
//   dart run tool/roadmap_status.dart
//
// Reads the checkboxes in docs/06-roadmap.md: `[x]` done, `[~]` partly done
// or waiting on someone else, `[ ]` to do. Keep the roadmap honest and this
// stays honest.
import 'dart:io';

void main() {
  final lines = File('docs/06-roadmap.md').readAsLinesSync();
  final task = RegExp(r'^- \[( |x|~)\] \*\*(T\d+\.\d+)\*\*');
  final phase = RegExp(r'^## (Faz \d+)');

  var current = '';
  final perPhase = <String, List<int>>{};
  for (final line in lines) {
    final p = phase.firstMatch(line);
    if (p != null) current = p.group(1)!;
    final m = task.firstMatch(line);
    if (m == null) continue;
    final counts = perPhase.putIfAbsent(current, () => [0, 0, 0]);
    counts[switch (m.group(1)) {
      'x' => 0,
      '~' => 1,
      _ => 2,
    }]++;
  }

  var done = 0, partly = 0, todo = 0;
  stdout.writeln('Phase      done  partly  todo');
  perPhase.forEach((name, c) {
    stdout.writeln(
      '${name.padRight(9)} ${c[0].toString().padLeft(5)} '
      '${c[1].toString().padLeft(7)} ${c[2].toString().padLeft(5)}',
    );
    done += c[0];
    partly += c[1];
    todo += c[2];
  });

  final total = done + partly + todo;
  final pct = total == 0 ? 0 : (done * 100 / total).round();
  stdout
    ..writeln('')
    ..writeln(
      'Total $total  ·  done $done ($pct%)  ·  partly $partly  ·  left $todo',
    );
}
