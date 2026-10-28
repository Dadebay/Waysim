import 'package:markdown/markdown.dart' as md;

class MobileLegalTableSyntax extends md.TableSyntax {
  const MobileLegalTableSyntax();

  @override
  md.Node? parse(md.BlockParser parser) {
    final table = super.parse(parser);
    if (table is! md.Element) return table;
    final sections = table.children!.cast<md.Element>();
    final headers = (sections.first.children!.single as md.Element).children!
        .cast<md.Element>();
    final rows = sections.length > 1
        ? sections[1].children!.cast<md.Element>()
        : <md.Element>[];

    if (rows.isEmpty) {
      return md.Element('blockquote', [
        for (final header in headers)
          md.Element('p', [
            md.Element('strong', [...?header.children]),
          ]),
      ]);
    }

    return md.Element('section', [
      for (final row in rows)
        md.Element('blockquote', [
          for (var i = 0; i < headers.length; i++)
            md.Element('p', [
              if (headers[i].textContent.trim().isNotEmpty) ...[
                md.Element('strong', [...?headers[i].children]),
                md.Element.empty('br'),
              ],
              ...?(row.children![i] as md.Element).children,
            ]),
        ]),
    ]);
  }
}
