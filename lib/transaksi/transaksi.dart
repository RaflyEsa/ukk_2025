import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _transaksiList.isEmpty
          ? Center(child: Text("Belum ada transaksi", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _transaksiList.length,
              itemBuilder: (context, index) {
                final transaksi = _transaksiList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("Produk: ${transaksi['produk']['nama_produk']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Harga: Rp${transaksi['produk']['harga']}"),
                        Text("Jumlah: ${transaksi['jumlah']}"),
                        Text("Total Harga: Rp${transaksi['total_harga']}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        Text("Tanggal: ${transaksi['tanggal']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
