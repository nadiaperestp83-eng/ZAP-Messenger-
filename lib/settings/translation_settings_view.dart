//
//  translation_settings_view.dart
//
//  翻译 settings: target language and no-translate language preferences.
//

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/sf_symbols.dart';
import '../components/ui_components.dart';
import '../theme/app_theme.dart';
import 'translation_controller.dart';

class TranslationSettingsView extends StatelessWidget {
  const TranslationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final translation = context.watch<TranslationController>();
    return Scaffold(
      backgroundColor: c.groupedBackground,
      body: Column(
        children: [
          NavHeader(title: '翻译', onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              children: [
                _card(context, [
                  _switchRow(
                    context,
                    icon: 'character.book.closed',
                    title: '消息翻译',
                    value: translation.enabled,
                    onChanged: (v) => translation.enabled = v,
                  ),
                  const InsetDivider(leadingInset: 56),
                  _switchRow(
                    context,
                    icon: 'wand.and.stars',
                    title: '自动翻译',
                    value: translation.autoTranslate,
                    onChanged: (v) {
                      if (v) translation.enabled = true;
                      translation.autoTranslate = v;
                    },
                  ),
                ]),
                const SizedBox(height: 14),
                _card(context, [
                  _navRow(
                    context,
                    icon: 'network',
                    title: '翻译服务',
                    trailing: translation.providerLabel,
                    onTap: null,
                  ),
                ]),
                const SizedBox(height: 14),
                _card(context, [
                  _navRow(
                    context,
                    icon: 'globe',
                    title: '目标语言',
                    trailing: translation.targetLanguageLabel,
                    onTap: () => _showTargetPicker(context),
                  ),
                  const InsetDivider(leadingInset: 56),
                  _navRow(
                    context,
                    icon: 'nosign',
                    title: '不翻译语言',
                    trailing: translation.noTranslateSummary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NoTranslateLanguagesView(),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final c = context.colors;
        final translation = context.watch<TranslationController>();
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: TranslationController.targetLanguages.length,
              separatorBuilder: (_, _) => const InsetDivider(leadingInset: 56),
              itemBuilder: (context, i) {
                final language = TranslationController.targetLanguages[i];
                final selected =
                    translation.targetLanguageCode == language.code;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    translation.targetLanguageCode = language.code;
                    Navigator.of(context).pop();
                  },
                  child: SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _iconBadge(context, 'globe', const Color(0xFF34A2DF)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              language.label,
                              style: TextStyle(
                                fontSize: 16,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(sfIcon('checkmark'), size: 18, color: AppTheme.brand),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );

  Widget _switchRow(
    BuildContext context, {
    required String icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final c = context.colors;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _iconBadge(context, icon, const Color(0xFF34A2DF)),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 16, color: c.textPrimary)),
            const Spacer(),
            CupertinoSwitch(
              value: value,
              activeTrackColor: AppTheme.brand,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navRow(
    BuildContext context, {
    required String icon,
    required String title,
    required String trailing,
    required VoidCallback? onTap,
  }) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _iconBadge(context, icon, const Color(0xFF34A2DF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: c.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: math.min(MediaQuery.sizeOf(context).width * 0.42, 190),
                child: Text(
                  trailing,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: c.textTertiary),
                ),
              ),
              const SizedBox(width: 6),
              if (onTap != null)
                SizedBox(
                  width: 14,
                  child: Icon(
                    sfIcon('chevron.right'),
                    size: 14,
                    color: c.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBadge(BuildContext context, String icon, Color color) =>
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(sfIcon(icon), size: 15, color: Colors.white),
      );
}

class NoTranslateLanguagesView extends StatelessWidget {
  const NoTranslateLanguagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final translation = context.watch<TranslationController>();
    return Scaffold(
      backgroundColor: c.groupedBackground,
      body: Column(
        children: [
          NavHeader(title: '不翻译语言', onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < TranslationController.noTranslateLanguages.length;
                        i++
                      ) ...[
                        _languageRow(
                          context,
                          translation,
                          TranslationController.noTranslateLanguages[i],
                        ),
                        if (i <
                            TranslationController.noTranslateLanguages.length -
                                1)
                          const InsetDivider(leadingInset: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageRow(
    BuildContext context,
    TranslationController translation,
    TranslationLanguage language,
  ) {
    final c = context.colors;
    final selected = translation.noTranslateLanguageCodes.contains(
      language.code,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => translation.setNoTranslateLanguage(language.code, !selected),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  language.label,
                  style: TextStyle(fontSize: 16, color: c.textPrimary),
                ),
              ),
              if (selected) Icon(sfIcon('checkmark'), size: 18, color: AppTheme.brand),
            ],
          ),
        ),
      ),
    );
  }
}
