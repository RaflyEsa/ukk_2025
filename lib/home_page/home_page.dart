import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/login/login.dart';
import 'package:ukk_2025/pelanggan/pelanggan.dart';
import 'package:ukk_2025/transaksi/transaksi.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String username;

  const HomePage({super.key, required this.userId, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  late TabController _tabController;

  get supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchProduk();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchProduk() async {
    try {
      final response =
          await supabase.from('produk').select().order('produk_id');
      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

    Future<void> addProduct() async {
    if (_nameController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Isi semua kolom!'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    try {
      // Cek apakah produk dengan nama yang sama sudah ada di database
      final existingProduct = await supabase
          .from('produk')
          .select()
          .eq('nama_produk', _nameController.text)
          .maybeSingle();

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Produk sudah ada!'),
              backgroundColor: Colors.red),
        );
        return;
      }

      // Jika produk belum ada, tambahkan ke database
      await supabase.from('produk').insert({
        'nama_produk': _nameController.text,
        'harga': int.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
      });

      fetchProduk();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Produk ditambahkan!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah!'), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> updateProduct(
      int id, String oldNama, int oldHarga, int oldStok) async {
    String newNama = _nameController.text;
    int newHarga = int.tryParse(_hargaController.text) ?? 0;
    int newStok = int.tryParse(_stokController.text) ?? 0;

    if (newNama == oldNama && newHarga == oldHarga && newStok == oldStok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tidak ada perubahan!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (newNama.isEmpty || newHarga <= 0 || newStok < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Isi semua kolom dengan benar!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await supabase.from('produk').update({
        'nama_produk': newNama,
        'harga': newHarga,
        'stok': newStok,
      }).eq('produk_id', id);
      fetchProduk();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Produk diperbarui!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal memperbarui!'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await supabase.from('produk').delete().eq('produk_id', id);
      fetchProduk();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
          title: Text(
            'Konfirmasi Penghapusan',
            style: TextStyle(color: Colors.blueGrey[900]),
          ),
          content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: <Widget>[
            // Tombol Tidak
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, // Background red
                padding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Tombol lebih besar
                minimumSize: Size(120, 48), // Ukuran minimum tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Tidak', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            // Tombol Iya
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Background green
                padding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Tombol lebih besar
                minimumSize: Size(120, 48), // Ukuran minimum tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Iya', style: TextStyle(fontSize: 18)),
              onPressed: () {
                deleteProduct(id);
                Navigator.of(context).pop(); // Menutup dialog setelah menghapus
              },
            ),
          ],
        );
      },
    );
  }

  void addToTransaction(Map<String, dynamic> product) {
    TextEditingController jumlahController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pilih Jumlah"),
          content: TextField(
            controller: jumlahController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Masukkan jumlah",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                int jumlah = int.tryParse(jumlahController.text) ?? 0;

                if (jumlah <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Jumlah harus lebih dari 0!"),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                if (jumlah > product['stok']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Stok tidak mencukupi!"),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  int totalHarga = (jumlah * product['harga']).toInt();

                  // Cek apakah harga valid
                  if (totalHarga <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Total harga tidak valid!"),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Jalankan transaksi Supabase
                  await supabase.from('penjualan').insert({
                    'produk_id': product['produk_id'],
                    'user_id': widget.userId,
                    'jumlah': jumlah,
                    'total_harga': (jumlah * product['harga']).toInt(),
                    'tanggal': DateTime.now()
                        .toIso8601String()
                        .split('T')[0], 
                  });

                  // Ambil ID transaksi terakhir
                  final response = await supabase
                      .from('penjualan')
                      .select('id')
                      .order('id', ascending: false)
                      .limit(1)
                      .single();

                  int penjualanId = response['id'];

                  // Masukkan detail penjualan
                  await supabase.from('detailpenjualan').insert({
                    'penjualan_id': penjualanId,
                    'produk_id': product['produk_id'],
                    'jumlah': jumlah,
                    'subtotal': totalHarga, // Pastikan subtotal dihitung
                  });

                  // Update stok produk
                  await supabase
                      .from('produk')
                      .update({'stok': product['stok'] - jumlah}).eq(
                          'produk_id', product['produk_id']);

                  // Jika berhasil
                  Navigator.pop(context); // Tutup dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Transaksi berhasil!"),
                        backgroundColor: Colors.green),
                  );

                  // Navigasi ke halaman transaksi
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransaksiPage(),
                    ),
                  );
                } catch (e) {
                  print("Error saat transaksi: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Gagal melakukan transaksi!"),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: Text("Lanjutkan"),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tuanmuda Liquor'),
      ),
      drawer: Drawer(
  child: Container( 
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(widget.username, style: TextStyle(color: Colors.white)),
          accountEmail: null,
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.account_circle, size: 50,
            color: Colors.black,),
          ),
          decoration: BoxDecoration(
            color: Colors.blue, // Warna latar belakang header drawer
          ),
        ),
        ListTile(
          title: Text('Logout', style: TextStyle(color: Colors.black)),
          leading: Icon(Icons.logout, color: Colors.black),
          onTap: logout,
        ),
      ],
    ),
  ),
),

      body: TabBarView(
        controller: _tabController,
        children: [
          // Produk Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: _products.map((product) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(product['nama_produk'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: Rp${product['harga']}',
                            style: TextStyle(fontSize: 16)),
                        Text('Stok: ${product['stok']}',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart, color: Colors.green),
                          onPressed: () => addToTransaction(product),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showProductDialog(
                            id: product['produk_id'],
                            nama: product['nama_produk'],
                            harga: product['harga'],
                            stok: product['stok'],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              showDeleteConfirmation(product['produk_id']),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          PelangganPage(),
          TransaksiPage(),
         
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => showProductDialog(
                  id: null, nama: null, harga: null, stok: null),
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), label: 'Pelanggan'),
           BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Transaksi'),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }

  // Function to show the product dialog (for adding and editing)
  void showProductDialog(
      {required id, required nama, required harga, required stok}) {
    _nameController.text = nama ?? '';
    _hargaController.text = harga != null ? harga.toString() : '';
    _stokController.text = stok != null ? stok.toString() : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
          title: Text(
            id == null ? 'Tambah Produk' : 'Edit Produk',
            style: TextStyle(color: Colors.blueGrey[900]),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              TextField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              TextField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey, // Background gray
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                minimumSize: Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Tombol Simpan / Perbarui
            TextButton(
              onPressed: () {
                if (id == null) {
                  addProduct();
                } else {
                  updateProduct(id, nama!, harga!, stok!);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Background blue
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                minimumSize: Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                id == null ? 'Tambah' : 'Perbarui',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}
