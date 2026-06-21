import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../state/profile_provider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controladores para los campos
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nombreCompletoCtrl = TextEditingController();
  final _ciCtrl = TextEditingController();
  final _nombreArtisticoCtrl = TextEditingController();
  final _biografiaCtrl = TextEditingController();

  XFile? _selectedImage;
  bool _isEditing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loadProfile().then((_) => _populateFields(profileProvider));
    }
  }

  void _populateFields(ProfileProvider provider) {
    if (!mounted) return;
    setState(() {
      _firstNameCtrl.text = provider.firstName;
      _lastNameCtrl.text = provider.lastName;
      _emailCtrl.text = provider.email;
      _nombreCompletoCtrl.text = provider.nombreCompleto ?? '';
      _ciCtrl.text = provider.ci ?? '';
      _nombreArtisticoCtrl.text = provider.nombreArtistico ?? '';
      _biografiaCtrl.text = provider.biografia ?? '';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _nombreCompletoCtrl.dispose();
    _ciCtrl.dispose();
    _nombreArtisticoCtrl.dispose();
    _biografiaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Seleccionar foto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogOption(
              icon: Icons.photo_library_rounded,
              label: 'Galería de fotos',
              onTap: () async {
                final img = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                  maxWidth: 800,
                );
                if (context.mounted) Navigator.pop(context, img);
              },
            ),
            const SizedBox(height: 12),
            _dialogOption(
              icon: Icons.camera_alt_rounded,
              label: 'Cámara',
              onTap: () async {
                final img = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 800,
                );
                if (context.mounted) Navigator.pop(context, img);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _isEditing = true;
      });
    }
  }

  Widget _dialogOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7C6FF7), size: 26),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    bool success;

    if (_selectedImage != null) {
      // Subir foto + datos juntos
      final fields = <String, String>{};
      if (_firstNameCtrl.text.isNotEmpty) fields['first_name'] = _firstNameCtrl.text.trim();
      if (_lastNameCtrl.text.isNotEmpty) fields['last_name'] = _lastNameCtrl.text.trim();
      if (_emailCtrl.text.isNotEmpty) fields['email'] = _emailCtrl.text.trim();
      if (_nombreCompletoCtrl.text.isNotEmpty) fields['nombre_completo'] = _nombreCompletoCtrl.text.trim();
      if (_ciCtrl.text.isNotEmpty) fields['ci'] = _ciCtrl.text.trim();
      if (profileProvider.esArtista) {
        if (_nombreArtisticoCtrl.text.isNotEmpty) fields['nombre_artistico_update'] = _nombreArtisticoCtrl.text.trim();
        if (_biografiaCtrl.text.isNotEmpty) fields['biografia_update'] = _biografiaCtrl.text.trim();
      }

      success = await profileProvider.updateProfileWithPhoto(
        foto: _selectedImage!,
        fields: fields,
      );
    } else {
      // Solo datos de texto
      final data = <String, dynamic>{};
      if (_firstNameCtrl.text.isNotEmpty) data['first_name'] = _firstNameCtrl.text.trim();
      if (_lastNameCtrl.text.isNotEmpty) data['last_name'] = _lastNameCtrl.text.trim();
      if (_emailCtrl.text.isNotEmpty) data['email'] = _emailCtrl.text.trim();
      if (_nombreCompletoCtrl.text.isNotEmpty) data['nombre_completo'] = _nombreCompletoCtrl.text.trim();
      if (_ciCtrl.text.isNotEmpty) data['ci'] = _ciCtrl.text.trim();
      if (profileProvider.esArtista) {
        if (_nombreArtisticoCtrl.text.isNotEmpty) data['nombre_artistico_update'] = _nombreArtisticoCtrl.text.trim();
        if (_biografiaCtrl.text.isNotEmpty) data['biografia_update'] = _biografiaCtrl.text.trim();
      }

      success = await profileProvider.updateProfileData(data);
    }

    if (!mounted) return;

    if (success) {
      // Log de verificacion: mostrar de donde viene la foto
      final fotoUrl = profileProvider.fotoUrl;
      if (fotoUrl != null) {
        if (fotoUrl.contains(':9000')) {
          debugPrint('[PERFIL] >> Foto almacenada en MinIO -> $fotoUrl');
        } else if (fotoUrl.contains('/media/')) {
          debugPrint('[PERFIL] >> Foto almacenada en LOCAL (media/) -> $fotoUrl');
        } else {
          debugPrint('[PERFIL] >> Foto URL -> $fotoUrl');
        }
      } else {
        debugPrint('[PERFIL] >> Sin foto de perfil');
      }

      setState(() {
        _selectedImage = null;
        _isEditing = false;
      });
      _populateFields(profileProvider);
      _showSnackBar('Perfil actualizado correctamente', isError: false);
    } else {
      _showSnackBar(profileProvider.errorMessage ?? 'Error al actualizar el perfil', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        // Control de acceso: solo fan y artista
        if (!profileProvider.isLoading && !profileProvider.puedeVerPerfil && profileProvider.profileData != null) {
          return _buildAccessDenied();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(profileProvider),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: profileProvider.isLoading && profileProvider.profileData == null
                      ? _buildLoadingState()
                      : profileProvider.profileData == null
                          ? _buildErrorState(profileProvider)
                          : _buildProfileContent(profileProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(ProfileProvider profileProvider) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0F0F1A),
      elevation: 0,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: [
        if (!profileProvider.isLoading && profileProvider.profileData != null)
          TextButton.icon(
            onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
            icon: Icon(
              _isEditing ? Icons.check_rounded : Icons.edit_rounded,
              color: const Color(0xFF7C6FF7),
              size: 20,
            ),
            label: Text(
              _isEditing ? 'Guardar' : 'Editar',
              style: const TextStyle(color: Color(0xFF7C6FF7), fontWeight: FontWeight.bold),
            ),
          ),
        if (_isEditing)
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
                _selectedImage = null;
              });
              _populateFields(profileProvider);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroSection(profileProvider),
      ),
    );
  }

  Widget _buildHeroSection(ProfileProvider profileProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            // Avatar con botón de edición
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isEditing ? const Color(0xFF7C6FF7) : const Color(0xFF2A2A4E),
                        width: _isEditing ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C6FF7).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF2A2A4E),
                      backgroundImage: _selectedImage != null
                          ? (kIsWeb
                              ? NetworkImage(_selectedImage!.path) as ImageProvider
                              : FileImage(File(_selectedImage!.path)) as ImageProvider)
                          : (profileProvider.fotoUrl != null
                              ? NetworkImage(profileProvider.fotoUrl!) as ImageProvider
                              : null),
                      child: _selectedImage == null && profileProvider.fotoUrl == null
                          ? Text(
                              _getInitials(profileProvider),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C6FF7),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6FF7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C6FF7).withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${profileProvider.firstName} ${profileProvider.lastName}'.trim().isEmpty
                  ? profileProvider.username
                  : '${profileProvider.firstName} ${profileProvider.lastName}'.trim(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Badges de roles
            Wrap(
              spacing: 8,
              children: profileProvider.roles.map((rol) => _buildRoleBadge(rol)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String rol) {
    Color color;
    IconData icon;
    switch (rol) {
      case 'artista':
        color = const Color(0xFFE74C3C);
        icon = Icons.music_note_rounded;
        break;
      case 'fan':
        color = const Color(0xFF3498DB);
        icon = Icons.favorite_rounded;
        break;
      default:
        color = const Color(0xFF7C6FF7);
        icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            rol.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileProvider profileProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Datos de cuenta
            _buildSectionHeader(Icons.person_outline_rounded, 'Datos de cuenta'),
            const SizedBox(height: 16),
            _buildField(
              controller: _firstNameCtrl,
              label: 'Nombre',
              icon: Icons.badge_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _lastNameCtrl,
              label: 'Apellido',
              icon: Icons.badge_outlined,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Sección: Datos personales (Persona)
            _buildSectionHeader(Icons.contact_page_outlined, 'Datos personales'),
            const SizedBox(height: 16),
            _buildField(
              controller: _nombreCompletoCtrl,
              label: 'Nombre completo',
              icon: Icons.person_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _ciCtrl,
              label: 'Cédula de identidad',
              icon: Icons.credit_card_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 24),

            // Sección: Perfil artístico (solo para artistas)
            if (profileProvider.esArtista) ...[
              _buildSectionHeader(Icons.music_note_rounded, 'Perfil artístico'),
              const SizedBox(height: 16),
              _buildField(
                controller: _nombreArtisticoCtrl,
                label: 'Nombre artístico',
                icon: Icons.star_rounded,
                enabled: _isEditing,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _biografiaCtrl,
                label: 'Biografía',
                icon: Icons.description_rounded,
                enabled: _isEditing,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
            ],

            // Información de solo lectura
            _buildInfoCard(profileProvider),
            const SizedBox(height: 16),
            _buildConfiguracionCard(profileProvider),
            const SizedBox(height: 24),

            // Botón Guardar (solo en modo edición)
            if (_isEditing)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: profileProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
                      )
                    : _buildSaveButton(),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7C6FF7).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7C6FF7), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: const Color(0xFF7C6FF7).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white60,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? const Color(0xFF7C6FF7) : Colors.white38,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF7C6FF7) : Colors.white30,
            size: 20,
          ),
          filled: true,
          fillColor: enabled ? const Color(0xFF1E1E2E) : const Color(0xFF161622),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2A2A4E), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF7C6FF7), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ProfileProvider profileProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de cuenta',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.alternate_email_rounded, 'Usuario', profileProvider.username),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.shield_rounded,
            'Roles',
            profileProvider.roles.join(', ').toUpperCase().isEmpty
                ? 'Sin roles asignados'
                : profileProvider.roles.join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguracionCard(ProfileProvider profileProvider) {
    final bool recibirNotif = profileProvider.profileData?['recibir_notificaciones'] ?? true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuraciones',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Color(0xFF7C6FF7), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Recibir notificaciones',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
              Switch(
                value: recibirNotif,
                activeColor: const Color(0xFF7C6FF7),
                activeTrackColor: const Color(0xFF7C6FF7).withOpacity(0.3),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.white10,
                onChanged: (bool value) async {
                  final success = await profileProvider.updateProfileData({
                    'recibir_notificaciones': value,
                  });
                  if (!mounted) return;
                  if (success) {
                    _showSnackBar('Preferencia de notificaciones actualizada', isError: false);
                  } else {
                    _showSnackBar('No se pudo actualizar la preferencia', isError: true);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7C6FF7), size: 18),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FF7), Color(0xFF5A4FCF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FF7).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _saveProfile,
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text(
          'Guardar cambios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF7C6FF7),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando perfil...',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ProfileProvider profileProvider) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 60),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el perfil',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              profileProvider.errorMessage ?? 'Intenta nuevamente',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => profileProvider.loadProfile(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6FF7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A2A4E)),
                ),
                child: const Icon(
                  Icons.phonelink_off_rounded,
                  size: 60,
                  color: Color(0xFF7C6FF7),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Perfil no disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tu tipo de cuenta no tiene perfil disponible en la app móvil. '
                'Los perfiles de administrador, organizador y verificador se gestionan desde la plataforma web.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(ProfileProvider provider) {
    final first = provider.firstName.isNotEmpty ? provider.firstName[0] : '';
    final last = provider.lastName.isNotEmpty ? provider.lastName[0] : '';
    if (first.isEmpty && last.isEmpty) {
      return provider.username.isNotEmpty ? provider.username[0].toUpperCase() : '?';
    }
    return '${first}${last}'.toUpperCase();
  }
}
