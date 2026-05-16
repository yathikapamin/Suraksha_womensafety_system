import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/emergency_contact.dart';
import '../providers/auth_provider.dart';
import '../services/emergency_contact_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final EmergencyContactService _service = EmergencyContactService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      final contacts = await _service.getContacts(auth.user!.id);
      if (mounted) setState(() { _contacts = contacts; _isLoading = false; });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addContact() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    bool isPrimary = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Emergency Contact', style: AppTheme.headingSmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+91 98765 43210',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relCtrl,
                  decoration: InputDecoration(
                    hintText: 'Relationship (e.g. Mother, Sister)',
                    prefixIcon: const Icon(Icons.group_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isPrimary,
                      onChanged: (v) => setDialogState(() => isPrimary = v ?? false),
                      activeColor: AppTheme.primaryBlue,
                    ),
                    Text('Primary Contact', style: AppTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        setState(() => _isLoading = true);
        await _service.addContact(
          userId: auth.user!.id,
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          relationship: relCtrl.text.trim(),
          isPrimary: isPrimary,
        );
        await _loadContacts();
      }
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      await _service.removeContact(auth.user!.id, contact.id);
      await _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppTheme.grey700, size: 28),
                  ),
                  Text('SafeNet AI', style: AppTheme.brandText),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Contacts', style: AppTheme.headingLarge),
                  const SizedBox(height: 6),
                  Text(
                    'These people will be immediately notified with your live location when danger is detected.',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Info banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRed.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dangerRed.withAlpha(25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'When SOS is triggered, all contacts receive an SMS with your exact GPS coordinates and a Google Maps link.',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.dangerRed, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contacts list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                  : _contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 60, color: AppTheme.grey300),
                              const SizedBox(height: 16),
                              Text('No emergency contacts yet', style: AppTheme.bodyLarge),
                              const SizedBox(height: 4),
                              Text('Add your family members to keep them informed', style: AppTheme.bodySmall),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _contacts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _buildContactCard(_contacts[i]),
                        ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addContact,
                  icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                  label: Text('Add Emergency Contact', style: AppTheme.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: contact.isPrimary
                ? AppTheme.primaryBlue.withAlpha(20)
                : AppTheme.grey100,
            child: Icon(
              Icons.person,
              color: contact.isPrimary ? AppTheme.primaryBlue : AppTheme.grey500,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(contact.name, style: AppTheme.labelLarge),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('PRIMARY', style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.dangerRed, fontSize: 9, fontWeight: FontWeight.w700,
                        )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${contact.relationship} • ${contact.phone}', style: AppTheme.bodySmall),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.safeGreen.withAlpha(15),
                ),
                child: const Icon(Icons.phone, color: AppTheme.safeGreen, size: 16),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _deleteContact(contact),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.dangerRed.withAlpha(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: AppTheme.dangerRed, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
