//
//  profile_tab_view.dart
//
//  Dedicated "Perfil" bottom-nav tab — replaces the old sliding "我" drawer.
//  Same data source (ProfileViewModel) and the same preserved shortcuts
//  (Calls / Saved Messages / Files / Videos, account switcher) as the old
//  drawer, laid out as a proper full-screen tab instead of an overlay.
//

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mithka/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../app/app_navigator.dart';
import '../auth/account_store.dart';
import '../auth/auth_manager.dart';
import '../call/calls_view.dart';
import '../chat/chat_view.dart';
import '../chat/saved_messages_view.dart';
import '../chat/shared_media_view.dart';
import '../components/app_icons.dart';
import '../components/confirm_dialog.dart';
import '../components/photo_avatar.dart';
import '../components/ui_components.dart';
import '../l10n/telegram_language_controller.dart';
import '../settings/edit_profile_view.dart';
import '../settings/settings_view.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'profile_detail_view.dart';
import 'profile_view.dart';
import 'qr_code_view.dart';

class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  final _vm = ProfileViewModel();
  bool _showArchivedPosts = false;

  @override
  void initState() {
    super.initState();
    _vm.addListener(() {
      if (mounted) setState(() {});
    });
    _vm.onAppear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountStore>().refresh();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  NavigatorState get _root => Navigator.of(context, rootNavigator: true);

  void _openSaved(String title) {
    final cid = _vm.savedChatId ?? _vm.user?.id ?? 0;
    final bookmarkView = context
        .read<ThemeController>()
        .savedMessagesBookmarkView;
    pushAppChatRoute(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => bookmarkView
            ? const SavedMessagesView()
            : ChatView(chatId: cid, title: title),
      ),
    );
  }

  void _openMyProfile() {
    final user = _vm.user;
    if (user == null || user.id <= 0) return;
    _root.push(
      MaterialPageRoute(
        builder: (_) => ProfileDetailView(userId: user.id, name: user.name),
      ),
    );
  }

  void _editPhoto() => _root.push(
    MaterialPageRoute(
      builder: (_) => const EditProfileView(openAvatarPicker: true),
    ),
  );

  void _editInfo() =>
      _root.push(MaterialPageRoute(builder: (_) => const EditProfileView()));

  void _openSettings() =>
      _root.push(MaterialPageRoute(builder: (_) => const SettingsView()));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      color: c.groupedBackground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _topBar(),
            const SizedBox(height: 12),
            _identity(),
            const SizedBox(height: 20),
            _actionCardsRow(),
            const SizedBox(height: 16),
            _phoneCard(),
            const SizedBox(height: 16),
            _card(child: _shortcutRows()),
            const SizedBox(height: 20),
            _postsSection(),
            const SizedBox(height: 20),
            _card(child: _accountsCard()),
          ],
        ),
      ),
    );
  }

  // MARK: - Top bar / identity

  Widget _topBar() {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _root.push(
              MaterialPageRoute(
                builder: (_) => QRCodeView(
                  name: _vm.user?.name ?? AppStrings.t(AppStringKeys.chatMeLabel),
                ),
              ),
            ),
            child: SizedBox(
              width: AppMetric.hitTarget,
              height: AppMetric.hitTarget,
              child: AppIcon(
                HeroAppIcons.qrcode,
                size: AppIconSize.toolbar,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identity() {
    final c = context.colors;
    final user = _vm.user;
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openMyProfile,
          child: PhotoAvatar(
            title: user?.name ?? AppStrings.t(AppStringKeys.chatMeLabel),
            photo: user?.photo,
            size: 96,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? AppStrings.t(AppStringKeys.contactsLoading),
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          telegramPresenceText(TelegramPresenceLabel.online),
          style: GoogleFonts.inter(fontSize: 14, color: c.textSecondary),
        ),
      ],
    );
  }

  // MARK: - Quick action cards

  Widget _actionCardsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _actionCard(
              icon: HeroAppIcons.camera,
              label: 'Definir Foto',
              onTap: _editPhoto,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionCard(
              icon: HeroAppIcons.penToSquare,
              label: 'Editar Informações',
              onTap: _editInfo,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionCard(
              icon: HeroAppIcons.gear,
              label: 'Configurações',
              onTap: _openSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required AppIconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 22, color: c.textPrimary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Phone card

  Widget _phoneCard() {
    final c = context.colors;
    final hidePhone = context.watch<ThemeController>().hideSidebarPhone;
    final phone = _vm.user?.phoneNumber ?? '';
    if (hidePhone || phone.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phone,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Celular',
              style: GoogleFonts.inter(fontSize: 13, color: c.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Preserved shortcuts (Calls / Saved / Files / Videos)

  Widget _shortcutRows() {
    return Column(
      children: [
        _row(
          HeroAppIcons.phone,
          const Color(0xFF34C759),
          AppStrings.t(AppStringKeys.callsTitle),
          () => _root.push(MaterialPageRoute(builder: (_) => const CallsView())),
        ),
        _row(
          HeroAppIcons.thumbtack,
          const Color(0xFFFF9D2E),
          AppStrings.t(AppStringKeys.savedMessages),
          () => _openSaved(AppStrings.t(AppStringKeys.savedMessages)),
        ),
        _row(
          HeroAppIcons.folder,
          const Color(0xFF3C8CF0),
          telegramText(AppStringKeys.topicPostContentFile),
          () => _root.push(
            MaterialPageRoute(
              builder: (_) => SharedMediaView(
                chatId: 0,
                title: telegramText(AppStringKeys.topicPostContentFile),
                initialTab: 1,
                displayTitle: AppStringKeys.topicPostContentFile,
              ),
            ),
          ),
        ),
        _row(
          HeroAppIcons.video,
          const Color(0xFF7B61FF),
          telegramText(AppStringKeys.sharedMediaVideos),
          () => _root.push(
            MaterialPageRoute(
              builder: (_) => SharedMediaView(
                chatId: 0,
                title: telegramText(AppStringKeys.sharedMediaVideos),
                initialTab: 4,
                displayTitle: AppStringKeys.sharedMediaVideos,
                lockedTab: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(AppIconData icon, Color color, String label, VoidCallback onTap) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 32,
                alignment: Alignment.center,
                child: AppIcon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 15, color: c.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              AppIcon(
                HeroAppIcons.chevronRight,
                size: 15,
                color: c.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Posts section
  //
  // Visual shell only for now (segmented toggle + empty state), matching the
  // reference layout. Wiring "Adicionar um post" to a real composer needs the
  // Moments tab's publishing flow, which isn't safely reachable from here yet
  // — flagged rather than guessed at.

  Widget _postsSection() {
    final c = context.colors;
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _postsToggle('Posts', !_showArchivedPosts),
                _postsToggle('Posts Arquivados', _showArchivedPosts),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Nenhum post ainda...',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Publique fotos e vídeos para mostrar na sua página de perfil',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: c.textTertiary),
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.brand,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(HeroAppIcons.camera, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Adicione um post',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _postsToggle(String label, bool selected) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _showArchivedPosts = label != 'Posts'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.brand.withValues(alpha: 0.14) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppTheme.brand : c.textSecondary,
          ),
        ),
      ),
    );
  }

  // MARK: - Card shell

  Widget _card({required Widget child}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  // MARK: - Account switcher (unchanged from the old drawer)

  Widget _accountsCard() {
    final accounts = context.watch<AccountStore>();
    final hidePhone = context.watch<ThemeController>().hideSidebarPhone;
    return Column(
      children: [
        const InsetDivider(leadingInset: 0),
        for (final s in accounts.summaries) ...[
          _SwipeAccountRow(
            onTap: () => accounts.switchTo(s.slot, context.read<AuthManager>()),
            onLongPress: () => _confirmRemoveAccount(accounts, s),
            onRemove: () => _confirmRemoveAccount(accounts, s),
            onLogout: () => _confirmLogOutAccount(accounts, s),
            child: _accountRow(
              s.name,
              hidePhone ? '' : s.phone,
              s.avatarPath,
              selected: s.slot == accounts.activeSlot,
            ),
          ),
          const InsetDivider(leadingInset: 64),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => accounts.addAccount(context.read<AuthManager>()),
          child: SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.brand.withValues(alpha: 0.12),
                    ),
                    child: AppIcon(
                      HeroAppIcons.plus,
                      size: 18,
                      color: AppTheme.brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.t(AppStringKeys.profileAddAccount),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _accountLabel(AccountSummary s) =>
      s.phone.isNotEmpty ? '${s.name}（${s.phone}）' : s.name;

  Future<void> _confirmRemoveAccount(
    AccountStore accounts,
    AccountSummary s,
  ) async {
    final ok = await confirmDialog(
      context,
      title: AppStrings.t(AppStringKeys.profileRemoveAccount),
      message: AppStrings.t(AppStringKeys.profileRemoveAccountConfirm, {
        'value1': _accountLabel(s),
      }),
      confirmText: AppStrings.t(AppStringKeys.chatInfoRemove),
      destructive: true,
    );
    if (!ok || !mounted) return;
    await accounts.removeAccount(s.slot, context.read<AuthManager>());
  }

  Future<void> _confirmLogOutAccount(
    AccountStore accounts,
    AccountSummary s,
  ) async {
    final ok = await confirmDialog(
      context,
      title: AppStrings.t(AppStringKeys.profileLogOutAccount),
      message: AppStrings.t(AppStringKeys.profileLogOutAccountConfirm, {
        'value1': _accountLabel(s),
      }),
      confirmText: AppStrings.t(AppStringKeys.settingsLogOut),
      destructive: true,
    );
    if (!ok || !mounted) return;
    await accounts.logOutAccount(s.slot, context.read<AuthManager>());
  }

  Widget _accountRow(
    String name,
    String phone,
    String? avatarPath, {
    required bool selected,
  }) {
    final c = context.colors;
    final avatarCacheSize = (36 * MediaQuery.devicePixelRatioOf(context))
        .ceil();
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (avatarPath != null && avatarPath.isNotEmpty)
              ClipOval(
                child: Image.file(
                  File(avatarPath),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  cacheWidth: avatarCacheSize,
                  cacheHeight: avatarCacheSize,
                ),
              )
            else
              PhotoAvatar(title: name, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 15, color: c.textPrimary),
                  ),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              AppIcon(HeroAppIcons.check, size: 16, color: AppTheme.brand),
          ],
        ),
      ),
    );
  }
}

class _SwipeAccountRow extends StatefulWidget {
  const _SwipeAccountRow({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
    required this.onLogout,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;
  final VoidCallback onLogout;

  @override
  State<_SwipeAccountRow> createState() => _SwipeAccountRowState();
}

class _SwipeAccountRowState extends State<_SwipeAccountRow> {
  static const double _actionWidth = 78;
  static const double _actionsWidth = _actionWidth * 2;
  double _offset = 0;

  void _close() {
    if (_offset == 0) return;
    setState(() => _offset = 0);
  }

  void _run(VoidCallback action) {
    _close();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SwipeActionButton(
                    label: AppStrings.t(AppStringKeys.chatInfoRemove),
                    color: const Color(0xFFFF9500),
                    onTap: () => _run(widget.onRemove),
                  ),
                  _SwipeActionButton(
                    label: AppStrings.t(AppStringKeys.settingsLogOut),
                    color: AppTheme.tagRed,
                    onTap: () => _run(widget.onLogout),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            left: _offset,
            right: -_offset,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _offset < 0 ? _close : widget.onTap,
              onLongPress: widget.onLongPress,
              onHorizontalDragUpdate: (details) {
                final next = (_offset + details.delta.dx).clamp(
                  -_actionsWidth,
                  0.0,
                );
                if (next != _offset) setState(() => _offset = next);
              },
              onHorizontalDragEnd: (_) {
                setState(() {
                  _offset = _offset.abs() > _actionsWidth * 0.35
                      ? -_actionsWidth
                      : 0;
                });
              },
              child: ColoredBox(color: c.card, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _SwipeAccountRowState._actionWidth,
        height: double.infinity,
        alignment: Alignment.center,
        color: color,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: readableForeground(color),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
