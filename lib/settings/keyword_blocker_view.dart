//
//  keyword_blocker_view.dart
//
//  关键词屏蔽 settings: user-managed local keyword list.
//

import 'package:flutter/material.dart';

import '../components/sf_symbols.dart';
import '../components/ui_components.dart';
import '../theme/app_theme.dart';
import 'keyword_blocker.dart';

class KeywordBlockerView extends StatefulWidget {
  const KeywordBlockerView({super.key});

  @override
  State<KeywordBlockerView> createState() => _KeywordBlockerViewState();
}

class _KeywordBlockerViewState extends State<KeywordBlockerView> {
  final _controller = TextEditingController();
  final _blocker = KeywordBlocker.shared;

  @override
  void initState() {
    super.initState();
    _blocker.addListener(_onChanged);
  }

  @override
  void dispose() {
    _blocker.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _add() {
    final text = _controller.text;
    _blocker.add(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final keywords = _blocker.keywords;
    return Scaffold(
      backgroundColor: c.groupedBackground,
      body: Column(
        children: [
          NavHeader(title: '关键词屏蔽', onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              children: [
                _inputCard(),
                const SizedBox(height: 14),
                if (keywords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
                    child: Text(
                      '添加关键词后，包含这些关键词的消息将不会在聊天中显示，也不会触发本地通知。',
                      style: TextStyle(fontSize: 14, color: c.textSecondary),
                    ),
                  )
                else
                  _keywordCard(keywords),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCard() {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              style: TextStyle(fontSize: 16, color: c.textPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: '输入关键词',
                hintStyle: TextStyle(color: c.textTertiary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _add,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.brand,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Text(
                '添加',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keywordCard(List<String> keywords) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final keyword in keywords) ...[
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(sfIcon('nosign'), size: 19, color: AppTheme.tagRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        keyword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: c.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _blocker.remove(keyword),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          sfIcon('xmark'),
                          size: 16,
                          color: c.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (keyword != keywords.last) const InsetDivider(leadingInset: 47),
          ],
        ],
      ),
    );
  }
}
