import 'package:flutter/material.dart';

import 'contact.dart';
import 'external_link.dart';
import 'visuals.dart';

const ink = Color(0xFFE4EAE8);
const navy = Color(0xFF081216);
const mint = Color(0xFF8BC8BA);
const muted = Color(0xFFA5B7B7);
const paper = Color(0xFFE4EAE8);
const line = Color(0xFF2A3C41);
const chapterNames = [
  'Who We Are',
  'What We Do',
  'What We’ve Done',
  'Why We Do It',
];

class YroSite extends StatefulWidget {
  const YroSite({super.key});
  @override
  State<YroSite> createState() => _YroSiteState();
}

class _YroSiteState extends State<YroSite> {
  final _scroll = ScrollController();
  final _pageProgress = ValueNotifier<double>(0);
  final _chapterKeys = {for (final name in chapterNames) name: GlobalKey()};
  String? _activeChapter;
  bool _scrollUpdatePending = false;
  final _sections = {
    for (final name in [
      'About',
      'How we work',
      'Capabilities',
      'Cyber',
      'R&D',
      'AI',
      'Apps',
      'Media',
      'Mind Country',
    ])
      name: GlobalKey(),
  };
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scheduleScrollUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleScrollUpdate();
  }

  void _scheduleScrollUpdate() {
    if (_scrollUpdatePending) return;
    _scrollUpdatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollUpdatePending = false;
      if (!mounted || !_scroll.hasClients) return;
      final extent = _scroll.position.maxScrollExtent;
      _pageProgress.value = extent > 0
          ? (_scroll.offset / extent).clamp(0.0, 1.0)
          : 0;
      String? current;
      final threshold = MediaQuery.sizeOf(context).height * 0.35;
      for (final entry in _chapterKeys.entries) {
        final box = entry.value.currentContext?.findRenderObject();
        if (box is RenderBox &&
            box.hasSize &&
            box.localToGlobal(Offset.zero).dy <= threshold) {
          current = entry.key;
        }
      }
      if (current != _activeChapter) setState(() => _activeChapter = current);
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_scheduleScrollUpdate);
    _scroll.dispose();
    _pageProgress.dispose();
    super.dispose();
  }

  void _goTo(String name) {
    setState(() => _menuOpen = false);
    // Measure after the compact navigation closes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = (_chapterKeys[name] ?? _sections[name])?.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: 0.04,
      );
    });
  }

  void _goHome() {
    setState(() => _menuOpen = false);
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
      return;
    }
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          _header(),
          ExcludeSemantics(
            child: ValueListenableBuilder<double>(
              valueListenable: _pageProgress,
              builder: (context, progress, child) => LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: line.withValues(alpha: 0.45),
                color: mint,
              ),
            ),
          ),
          Expanded(
            child: SelectionArea(
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  children: [
                    _Hero(onExplore: () => _goTo('What We Do')),
                    _chapter(
                      index: 0,
                      description: 'EXPERIENCE & APPROACH',
                      color: const Color(0xFF0A1519),
                      children: [_about(), _howWeWork()],
                    ),
                    _chapter(
                      index: 1,
                      description: 'CAPABILITIES & CREATIVE WORK',
                      color: const Color(0xFF12232D),
                      children: [_capabilities(), _media()],
                    ),
                    _chapter(
                      index: 2,
                      description: 'APPS & RECOGNITION',
                      color: const Color(0xFF070C11),
                      children: [_apps(), _recognition()],
                    ),
                    _chapter(
                      index: 3,
                      description: 'APPALACHIAN ROOTS',
                      color: const Color(0xFF16271F),
                      children: [_mindCountry()],
                    ),
                    _footer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _chapter({
    required int index,
    required String description,
    required Color color,
    required List<Widget> children,
  }) => Container(
    key: _chapterKeys[chapterNames[index]],
    decoration: BoxDecoration(
      color: color,
      border: Border(top: BorderSide(color: line.withValues(alpha: 0.8))),
    ),
    padding: const EdgeInsets.only(bottom: 64),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChapterIntro(
          number: '0${index + 1}',
          title: chapterNames[index],
          description: description,
          scroll: _scroll,
        ),
        ...children,
      ],
    ),
  );

  Widget _chapterLink(String name) {
    final selected = name == _activeChapter;
    return Semantics(
      selected: selected,
      child: TextButton(
        onPressed: () => _goTo(name),
        style: TextButton.styleFrom(
          foregroundColor: selected ? mint : muted,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              height: 1,
              width: selected ? 26 : 0,
              color: mint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => ColoredBox(
    color: navy,
    child: Frame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          return Column(
            children: [
              SizedBox(
                height: 88,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _goHome,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Wordmark(),
                    ),
                    const Spacer(),
                    if (!compact) ...[
                      for (final name in chapterNames) _chapterLink(name),
                      const SizedBox(width: 28),
                      const EmailContact(label: 'Contact', outlined: true),
                    ] else
                      IconButton(
                        tooltip: _menuOpen ? 'Close menu' : 'Open menu',
                        onPressed: () => setState(() => _menuOpen = !_menuOpen),
                        color: mint,
                        icon: Icon(_menuOpen ? Icons.close : Icons.menu),
                      ),
                  ],
                ),
              ),
              if (compact && _menuOpen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      for (final name in chapterNames) _chapterLink(name),
                      const EmailContact(label: 'Contact'),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );

  Widget _about() => Frame(
    key: _sections['About'],
    vertical: 82,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('ABOUT YRO'),
            const SizedBox(height: 22),
            sectionHeading('Experience in\ndemanding environments.'),
          ],
        );
        const description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experience in government and cleared environments, from operational work to technical leadership.',
              style: TextStyle(fontSize: 23, height: 1.5, color: ink),
            ),
            SizedBox(height: 18),
            Text(
              'Our background spans incident response, security engineering, software architecture, '
              'and research. We understand the constraints of sensitive environments and the need '
              'for dependable systems, clear communication, and accountable delivery.',
              style: TextStyle(fontSize: 16, height: 1.85, color: muted),
            ),
          ],
        );
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 32), description],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 90),
            const Expanded(child: description),
          ],
        );
      },
    ),
  );

  Widget _recognition() => Container(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: line)),
    ),
    child: Frame(
      vertical: 64,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final introduction = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('RECOGNITION'),
              const SizedBox(height: 22),
              sectionHeading('Cybersecurity program\nparticipation.'),
              const SizedBox(height: 20),
              const Text(
                'Yro’s founder has been accepted into both programs as an individual '
                'cybersecurity practitioner.',
                style: TextStyle(color: muted, fontSize: 16, height: 1.85),
              ),
            ],
          );
          const programs = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ApproachStep(
                title: 'Anthropic',
                description: 'Cyber Verification Program (CVP)',
              ),
              ApproachStep(title: 'OpenAI', description: 'Daybreak'),
            ],
          );
          if (constraints.maxWidth < 800) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [introduction, const SizedBox(height: 36), programs],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: introduction),
              const SizedBox(width: 88),
              const Expanded(flex: 6, child: programs),
            ],
          );
        },
      ),
    ),
  );

  Widget _howWeWork() => Container(
    key: _sections['How we work'],
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: line)),
    ),
    child: Frame(
      vertical: 76,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final introduction = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('OUR APPROACH'),
              const SizedBox(height: 22),
              sectionHeading('Working with Yro'),
              const SizedBox(height: 24),
              const Text(
                'You do not need a technical specification to start.',
                style: TextStyle(color: ink, fontSize: 23, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tell us what needs to change. We work with your leadership and technical teams '
                'to turn that into clear requirements, and explain technical choices in terms each group can use.',
                style: TextStyle(color: muted, fontSize: 16, height: 1.85),
              ),
              const SizedBox(height: 20),
              const Text(
                'You work directly with the people designing and building your solution, without a sales handoff.',
                style: TextStyle(color: muted, fontSize: 16, height: 1.85),
              ),
              const SizedBox(height: 26),
              const EmailContact(),
            ],
          );
          const steps = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ApproachStep(
                title: 'Start with a working example',
                description:
                    'We demonstrate both the workflow and its technical feasibility before proposing '
                    'the full work. You can try the approach and tell us what we understood correctly '
                    'and where our assumptions missed the mark.',
              ),
              ApproachStep(
                title: 'Keep the feedback cycle short',
                description:
                    'We ask for feedback early and often, compare it with what was discussed, '
                    'and revise quickly. Each iteration brings the requirements and the prototype '
                    'closer to what you need.',
              ),
              ApproachStep(
                title: 'Build only what the problem needs',
                description:
                    'We choose technology around your requirements, budget, and existing systems. '
                    'We reuse what fits and build what is missing, with local deployment available '
                    'when you need control over your systems and data.',
              ),
            ],
          );
          if (constraints.maxWidth < 800) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [introduction, const SizedBox(height: 42), steps],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: introduction),
              const SizedBox(width: 88),
              const Expanded(flex: 6, child: steps),
            ],
          );
        },
      ),
    ),
  );

  Widget _capabilities() => Container(
    key: _sections['Capabilities'],
    child: Frame(
      vertical: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('OUR CAPABILITIES'),
          const SizedBox(height: 22),
          sectionHeading('Cyber, R&D, and AI.'),
          const SizedBox(height: 18),
          const Text(
            'Research and engineering across security, software, and AI.',
            style: TextStyle(color: muted, fontSize: 17, height: 1.6),
          ),
          const SizedBox(height: 44),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                CapabilityCard(
                  key: _sections['Cyber'],
                  number: '01',
                  name: 'Cyber',
                  subtitle: 'Security operations and assurance',
                  description: 'We assess systems, investigate weaknesses, and improve security operations. Our work includes secure architecture, cryptographic assessment, and automation for security teams.',
                  topics: const [
                    'Security operations & automation',
                    'Software & cryptographic assurance',
                    'Vulnerability assessment & research',
                  ],
                  accent: const Color(0xFF8BC8BA),
                ),
                CapabilityCard(
                  key: _sections['R&D'],
                  number: '02',
                  name: 'R&D',
                  subtitle: 'Research and software development',
                  description: 'We investigate technical problems, build prototypes, and develop custom software. We help organizations evaluate new technology and decide where further investment makes sense.',
                  topics: const [
                    'Applied research & prototyping',
                    'Custom software & systems',
                    'Technical strategy & evaluation',
                  ],
                  accent: const Color(0xFF88A9BA),
                ),
                CapabilityCard(
                  key: _sections['AI'],
                  number: '03',
                  name: 'AI',
                  subtitle: 'Applied AI and automation',
                  description: 'We develop AI applications for working with information, automating tasks, and analyzing data. The work accounts for security requirements, existing systems, and how people will use it.',
                  topics: const [
                    'Knowledge & workflow automation',
                    'Predictive analytics & decision support',
                    'Secure AI integration',
                  ],
                  accent: const Color(0xFFB8B79A),
                ),
              ];
              if (constraints.maxWidth < 880) {
                return Column(
                  children: [
                    for (final card in cards)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: card,
                      ),
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 20),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 20),
                    Expanded(child: cards[2]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );

  Widget _apps() => Container(
    key: _sections['Apps'],
    child: Frame(
      vertical: 76,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('APPS BY YRO'),
              const SizedBox(height: 22),
              sectionHeading('Apps we’ve made.'),
              const SizedBox(height: 30),
              Semantics(
                headingLevel: 4,
                child: const Text(
                  'Tunings',
                  style: TextStyle(color: ink, fontSize: 25, height: 1.4),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'A music workbench for exploring chords, alternate tunings, and ideas '
                'on the fretboard. Built for musicians, learners, and teachers.',
                style: TextStyle(color: muted, fontSize: 16, height: 1.85),
              ),
              const SizedBox(height: 20),
              const ExternalLink(
                url: 'https://tunings.io/',
                label: 'Open tunings.io in a new tab',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Open tunings.io', style: TextStyle(color: mint)),
                      SizedBox(width: 12),
                      Icon(Icons.north_east, color: mint, size: 17),
                    ],
                  ),
                ),
              ),
            ],
          );
          final preview = ExternalLink(
            url: 'https://tunings.io/',
            label: 'Tunings website preview. Open tunings.io in a new tab',
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF101E23),
                border: Border.all(color: line),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.language, color: mint, size: 16),
                        SizedBox(width: 10),
                        Text(
                          'tunings.io',
                          style: TextStyle(color: ink, fontSize: 12),
                        ),
                        Spacer(),
                        Text(
                          'Website preview',
                          style: TextStyle(color: muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/previews/tunings.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          );
          if (constraints.maxWidth < 800) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 30), preview],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 4, child: copy),
              const SizedBox(width: 64),
              Expanded(flex: 7, child: preview),
            ],
          );
        },
      ),
    ),
  );

  Widget _media() => Frame(
    key: _sections['Media'],
    vertical: 84,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final illustration = Container(
          height: compact ? 260 : 350,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF112526),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ExcludeSemantics(
                child: CustomPaint(painter: MediaPainter()),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('YRO / MEDIA'),
                    const Spacer(),
                    Text(
                      'Audio /\nVisual',
                      style: TextStyle(
                        color: ink,
                        fontSize: compact ? 42 : 54,
                        height: 1.05,
                        letterSpacing: -2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('MEDIA'),
            const SizedBox(height: 20),
            sectionHeading('Audio, video\nand creative work.'),
            const SizedBox(height: 20),
            const Text(
              'We also work in media. Our experience includes over 15 years of audio engineering, '
              'along with sound design, video editing, 3D modeling, and production '
              'for marketing and commercial projects.',
              style: TextStyle(color: muted, fontSize: 16, height: 1.85),
            ),
            const SizedBox(height: 26),
            const Wrap(
              spacing: 22,
              runSpacing: 12,
              children: [
                Text(
                  'AUDIO',
                  style: TextStyle(
                    color: mint,
                    fontSize: 10,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  'VIDEO',
                  style: TextStyle(
                    color: mint,
                    fontSize: 10,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  '3D',
                  style: TextStyle(
                    color: mint,
                    fontSize: 10,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  'COMMERCIAL',
                  style: TextStyle(
                    color: mint,
                    fontSize: 10,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ],
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [illustration, const SizedBox(height: 38), copy],
          );
        }
        return Row(
          children: [
            Expanded(child: illustration),
            const SizedBox(width: 76),
            Expanded(child: copy),
          ],
        );
      },
    ),
  );

  Widget _mindCountry() => Container(
    key: _sections['Mind Country'],
    child: Frame(
      vertical: 76,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('COMMUNITY & VOLUNTEERING'),
              const SizedBox(height: 22),
              sectionHeading('Mind Country'),
              const SizedBox(height: 24),
              const Text(
                'Appalachia is home.',
                style: TextStyle(color: ink, fontSize: 23, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'As a small business with Appalachian roots, we want to put our time and skills '
                'to use in the communities that shaped us.',
                style: TextStyle(color: muted, fontSize: 16, height: 1.85),
              ),
              const SizedBox(height: 16),
              const Text(
                'We are always open to conversations about volunteering, speaking engagements, '
                'technical education, and community projects. If your school, group, or organization '
                'could use technical or creative support, we would like to hear from you.',
                style: TextStyle(color: muted, fontSize: 16, height: 1.85),
              ),
              const SizedBox(height: 26),
              const EmailContact(),
            ],
          );
          const landscape = ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: 1.5,
              child: CustomPaint(painter: AppalachiaPainter()),
            ),
          );
          if (constraints.maxWidth < 800) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 30), landscape],
            );
          }
          return Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 74),
              const Expanded(flex: 5, child: landscape),
            ],
          );
        },
      ),
    ),
  );

  Widget _footer() => ColoredBox(
    color: navy,
    child: Frame(
      vertical: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 80,
            runSpacing: 30,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Wordmark(),
              const Text(
                'Cybersecurity, software, and creative work.',
                style: TextStyle(color: Color(0xFFD0DEDC), fontSize: 18),
              ),
              const EmailContact(),
              TextButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.north, size: 17),
                label: const Text('Back to top'),
                style: TextButton.styleFrom(foregroundColor: mint),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Divider(color: Color(0xFF2B3B40), height: 1),
          ),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              Text(
                '© ${DateTime.now().year} Yro LLC. All rights reserved.',
                style: const TextStyle(color: Color(0xFF99AEAE), fontSize: 12),
              ),
              const Text(
                'CYBER  /  R&D  /  AI  /  MEDIA',
                style: TextStyle(
                  color: Color(0xFF99AEAE),
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ChapterIntro extends StatefulWidget {
  const ChapterIntro({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.scroll,
  });

  final String number;
  final String title;
  final String description;
  final ScrollController scroll;

  @override
  State<ChapterIntro> createState() => _ChapterIntroState();
}

class _ChapterIntroState extends State<ChapterIntro> {
  final _positionKey = GlobalKey();
  bool _shown = false;
  bool _checkPending = false;

  @override
  void initState() {
    super.initState();
    widget.scroll.addListener(_checkVisibility);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkVisibility();
  }

  void _checkVisibility() {
    if (_shown || _checkPending) return;
    _checkPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPending = false;
      if (!mounted) return;
      final box = _positionKey.currentContext?.findRenderObject();
      if (box is RenderBox &&
          box.hasSize &&
          box.localToGlobal(Offset.zero).dy <
              MediaQuery.sizeOf(context).height * 0.9) {
        setState(() => _shown = true);
      }
    });
  }

  @override
  void dispose() {
    widget.scroll.removeListener(_checkVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final visible = _shown || reducedMotion;
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 650);
    return Frame(
      key: _positionKey,
      vertical: compact ? 52 : 92,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.12),
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0.35,
          duration: duration,
          alwaysIncludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.number,
                    style: const TextStyle(
                      color: mint,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    width: 38,
                    height: 1,
                    color: mint.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 18),
                  Expanded(child: Eyebrow(widget.description)),
                ],
              ),
              const SizedBox(height: 28),
              Semantics(
                headingLevel: 2,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: ink,
                    fontSize: compact ? 46 : 82,
                    height: 1.08,
                    letterSpacing: compact ? -1.7 : -3.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 42),
              Divider(color: mint.withValues(alpha: 0.2), height: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: navy,
      border: Border(top: BorderSide(color: Color(0xFF223439))),
    ),
    child: Frame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 800;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('SOFTWARE / SECURITY / AI / MEDIA', light: true),
              const SizedBox(height: 30),
              Semantics(
                headingLevel: 1,
                child: Text(
                  'Software, security,\nand creative work.',
                  style: TextStyle(
                    color: paper,
                    fontSize: compact ? 42 : 62,
                    height: 1.08,
                    letterSpacing: -1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: const Text(
                  'We develop software, strengthen security, and produce digital media. '
                  'Our work combines engineering, applied AI, and creative production '
                  'to help people and organizations solve problems and develop ideas.',
                  style: TextStyle(
                    color: Color(0xFFADBFBE),
                    fontSize: 17,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              SiteButton(label: 'View capabilities', onPressed: onExplore),
            ],
          );
          const art = ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: 1.1,
              child: CustomPaint(painter: CircuitPainter()),
            ),
          );
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: compact ? 48 : 66,
                  bottom: compact ? 58 : 110,
                ),
                child: compact
                    ? Column(children: [copy, const SizedBox(height: 22), art])
                    : Row(
                        children: [
                          Expanded(flex: 6, child: copy),
                          const SizedBox(width: 15),
                          Expanded(flex: 5, child: art),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class CapabilityCard extends StatelessWidget {
  const CapabilityCard({
    super.key,
    required this.number,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.topics,
    required this.accent,
  });
  final String number, name, subtitle, description;
  final List<String> topics;
  final Color accent;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Container(
      padding: const EdgeInsets.fromLTRB(0, 24, 20, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.55))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(color: accent, fontSize: 11, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Semantics(
            headingLevel: 4,
            child: Text(
              name,
              style: const TextStyle(
                color: ink,
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(color: muted, fontSize: 15, height: 1.85),
          ),
          const SizedBox(height: 28),
          const Divider(color: line, height: 1),
          const SizedBox(height: 22),
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.add, color: accent, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class Frame extends StatelessWidget {
  const Frame({super.key, required this.child, this.vertical = 0});
  final Widget child;
  final double vertical;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1320),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 700 ? 24 : 56,
          vertical: vertical,
        ),
        child: child,
      ),
    ),
  );
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Yro LLC',
    excludeSemantics: true,
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Yro',
          style: TextStyle(
            color: mint,
            fontWeight: FontWeight.w600,
            fontSize: 40,
            letterSpacing: -2.5,
            height: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            'LLC',
            style: TextStyle(
              color: Color(0xFFA7BFBE),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.light = false});
  final String text;
  final bool light;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: light ? mint : const Color(0xFF9DAF9B),
      fontSize: 10,
      height: 1.6,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
    ),
  );
}

