import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../models/cart_item.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/image_helper.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/snackbar_helper.dart';

class CartPage extends StatefulWidget {
  final UserData user;
  final List<CartItem> cart;
  const CartPage({super.key, required this.user, required this.cart});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _showCheckoutDialog() {
    if (widget.cart.isEmpty) return;
    final addr = TextEditingController();
    final promo = TextEditingController();
    String pay = 'COD';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Checkout Confirmation",
                style: titleStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 20),
            CustomTextField(
              controller: addr,
              label: "Shipping Address",
              icon: Icons.map,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: pay,
              items: ['COD', 'E-Wallet', 'Bank Transfer']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => pay = v.toString(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Payment Method",
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: promo,
              label: "Promo Code",
              icon: Icons.discount,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () async {
                  int t = widget.cart.fold(0, (s, i) => s + (i.harga * i.qty));
                  if (promo.text == "MHS2024") t = (t * 0.9).toInt();
                  String result = await FirebaseService.createOrder(
                    widget.user.id,
                    widget.user.fullname,
                    t,
                    widget.cart,
                    addr.text,
                    pay,
                    promo.text,
                  );
                  if (result == "OK") {
                    setState(() => widget.cart.clear());
                    Navigator.pop(ctx);
                    showSuccessSnackbar(context, "Order Success!");
                  } else {
                    Navigator.pop(ctx);
                    showErrorSnackbar(context, "Gagal: $result");
                  }
                },
                child: const Text(
                  "PLACE ORDER",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int t = widget.cart.fold(0, (s, i) => s + (i.harga * i.qty));
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),
      body: widget.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Keranjang Anda Masih Kosong",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Yuk, mulai belanja kebutuhan kampusmu!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.shopping_bag, color: Colors.white),
                    label: const Text(
                      "Mulai Belanja",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (c, i) => Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image(
                    image: getDynamicImage(widget.cart[i].img),
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(widget.cart[i].nama),
                  subtitle: Text(formatRupiah(widget.cart[i].harga)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => setState(() {
                          if (widget.cart[i].qty > 1) {
                            widget.cart[i].qty--;
                          } else {
                            widget.cart.removeAt(i);
                          }
                        }),
                      ),
                      Text("${widget.cart[i].qty}"),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => setState(() {
                          if (widget.cart[i].qty < widget.cart[i].maxStok) {
                            widget.cart[i].qty++;
                          }
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: widget.cart.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ${formatRupiah(t)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _showCheckoutDialog,
                    child: const Text("CHECKOUT"),
                  )
                ],
              ),
            )
          : null,
    );
  }
}
