import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  final int pelangganId;
  final List<Map<String, dynamic>> keranjang;

  const TransaksiPage({
    Key? key,
    required this.pelangganId,
    required this.keranjang,
  }) : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<Map<String, dynamic>> _transaksiList = [];
  get supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
  }

  Future<void> fetchTransaksi() async {
    try {
      final response = await supabase
          .from('transaksi')
          .select('transaksi_id, produk(nama_produk, harga), jumlah, total_harga, tanggal')
          .order('tanggal', ascending: false);

      setState(() {
        _transaksiList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching transaksi: $e');
    }
  }

  Future<void> simpanTransaksi(int pelangganId, List<Map<String, dynamic>> keranjang) async {
  if (keranjang.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Keranjang masih kosong!'), backgroundColor: Colors.orange),
    );
    return;
  }

  try {
    double totalHarga = keranjang.fold(0, (sum, item) => sum + (item['harga'] * item['jumlah']));

    // Simpan transaksi ke tabel 'penjualan'
    final response = await supabase
        .from('penjualan')
        .insert({
          'tanggal_penjualan': DateTime.now().toIso8601String(),
          'total_harga': totalHarga,
          'pelanggan_id': pelangganId
        })
        .select()
        .single();

    int penjualanId = response['penjualan_id'];

    // Simpan detail transaksi ke tabel 'detailpenjualan'
    for (var item in keranjang) {
      await supabase.from('detailpenjualan').insert({
        'penjualan_id': penjualanId,
        'produk_id': item['produk_id'],
        'jumlah_produk': item['jumlah'],
        'subtotal': item['harga'] * item['jumlah']
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaksi berhasil disimpan!'), backgroundColor: Colors.green),
    );

    fetchTransaksi(); // Refresh daftar transaksi
  } catch (e) {
    print('Error menyimpan transaksi: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menyimpan transaksi!'), backgroundColor: Colors.red),
    );
  }
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Konfirmasi Transaksi')),
    body: _transaksiList.isEmpty
        ? Center(child: Text("Belum ada transaksi", style: TextStyle(fontSize: 18)))
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: widget.keranjang.length,
            itemBuilder: (context, index) {
              final item = widget.keranjang[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text("Produk: ${item['nama_produk']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Harga: Rp${item['harga']}"),
                      Text("Jumlah: ${item['jumlah']}"),
                      Text("Subtotal: Rp${item['harga'] * item['jumlah']}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              );
            },
          ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => simpanTransaksi(widget.pelangganId, widget.keranjang),
      label: Text('Bayar Sekarang'),
      icon: Icon(Icons.payment),
      backgroundColor: Colors.green,
    ),
  );
}
}