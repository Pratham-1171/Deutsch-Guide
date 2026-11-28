import 'package:material_ui/material_ui.dart';

import '../domain/german_nlp_engine.dart';

class GermanGrammarScreen extends StatefulWidget {
  const GermanGrammarScreen({super.key});

  @override
  State<GermanGrammarScreen> createState() => _GermanGrammarScreenState();
}

class _GermanGrammarScreenState extends State<GermanGrammarScreen> {
  final _controller = TextEditingController(text: 'ich morgen gehe zur schule.');
  final _engine = const GermanNlpEngine();
  GermanAnalysis? _analysis;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    FocusScope.of(context).unfocus();
    setState(() => _analysis = _engine.analyze(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = _analysis;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline German checker'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Chip(label: Text('On device'))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Check a German sentence', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Your text is analysed locally. No sentence is sent to a server.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Schreibe einen Satz auf Deutsch …',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _analyze,
            icon: const Icon(Icons.manage_search),
            label: const Text('Analyse sentence'),
          ),
          if (analysis != null) ...[
            const SizedBox(height: 24),
            Text('Analysis', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${analysis.tokens.length} tokens · ${analysis.findings.length} suggestions'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final token in analysis.tokens)
                  Chip(
                    label: Text(token.text),
                    avatar: CircleAvatar(
                      child: Text(token.partOfSpeech.name.substring(0, 1).toUpperCase()),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Grammar feedback', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (analysis.findings.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('No issues found by the available rules.'),
                  subtitle: Text('This is not a guarantee that the sentence is fully correct.'),
                ),
              )
            else
              for (final finding in analysis.findings)
                Card(
                  child: ListTile(
                    leading: Icon(
                      finding.severity == GrammarSeverity.error
                          ? Icons.error_outline
                          : Icons.info_outline,
                      color: finding.severity == GrammarSeverity.error
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    title: Text(finding.message),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${finding.explanation}${finding.suggestion == null ? '' : '\nSuggestion: ${finding.suggestion}'}',
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            Text(
              'Engine: ${analysis.engineVersion}. This first offline release uses reviewed lexical rules; statistical model inference and broad grammar coverage are future stages.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
