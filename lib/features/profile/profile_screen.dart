import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../core/constants/districts.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const int _maxContacts = 5;

  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  late final TextEditingController _nameCtrl;
  late String _district;
  late List<EmergencyContact> _contacts;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Start from the current profile values
    _nameCtrl = TextEditingController(text: widget.user.name);
    _district = widget.user.district;
    _contacts = List.of(widget.user.emergencyContacts);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addContact() async {
    final t = AppLocalizations.of(context)!;

    if (_contacts.length >= _maxContacts) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.maxContacts)));
      return;
    }

    final contact = await showDialog<EmergencyContact>(
      context: context,
      builder: (_) => const _ContactDialog(),
    );

    if (contact != null) {
      setState(() => _contacts.add(contact));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final t = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await _userService.updateProfile(
        uid: widget.user.uid,
        name: _nameCtrl.text,
        district: _district,
        contacts: _contacts,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.profileSaved)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isSi = Localizations.localeOf(context).languageCode == 'si';

    return Scaffold(
      appBar: AppBar(title: Text(t.profile)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: t.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
                ),
                const SizedBox(height: 16),

                // Email (read-only, cannot be changed here)
                TextFormField(
                  initialValue: widget.user.email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: t.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // District
                DropdownButtonFormField<String>(
                  initialValue: _district,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: t.district,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  items: sriLankaDistricts
                      .map((d) => DropdownMenuItem<String>(
                            value: d.en,
                            child: Text(isSi ? d.si : d.en),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _district = v);
                  },
                ),
                const SizedBox(height: 32),

                // Emergency contacts header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.emergencyContacts,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addContact,
                      icon: const Icon(Icons.add),
                      label: Text(t.add),
                    ),
                  ],
                ),
                Text(t.emergencyContactsHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),

                // Contacts list
                if (_contacts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text(t.noContacts)),
                  )
                else
                  ..._contacts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.contact_phone_outlined),
                        title: Text(c.name),
                        subtitle: Text(c.phone),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              setState(() => _contacts.removeAt(i)),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Save button
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog for adding one emergency contact.
// It is its own widget so it owns and disposes its controllers safely.
class _ContactDialog extends StatefulWidget {
  const _ContactDialog();

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      EmergencyContact(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.replaceAll(' ', ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(t.addContact),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t.contactName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: t.contactPhone,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return t.fieldRequired;
                // Accepts 9-12 digits with an optional leading +
                final phone = v.replaceAll(' ', '');
                if (!RegExp(r'^\+?[0-9]{9,12}$').hasMatch(phone)) {
                  return t.invalidPhone;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(t.add)),
      ],
    );
  }
}