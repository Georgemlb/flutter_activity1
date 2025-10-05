import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../widgets/level_range_selector.dart';

class PlayerFormScreen extends StatefulWidget {
  final Player? existing;
  const PlayerFormScreen({super.key, this.existing});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nick = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _addr = TextEditingController();
  final _remarks = TextEditingController();
  RangeValues _range = const RangeValues(3, 8); // defaults

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _nick.text = p.nickname;
      _name.text = p.fullName;
      _phone.text = p.contact;
      _email.text = p.email;
      _addr.text = p.address;
      _remarks.text = p.remarks;
      _range = RangeValues(p.levelStart.toDouble(), p.levelEnd.toDouble());
    }
  }

  @override
  void dispose() {
    _nick.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _addr.dispose();
    _remarks.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _emailValidator(String? v) {
    if (_required(v) != null) return 'Required';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(v!.trim()) ? null : 'Enter a valid email';
  }

  /// ✅ PH phone number validator
  /// Accepts:
  /// - 09XXXXXXXXX  (11 digits)
  /// - +639XXXXXXXXX (13 characters)
  String? _phoneValidator(String? v) {
    if (_required(v) != null) return 'Required';
    final s = v!.trim();
    final re = RegExp(r'^(09\d{9}|\+639\d{9})$');
    if (!re.hasMatch(s)) {
      return 'Use PH format: 09XXXXXXXXX or +639XXXXXXXXX';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Player' : 'Add New Player')),
      body: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nick,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nickname'),
              validator: _required,
            ),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: _required,
            ),
            TextFormField(
              controller: _phone,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\+]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                hintText: '09XXXXXXXXX or +639XXXXXXXXX',
              ),
              validator: _phoneValidator,
            ),
            TextFormField(
              controller: _email,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: _emailValidator,
            ),
            TextFormField(
              controller: _addr,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
              validator: _required,
            ),
            TextFormField(
              controller: _remarks,
              decoration: const InputDecoration(labelText: 'Remarks'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            LevelRangeSelector(
              values: _range,
              onChanged: (v) => setState(() => _range = v),
            ),

            const SizedBox(height: 24),
            // --- Save/Update Buttons ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      final p = Player(
                        id: widget.existing?.id ??
                            DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                        nickname: _nick.text.trim(),
                        fullName: _name.text.trim(),
                        contact: _phone.text.trim(),
                        email: _email.text.trim(),
                        address: _addr.text.trim(),
                        remarks: _remarks.text.trim(),
                        levelStart: _range.start.round(),
                        levelEnd: _range.end.round(),
                      );
                      Navigator.pop(context, p);
                    },
                    child: Text(isEdit ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),

            // --- Delete Button (Only when Editing) ---
            if (isEdit) ...[
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final sure = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete player?'),
                      content: Text(
                          'Remove ${widget.existing!.nickname}? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (sure == true) {
                    Navigator.pop(context, {
                      'deleted': true,
                      'id': widget.existing!.id,
                    });
                  }
                },
                child: const Text('Delete Player'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
