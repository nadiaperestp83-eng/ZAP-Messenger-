//
//  sf_symbols.dart
//
//  The Swift app uses SF Symbols (`Image(systemName:)`). SF Symbols are an
//  Apple-proprietary font that can't ship on Android, so we map each symbol used
//  across the app to its closest Font Awesome equivalent. This keeps the
//  iconography consistent on both platforms while staying call-site-readable:
//
//      Icon(sfIcon('chevron.left'))
//

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Map<String, Object> _map = {
  // Navigation / chrome
  'chevron.left': FontAwesomeIcons.chevronLeft,
  'chevron.right': FontAwesomeIcons.chevronRight,
  'chevron.up': FontAwesomeIcons.chevronUp,
  'chevron.down': FontAwesomeIcons.chevronDown,
  'xmark': FontAwesomeIcons.xmark,
  'clock': FontAwesomeIcons.clock,
  'timer': FontAwesomeIcons.stopwatch,
  'ellipsis': FontAwesomeIcons.ellipsis,
  'plus': FontAwesomeIcons.plus,
  'plus.circle': FontAwesomeIcons.circlePlus,
  'minus': FontAwesomeIcons.minus,
  'minus.circle': FontAwesomeIcons.circleMinus,
  'magnifyingglass': FontAwesomeIcons.magnifyingGlass,
  'line.3.horizontal': FontAwesomeIcons.bars,
  'line.3.horizontal.decrease': FontAwesomeIcons.filter,
  'arrow.left': FontAwesomeIcons.arrowLeft,
  'arrow.up': FontAwesomeIcons.arrowUp,
  'arrow.down': FontAwesomeIcons.arrowDown,
  'arrow.down.to.line': FontAwesomeIcons.download,
  'arrow.down.right.and.arrow.up.left': FontAwesomeIcons.expand,
  'slash.circle': FontAwesomeIcons.ban,

  // Tabs
  'message.fill': FontAwesomeIcons.solidMessage,
  'message': FontAwesomeIcons.message,
  'message.badge': FontAwesomeIcons.solidMessage,
  'number': FontAwesomeIcons.hashtag,
  'number.circle.fill': FontAwesomeIcons.hashtag,
  'person.2.fill': FontAwesomeIcons.users,
  'person.2': FontAwesomeIcons.users,
  'circle.dashed': FontAwesomeIcons.circleNotch,
  'person.crop.circle': FontAwesomeIcons.circleUser,
  'person.crop.circle.fill': FontAwesomeIcons.solidCircleUser,
  'square.and.pencil': FontAwesomeIcons.penToSquare,
  'pencil': FontAwesomeIcons.pen,
  'square.grid.2x2': FontAwesomeIcons.tableCells,

  // Appearance / settings
  'circle.lefthalf.filled': FontAwesomeIcons.circleHalfStroke,
  'sun.max': FontAwesomeIcons.sun,
  'sun.max.fill': FontAwesomeIcons.solidSun,
  'moon': FontAwesomeIcons.moon,
  'moon.fill': FontAwesomeIcons.solidMoon,
  'rectangle.split.3x1.fill': FontAwesomeIcons.tableColumns,
  'rectangle.split.2x1': FontAwesomeIcons.tableColumns,
  'pip.enter': FontAwesomeIcons.windowRestore,
  'sparkles': FontAwesomeIcons.wandMagicSparkles,
  'tshirt': FontAwesomeIcons.shirt,
  'gearshape.fill': FontAwesomeIcons.gear,
  'gearshape': FontAwesomeIcons.gear,
  'bell.fill': FontAwesomeIcons.solidBell,
  'bell': FontAwesomeIcons.bell,
  'lock.fill': FontAwesomeIcons.lock,
  'nosign': FontAwesomeIcons.ban,
  'lock.shield.fill': FontAwesomeIcons.shieldHalved,
  'iphone': FontAwesomeIcons.mobileScreenButton,
  'globe': FontAwesomeIcons.globe,
  'character.book.closed': FontAwesomeIcons.language,
  'questionmark.circle': FontAwesomeIcons.circleQuestion,
  'info.circle': FontAwesomeIcons.circleInfo,
  'trash': FontAwesomeIcons.trash,
  'trash.fill': FontAwesomeIcons.trash,
  'star': FontAwesomeIcons.star,
  'star.fill': FontAwesomeIcons.solidStar,
  'folder': FontAwesomeIcons.folder,
  'folder.fill': FontAwesomeIcons.solidFolder,
  'tray.full': FontAwesomeIcons.inbox,
  'qrcode': FontAwesomeIcons.qrcode,
  'qrcode.viewfinder': FontAwesomeIcons.qrcode,
  'antenna.radiowaves.left.and.right': FontAwesomeIcons.towerBroadcast,
  'square.and.arrow.up': FontAwesomeIcons.shareFromSquare,
  'chevron.left.forwardslash.chevron.right': FontAwesomeIcons.code,
  'textformat': FontAwesomeIcons.font,
  'photo.stack': FontAwesomeIcons.images,
  'paintpalette': FontAwesomeIcons.palette,
  'person.text.rectangle': FontAwesomeIcons.idBadge,
  'rectangle.grid.1x2': FontAwesomeIcons.tableColumns,
  'keyboard.chevron.compact.down': FontAwesomeIcons.chevronDown,

  // Conversation / input
  'paperplane.fill': FontAwesomeIcons.solidPaperPlane,
  'paperplane': FontAwesomeIcons.paperPlane,
  'mic.fill': FontAwesomeIcons.microphone,
  'face.smiling': FontAwesomeIcons.solidFaceSmile,
  'plus.circle.fill': FontAwesomeIcons.circlePlus,
  'photo': FontAwesomeIcons.image,
  'photo.fill': FontAwesomeIcons.solidImage,
  'camera.fill': FontAwesomeIcons.camera,
  'camera.rotate': FontAwesomeIcons.rotate,
  'phone.fill': FontAwesomeIcons.phone,
  'phone.down.fill': FontAwesomeIcons.phoneSlash,
  'video.fill': FontAwesomeIcons.video,
  'doc.fill': FontAwesomeIcons.solidFile,
  'doc': FontAwesomeIcons.file,
  'location.fill': FontAwesomeIcons.locationDot,
  'location': FontAwesomeIcons.locationDot,
  'arrowshape.turn.up.left': FontAwesomeIcons.reply,
  'arrowshape.turn.up.left.fill': FontAwesomeIcons.reply,
  'arrowshape.turn.up.right': FontAwesomeIcons.share,
  'hand.thumbsup': FontAwesomeIcons.thumbsUp,
  'bubble.left': FontAwesomeIcons.comment,
  'quote.bubble': FontAwesomeIcons.quoteLeft,
  'checkmark.circle': FontAwesomeIcons.circleCheck,
  'checkmark.double': FontAwesomeIcons.checkDouble,
  'circle.checkmark': FontAwesomeIcons.circleCheck,
  'circle.dashed.unchecked': FontAwesomeIcons.circle,
  'scissors': FontAwesomeIcons.scissors,
  'speaker.wave.2.fill': FontAwesomeIcons.volumeHigh,
  'speaker.slash.fill': FontAwesomeIcons.volumeXmark,
  'play.fill': FontAwesomeIcons.play,
  'pause.fill': FontAwesomeIcons.pause,
  'checkmark': FontAwesomeIcons.check,
  'link': FontAwesomeIcons.link,
  'mappin.and.ellipse': FontAwesomeIcons.locationPin,
  'music.note': FontAwesomeIcons.music,
  'music.note.list': FontAwesomeIcons.compactDisc,
  'checklist': FontAwesomeIcons.listCheck,
  'at': FontAwesomeIcons.at,
  'exclamationmark.triangle.fill': FontAwesomeIcons.triangleExclamation,
  'exclamationmark.circle': FontAwesomeIcons.circleExclamation,
  'doc.text': FontAwesomeIcons.file,
  'arrow.triangle.2.circlepath': FontAwesomeIcons.rotate,
  'arrow.counterclockwise': FontAwesomeIcons.rotateLeft,
  'rotate.right': FontAwesomeIcons.rotateRight,
  'crop': FontAwesomeIcons.crop,
  'paintbrush': FontAwesomeIcons.paintbrush,
  'drop': FontAwesomeIcons.droplet,
  'circle': FontAwesomeIcons.circle,
  'square': FontAwesomeIcons.square,
  'eye': FontAwesomeIcons.eye,
  'eye.slash': FontAwesomeIcons.eyeSlash,

  // Misc
  'person.badge.plus': FontAwesomeIcons.userPlus,
  'person.2.square.stack': FontAwesomeIcons.objectGroup,
  'square.grid.2x2.fill': FontAwesomeIcons.grip,
  'arrow.right.square': FontAwesomeIcons.rightFromBracket,
  'bell.slash.fill': FontAwesomeIcons.bellSlash,
  'pin.fill': FontAwesomeIcons.thumbtack,
  'archivebox.fill': FontAwesomeIcons.boxArchive,
  'circle.fill': FontAwesomeIcons.solidCircle,
};

/// Resolve an SF Symbol name to the closest Flutter icon. Unknown names fall
/// back to a neutral circle so a missing mapping is visible but harmless.
IconData sfIcon(String name) {
  final icon = _map[name];
  return switch (icon) {
    FaIconData(:final data) => data,
    IconData() => icon,
    _ => FontAwesomeIcons.circle.data,
  };
}