Widget sectionHeading(String text) => Semantics(
  headingLevel: 3,
  child: Text(
    text,
    style: const TextStyle(
      color: ink,
      fontSize: 37,
      height: 1.18,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.3,
    ),
  ),
);

class SiteButton extends StatelessWidget {
  const SiteButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor: outlined ? Colors.transparent : mint,
      foregroundColor: outlined ? mint : navy,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      side: outlined ? const BorderSide(color: Color(0xFF466762)) : null,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(label)),
        const SizedBox(width: 20),
        const Icon(Icons.arrow_outward, size: 17),
      ],
    ),
  );
}

class ApproachStep extends StatelessWidget {
  const ApproachStep({
    super.key,
    required this.title,
    required this.description,
  });
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            headingLevel: 4,
            child: Text(
              title,
              style: const TextStyle(color: ink, fontSize: 20, height: 1.35),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: muted, fontSize: 15, height: 1.8),
          ),
        ],
      ),
    ),
  );
}

class EmailContact extends StatelessWidget {
  const EmailContact({
    super.key,
    this.label = businessEmail,
    this.outlined = false,
  });
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    Future<void> open() async {
      final opened = await openBusinessEmail();
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email address copied: business@yro.dev'),
          ),
        );
      }
    }

    return Semantics(
      link: true,
      linkUrl: Uri(scheme: 'mailto', path: businessEmail),
      label: 'Email $businessEmail',
      onTap: open,
      child: ExcludeSemantics(
        child: TextButton.icon(
          onPressed: open,
          icon: const Icon(Icons.north_east, size: 16),
          iconAlignment: IconAlignment.end,
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: mint,
            padding: EdgeInsets.symmetric(
              horizontal: outlined ? 20 : 0,
              vertical: 16,
            ),
            side: outlined ? const BorderSide(color: line) : null,
          ),
        ),
      ),
    );
  }
}
