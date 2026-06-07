// Profile screen: editable personal info + picture.
part of '../main.dart';

class ProfilePage extends StatefulWidget {
  final TransactionManager manager;
  const ProfilePage({super.key, required this.manager});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.manager.username);
    _emailController = TextEditingController(text: widget.manager.email);
    _phoneController = TextEditingController(text: widget.manager.phoneNumber);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await widget.manager.setUserProfile(
        name: widget.manager.username,
        pic: image.path,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isEditing) {
                        widget.manager.setUserProfile(
                          name: _nameController.text,
                          mail: _emailController.text,
                          phone: _phoneController.text,
                        );
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isEditing
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isEditing
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.05,
                          ),
                          image: widget.manager.profilePicturePath != null
                              ? DecorationImage(
                                  image: _getProfileImage(
                                    widget.manager.profilePicturePath,
                                  )!,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: widget.manager.profilePicturePath == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondary,
                            radius: 22,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _infoField(theme, 'Full Name', _nameController),
                    Divider(
                      height: 32,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                    _infoField(theme, 'Email Address', _emailController),
                    Divider(
                      height: 32,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                    _infoField(theme, 'Phone Number', _phoneController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoField(
    ThemeData theme,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.only(top: 8),
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// --- PLAN PAGE (Notes / Goals / To-Do) ---

