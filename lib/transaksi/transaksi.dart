import 'package:flutter/material.dart';

class TransaksiPage extends StatefulWidget {
  final Map<String, dynamic>? selectedProduct;
  final int? jumlahDibeli;

  const TransaksiPage({super.key, this.selectedProduct, this.jumlahDibeli});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}


class _TransaksiPageState extends State<TransaksiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: widget.selectedProduct != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Produk: ${widget.selectedProduct!['nama_produk']}", style: TextStyle(fontSize: 18)),
                  Text("Harga: Rp${widget.selectedProduct!['harga']}", style: TextStyle(fontSize: 18)),
                  Text("Stok Tersisa: ${widget.selectedProduct!['stok'] - widget.jumlahDibeli!}", style: TextStyle(fontSize: 18, color: Colors.red)),
                  Text("Jumlah Dibeli: ${widget.jumlahDibeli}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text("Total Harga: Rp${widget.selectedProduct!['harga'] * widget.jumlahDibeli!}", style: TextStyle(fontSize: 18, color: Colors.green)),
                ],
              )
            : Center(child: Text("Belum ada produk yang dipilih", style: TextStyle(fontSize: 18))),
      ),
    );
  }
}

