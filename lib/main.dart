import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Palet warna
const Color kUtama = Color(0xFF8B5E3C);
const Color kSekunder = Color(0xFFB8865B);
const Color kLatar = Color(0xFFFAF5EF);
const Color kTinta = Color(0xFF3E2723);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendaftaran Kegiatan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: kUtama,
        useMaterial3: true,
        scaffoldBackgroundColor: kLatar,
      ),
      home: const FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  String? _jenisKelamin;
  final Map<String, bool> _hobi = {
    'Membaca': false,
    'Olahraga': false,
    'Musik': false,
    'Fotografi': false,
  };
  String? _prodi;
  bool _setuju = false;

  String? _jkError;
  String? _hobiError;
  String? _setujuError;

  final List<String> _daftarProdi = ['Pendidikan TI', 'Bisnis Digital', 'PGSD'];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Menghitung berapa bagian form yang sudah terisi (dari 8)
  int get _terisi {
    int n = 0;
    if (_namaCtrl.text.trim().isNotEmpty) n++;
    if (_nimCtrl.text.trim().isNotEmpty) n++;
    if (_emailCtrl.text.trim().isNotEmpty) n++;
    if (_passwordCtrl.text.isNotEmpty) n++;
    if (_jenisKelamin != null) n++;
    if (_hobi.values.any((v) => v)) n++;
    if (_prodi != null) n++;
    if (_setuju) n++;
    return n;
  }

  void _simpan() {
    final formValid = _formKey.currentState!.validate();
    final hobiTerpilih =
        _hobi.entries.where((e) => e.value).map((e) => e.key).toList();

    setState(() {
      _jkError = _jenisKelamin == null ? 'Pilih jenis kelamin' : null;
      _hobiError = hobiTerpilih.isEmpty ? 'Pilih minimal satu hobi' : null;
      _setujuError =
          !_setuju ? 'Anda harus menyetujui syarat dan ketentuan' : null;
    });

    if (formValid &&
        _jkError == null &&
        _hobiError == null &&
        _setujuError == null) {
      _tampilkanRingkasan(hobiTerpilih);
    } else {
      // Beri tahu pengguna kalau masih ada data yang belum sesuai
      final belum = <String>[];
      if (_namaCtrl.text.trim().isEmpty) belum.add('nama');
      if (_nimCtrl.text.trim().length < 8) belum.add('NIM (min. 8 digit)');
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
          .hasMatch(_emailCtrl.text.trim())) {
        belum.add('email');
      }
      if (_passwordCtrl.text.length < 8) belum.add('password (min. 8 karakter)');
      if (_jenisKelamin == null) belum.add('jenis kelamin');
      if (hobiTerpilih.isEmpty) belum.add('hobi');
      if (_prodi == null) belum.add('program studi');
      if (!_setuju) belum.add('persetujuan');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
            content: Text('Belum lengkap/sesuai: ${belum.join(', ')}'),
          ),
        );
    }
  }

  // ---------- Dekorasi input ----------
  OutlineInputBorder _batas(Color c, [double w = 1.2]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );

  InputDecoration _dekor(String label, String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: kUtama),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFFFBF6),
      border: _batas(const Color(0xFFE0CDB5)),
      enabledBorder: _batas(const Color(0xFFE0CDB5)),
      focusedBorder: _batas(kUtama, 2),
      errorBorder: _batas(Colors.red.shade400),
      focusedErrorBorder: _batas(Colors.red.shade400, 2),
    );
  }

  // ---------- Ringkasan ----------
  void _tampilkanRingkasan(List<String> hobiTerpilih) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 44),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Pendaftaran Berhasil!',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: kTinta),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Berikut ringkasan data Anda',
                    style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 18),
              _baris(Icons.person, 'Nama', _namaCtrl.text.trim()),
              _baris(Icons.badge, 'NIM', _nimCtrl.text.trim()),
              _baris(Icons.email, 'Email', _emailCtrl.text.trim()),
              _baris(Icons.lock, 'Password', '•' * _passwordCtrl.text.length),
              _baris(Icons.wc, 'Jenis kelamin', _jenisKelamin ?? '-'),
              _baris(Icons.school, 'Program studi', _prodi ?? '-'),
              const SizedBox(height: 4),
              const Text('Hobi',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: hobiTerpilih
                    .map((h) => Chip(
                          label: Text(h),
                          backgroundColor: const Color(0xFFF1E4D3),
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                              color: kUtama, fontWeight: FontWeight.w600),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kUtama,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _baris(IconData ikon, String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1E4D3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, size: 16, color: kUtama),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
                Text(nilai,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: kTinta)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Komponen tampilan ----------
  Widget _header() {
    final terisi = _terisi;
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 20, 20, 64),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E342E), kUtama, kSekunder],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.assignment_turned_in,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pendaftaran Kegiatan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Lengkapi data diri Anda di bawah ini',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kelengkapan form',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text('$terisi / 8',
                    style: const TextStyle(
                        color: Colors.amberAccent, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: terisi / 8,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.amberAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartu(String judul, IconData ikon, List<Widget> isi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kUtama.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kUtama, kSekunder]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(ikon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(judul,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTinta)),
            ],
          ),
          const SizedBox(height: 16),
          ...isi,
        ],
      ),
    );
  }

  // Tile pilihan (dipakai untuk Radio dan Checkbox)
  Widget _tilePilihan({
    required String label,
    required bool terpilih,
    required Widget kontrol,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: terpilih ? const Color(0xFFF1E4D3) : const Color(0xFFFFFBF6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: terpilih ? kUtama : const Color(0xFFE0CDB5),
            width: terpilih ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            IgnorePointer(child: kontrol),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontWeight: terpilih ? FontWeight.w700 : FontWeight.w500,
                    color: terpilih ? kUtama : kTinta,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tileJenisKelamin(String nilai) {
    return _tilePilihan(
      label: nilai,
      terpilih: _jenisKelamin == nilai,
      kontrol: Radio<String>(
        value: nilai,
        groupValue: _jenisKelamin,
        activeColor: kUtama,
        onChanged: (_) {},
      ),
      onTap: () => setState(() => _jenisKelamin = nilai),
    );
  }

  Widget _pesanError(String pesan) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Row(
        children: [
          Icon(Icons.error, size: 14, color: Colors.red.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(pesan,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lebarTile =
        (MediaQuery.of(context).size.width - 32 - 32 - 10) / 2; // 2 kolom

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ===== Data diri =====
                    _kartu('Data Diri', Icons.person, [
                      TextFormField(
                        controller: _namaCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: _dekor('Nama Lengkap',
                            'Masukkan nama lengkap', Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nimCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: _dekor(
                            'NIM', 'Minimal 8 digit angka', Icons.badge_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'NIM wajib diisi';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                            return 'NIM harus berupa angka';
                          }
                          if (value.trim().length < 8) {
                            return 'NIM minimal 8 digit';
                          }
                          return null;
                        },
                      ),
                    ]),

                    // ===== Akun =====
                    _kartu('Akun', Icons.lock, [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        decoration: _dekor(
                            'Email', 'nama@email.com', Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          final emailRegex =
                              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() {}),
                        decoration: _dekor(
                          'Password',
                          'Minimal 8 karakter',
                          Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kUtama,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                    ]),

                    // ===== Pilihan =====
                    _kartu('Pilihan', Icons.checklist, [
                      const Text('Jenis Kelamin',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: kTinta)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _tileJenisKelamin('Laki-laki')),
                          const SizedBox(width: 10),
                          Expanded(child: _tileJenisKelamin('Perempuan')),
                        ],
                      ),
                      if (_jkError != null) _pesanError(_jkError!),
                      const SizedBox(height: 18),
                      const Text('Hobi (boleh lebih dari satu)',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: kTinta)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _hobi.keys.map((nama) {
                          final aktif = _hobi[nama]!;
                          return SizedBox(
                            width: lebarTile,
                            child: _tilePilihan(
                              label: nama,
                              terpilih: aktif,
                              kontrol: Checkbox(
                                value: aktif,
                                activeColor: kUtama,
                                onChanged: (_) {},
                              ),
                              onTap: () =>
                                  setState(() => _hobi[nama] = !aktif),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_hobiError != null) _pesanError(_hobiError!),
                      const SizedBox(height: 18),
                      const Text('Program Studi',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: kTinta)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _prodi,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: kUtama),
                        decoration: _dekor('Pilih program studi',
                            'Program studi', Icons.school_outlined),
                        items: _daftarProdi
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (value) => setState(() => _prodi = value),
                        validator: (value) =>
                            value == null ? 'Pilih program studi' : null,
                      ),
                    ]),

                    // ===== Persetujuan + Simpan =====
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: kUtama.withOpacity(0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tilePilihan(
                            label: 'Saya menyetujui syarat dan ketentuan',
                            terpilih: _setuju,
                            kontrol: Checkbox(
                              value: _setuju,
                              activeColor: kUtama,
                              onChanged: (_) {},
                            ),
                            onTap: () => setState(() => _setuju = !_setuju),
                          ),
                          if (_setujuError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 6),
                              child: _pesanError(_setujuError!),
                            ),
                        ],
                      ),
                    ),

                    Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(colors: [kUtama, kSekunder]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: kUtama.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _simpan,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, color: Colors.white),
                                SizedBox(width: 10),
                                Text('Simpan',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bentuk gelombang di bagian bawah header
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 30);
    p.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 22);
    p.quadraticBezierTo(
        size.width * 0.78, size.height - 46, size.width, size.height - 12);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}