// Shared helpers (cross-platform profile image provider).
part of 'main.dart';

ImageProvider? _getProfileImage(String? path) {
  if (path == null) return null;
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}

