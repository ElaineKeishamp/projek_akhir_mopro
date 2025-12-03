import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/image_helper.dart';
import '../../widgets/snackbar_helper.dart';
import '../product/product_detail_page.dart';
import '../product/add_product_page.dart';
import '../product/wishlist_page.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  final UserData user;
  final List<CartItem> cart;
  const HomePage({super.key, required this.user, required this.cart});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _p = [];
  List<Product> _show = [];
  bool _load = true;

  @override
  void initState() {
    super.initState();
    _ref();
  }

  void _ref() async {
    var d = await FirebaseService.getProducts();
    setState(() {
      _p = d;
      _show = d;
      _load = false;
    });
  }

  void _search(String q) => setState(() => _show = q.isEmpty
      ? _p
      : _p.where((x) => x.nama.toLowerCase().contains(q.toLowerCase())).toList());

  void _filter(String c) => setState(
      () => _show = c == 'all' ? _p : _p.where((x) => x.kategori == c).toList());

  void _add(Product p) {
    if (p.stok <= 0) {
      showErrorSnackbar(context, "Stok ${p.nama} habis!");
      return;
    }
    
    setState(() {
      int idx = widget.cart.indexWhere((c) => c.id == p.id);
      if (idx != -1) {
        if (widget.cart[idx].qty < p.stok) {
          widget.cart[idx].qty++;
        } else {
          showErrorSnackbar(context, "Stok tidak cukup!");
          return;
        }
      } else {
        widget.cart.add(CartItem(
            id: p.id,
            nama: p.nama,
            img: p.img,
            harga: p.harga,
            maxStok: p.stok));
      }
    });
    showSuccessSnackbar(context, "${p.nama} added");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 160,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF1565C0)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.school,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "CampusStore",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Halo, ${widget.user.fullname.split(' ')[0]}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NotificationPage(user: widget.user),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WishlistPage(user: widget.user),
                                  ),
                                );
                              },
                            ),
                            CircleAvatar(
                              backgroundImage: getDynamicImage(widget.user.img),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: _search,
                        decoration: const InputDecoration(
                          hintText: "Cari barang...",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: primaryColor),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _load
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15),
                      children: [
                        _banner([primaryColor, secondaryColor],
                            "Diskon Mahasiswa", "Kode: MHS2024", Icons.school),
                        _banner([Colors.orange, Colors.redAccent],
                            "Gratis Ongkir", "Min. Blj 50rb", Icons.local_shipping),
                        _banner([Colors.purple, Colors.deepPurpleAccent],
                            "Flash Sale", "Up to 30% Off", Icons.flash_on),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      children: ["all", "Elektronik", "Pakaian", "Buku"]
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(c),
                                  selected: false,
                                  onSelected: (_) => _filter(c),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  GridView.builder(
                    padding: const EdgeInsets.all(15),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.60,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: _show.length,
                    itemBuilder: (c, i) {
                      final p = _show[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              product: p,
                              onAdd: _add,
                              user: widget.user,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: Hero(
                                        tag: p.id,
                                        child: Image(
                                          image: getDynamicImage(p.img),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                              Container(color: Colors.grey[200]),
                                        ),
                                      ),
                                    ),
                                    if (widget.user.role == 'penjual')
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.white,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 16),
                                            onPressed: () async {
                                              if (await FirebaseService
                                                  .deleteProduct(p.id)) _ref();
                                            },
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      formatRupiah(p.harga),
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          p.stok > 0 ? "Stok: ${p.stok}" : "Stok Habis",
                                          style: TextStyle(
                                              fontSize: 10, 
                                              color: p.stok > 0 ? Colors.grey : Colors.red,
                                              fontWeight: p.stok > 0 ? FontWeight.normal : FontWeight.bold),
                                        ),
                                        if (widget.user.role != 'penjual')
                                          InkWell(
                                            onTap: p.stok > 0 ? () => _add(p) : null,
                                            child: Icon(
                                              Icons.add_circle,
                                              color: p.stok > 0 ? primaryColor : Colors.grey,
                                            ),
                                          )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
      ),
      floatingActionButton: widget.user.role == 'penjual'
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductPage(user: widget.user),
                ),
              ).then((_) => _ref()),
              backgroundColor: secondaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _banner(List<Color> c, String t, String s, IconData i) => Container(
        width: 300,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: c),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: c[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
            Icon(i, size: 60, color: Colors.white30)
          ],
        ),
      );
}
