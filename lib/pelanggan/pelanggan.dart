import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<Map<String, dynamic>> _pelanggan = [];
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select().order('pelanggan_id');
      setState(() {
        _pelanggan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
    }
  }

  Future<void> addPelanggan() async {
  if (_namaController.text.isEmpty || _alamatController.text.isEmpty || _teleponController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Isi semua kolom!'), backgroundColor: Colors.orange),
    );
    return;
  }

  try {
    // Cek apakah pelanggan sudah ada
    final existingPelanggan = await supabase
        .from('pelanggan')
        .select()
        .eq('nama_pelanggan', _namaController.text)
        .eq('nomor_telepon', _teleponController.text)
        .maybeSingle();

    if (existingPelanggan != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pelanggan sudah ada!'), backgroundColor: Colors.red),
      );
      return;
    }

    await supabase.from('pelanggan').insert({
      'nama_pelanggan': _namaController.text,
      'alamat': _alamatController.text,
      'nomor_telepon': _teleponController.text,
    });

    fetchPelanggan();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pelanggan ditambahkan!'), backgroundColor: Colors.green),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menambah pelanggan!'), backgroundColor: Colors.red),
    );
  }
}


Future<void> editPelanggan(int id, Map<String, dynamic> pelangganLama) async {
  if (_namaController.text.isEmpty || _alamatController.text.isEmpty || _teleponController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Isi semua kolom!'), backgroundColor: Colors.orange),
    );
    return;
  }

  // Cek apakah ada perubahan data
  if (_namaController.text == pelangganLama['nama_pelanggan'] &&
      _alamatController.text == pelangganLama['alamat'] &&
      _teleponController.text == pelangganLama['nomor_telepon']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data tidak berubah!'), backgroundColor: Colors.orange),
    );
    return;
  }

  try {
    // Cek apakah ada pelanggan lain dengan data yang sama
    final existingPelanggan = await supabase
        .from('pelanggan')
        .select()
        .eq('nama_pelanggan', _namaController.text)
        .eq('nomor_telepon', _teleponController.text)
        .neq('pelanggan_id', id) // Pastikan pelanggan yang sama tidak dibandingkan dengan dirinya sendiri
        .maybeSingle();

    if (existingPelanggan != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data pelanggan sudah ada!'), backgroundColor: Colors.red),
      );
      return;
    }

    await supabase.from('pelanggan').update({
      'nama_pelanggan': _namaController.text,
      'alamat': _alamatController.text,
      'nomor_telepon': _teleponController.text,
    }).eq('pelanggan_id', id);

    fetchPelanggan();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pelanggan diperbarui!'), backgroundColor: Colors.green),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengedit pelanggan!'), backgroundColor: Colors.red),
    );
  }
}

  Future<void> deletePelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
      fetchPelanggan();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pelanggan berhasil dihapus!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Error deleting pelanggan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pelanggan!'), backgroundColor: Colors.red),
      );
    }
  }

  void showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Pelanggan'),
          content: Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deletePelanggan(id);
              },
            ),
          ],
        );
      },
    );
  }

 void showEditPelangganDialog(Map<String, dynamic> pelanggan) {
  _namaController.text = pelanggan['nama_pelanggan'];
  _alamatController.text = pelanggan['alamat'];
  _teleponController.text = pelanggan['nomor_telepon'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _teleponController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Nomor Telepon'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Simpan'),
            onPressed: () => editPelanggan(pelanggan['pelanggan_id'], pelanggan),
          ),
        ],
      );
    },
  );
}


  void showAddPelangganDialog() {
    _namaController.clear();
    _alamatController.clear();
    _teleponController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: _teleponController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Nomor Telepon'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Tambah'),
              onPressed: addPelanggan,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _pelanggan.length,
        itemBuilder: (context, index) {
          final pelanggan = _pelanggan[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: Text(
                  pelanggan['nama_pelanggan'][0].toUpperCase(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              title: Text(pelanggan['nama_pelanggan'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alamat: ${pelanggan['alamat']}'),
                  Text('Telepon: ${pelanggan['nomor_telepon']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showEditPelangganDialog(pelanggan),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showDeleteConfirmationDialog(pelanggan['pelanggan_id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPelangganDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
