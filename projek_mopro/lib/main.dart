import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ==================================================================
// 1. KONFIGURASI (GANTI IP DI SINI)
// ==================================================================
const String myIpAddress = '10.157.88.53'; // <--- IP LAPTOP ANDA
const String apiBaseURL = 'http://$myIpAddress/campus_api';

void main() {
  runApp(const CampusStoreApp());
}

// ==================================================================
// 2. TEMA & WARNA MODERN
// ==================================================================
const Color primaryColor = Color(0xFF4E73DF);
const Color secondaryColor = Color(0xFF36B9CC);
const Color accentColor = Color(0xFFF6C23E);
const Color dangerColor = Color(0xFFE74A3B);
const Color successColor = Color(0xFF1CC88A);
const Color surfaceColor = Color(0xFFFFFFFF);
const Color backgroundColor = Color(0xFFF8F9FC);
const Color textDark = Color(0xFF5A5C69);
const Color textLight = Color(0xFF858796);

TextStyle get titleStyle => const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: textDark);
TextStyle get subTitleStyle => const TextStyle(fontFamily: 'Inter', color: textLight);

// ==================================================================
// 3. MODELS
// ==================================================================
class Product {
  final int id; final String nama; final String kategori; final int harga; int stok; final String img;
  final String deskripsi; final double rating; final int jumlahRating; final String sellerName;
  Product({required this.id, required this.nama, required this.kategori, required this.harga, required this.stok, required this.img, this.deskripsi='', this.rating=0.0, this.jumlahRating=0, this.sellerName='Official'});
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()), nama: json['nama'], kategori: json['kategori'],
      harga: int.parse(json['harga'].toString()), stok: int.parse(json['stok'].toString()), img: json['img'],
      deskripsi: json['deskripsi'] ?? '', rating: double.tryParse(json['avg_rating']?.toString() ?? '0.0') ?? 0.0, 
      jumlahRating: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0, sellerName: json['seller_name'] ?? 'Campus Official'
    );
  }
}

class UserData {
  final int id; final String username; final String fullname; final String role; final String nim; final String img;
  UserData({required this.id, required this.username, required this.fullname, required this.role, required this.nim, required this.img});
  factory UserData.fromMap(Map<String, dynamic> map) => UserData(
    id: int.tryParse(map['id'].toString()) ?? 0, username: map['username'], fullname: map['fullname'], role: map['role'], nim: map['nim'], img: map['img']);
}

class UserList {
  final int id; final String username; final String role; final String fullname; final String nim; final String img;
  UserList({required this.id, required this.username, required this.role, required this.fullname, required this.nim, required this.img});
  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
    id: int.parse(json['id'].toString()), username: json['username'], fullname: json['fullname'] ?? 'User', 
    role: json['role'], nim: json['nim'] ?? '-', img: json['img'] ?? 'images/profile_default.jpg'
  );
}

class OrderModel {
  final int id; final String status; final int total; final String date; final List<dynamic> items; final String? buyerName; final String address; final String payment;
  OrderModel({required this.id, required this.status, required this.total, required this.date, required this.items, this.buyerName, this.address='', this.payment=''});
  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: int.parse(json['id'].toString()), status: json['status'], total: int.parse(json['total_price'].toString()),
    date: json['order_date'], items: json['items'] ?? [], buyerName: json['fullname'],
    address: json['shipping_address'] ?? '-', payment: json['payment_method'] ?? 'COD'
  );
}

class CartItem {
  final int id; final String nama; final String img; final int harga; int qty; final int maxStok;
  CartItem({required this.id, required this.nama, required this.img, required this.harga, required this.maxStok, this.qty = 1});
  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'harga': harga, 'qty': qty, 'img': img};
}

// ==================================================================
// 4. API SERVICE
// ==================================================================
class API {
  static Future<Map<String, dynamic>> login(String u, String p) async {
    try {
      final res = await http.post(Uri.parse('$apiBaseURL/login.php'), body: {'username': u, 'password': p});
      return json.decode(res.body);
    } catch (e) { return {"status": "error", "message": "Koneksi Gagal"}; }
  }
  static Future<Map<String, dynamic>> register(String u, String p, String r, String f, String n, File? i) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse('$apiBaseURL/register.php'));
      req.fields.addAll({'username': u, 'password': p, 'role': r, 'fullname': f, 'nim': n});
      if (i != null) req.files.add(await http.MultipartFile.fromPath('image', i.path));
      var res = await http.Response.fromStream(await req.send());
      return json.decode(res.body);
    } catch (e) { return {"status": "error"}; }
  }
  static Future<Map<String, dynamic>> updateProfile(String oldUser, String f, String n, File? i) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse('$apiBaseURL/update_profile.php'));
      req.fields.addAll({'old_username': oldUser, 'fullname': f, 'nim': n});
      if (i != null) req.files.add(await http.MultipartFile.fromPath('image', i.path));
      var res = await http.Response.fromStream(await req.send());
      return json.decode(res.body);
    } catch (e) { return {"status": "error", "message": e.toString()}; }
  }
  static Future<List<Product>> getProducts() async {
    try {
      final res = await http.get(Uri.parse('$apiBaseURL/get_produk.php'));
      if (res.statusCode == 200) return (json.decode(res.body) as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) { print(e); }
    return [];
  }
  static Future<bool> addProduct(String n, String k, String h, String s, String d, File? i, int sId, String sName) async {
    var req = http.MultipartRequest('POST', Uri.parse('$apiBaseURL/add_produk.php'));
    req.fields.addAll({'nama': n, 'kategori': k, 'harga': h, 'stok': s, 'deskripsi': d, 'seller_id': sId.toString(), 'seller_name': sName});
    if (i != null) req.files.add(await http.MultipartFile.fromPath('image', i.path));
    else req.fields['img_manual'] = "images/macbook_m2.jpg";
    var res = await http.Response.fromStream(await req.send());
    return json.decode(res.body)['status'] == 'success';
  }
  static Future<bool> deleteProduct(int id) async {
    final res = await http.post(Uri.parse('$apiBaseURL/delete_produk.php'), body: {'id': id.toString()});
    return json.decode(res.body)['status'] == 'success';
  }
  
  // MODIFIKASI CREATE ORDER: Mengembalikan String Pesan (Bukan Boolean)
  static Future<String> createOrder(int userId, int total, List<CartItem> items, String addr, String pay, String promo) async {
    try {
      String itemsJson = json.encode(items.map((e) => e.toJson()).toList());
      final res = await http.post(Uri.parse('$apiBaseURL/create_order.php'), body: {
        'user_id': userId.toString(), 'total': total.toString(), 'items': itemsJson, 'address': addr, 'payment': pay, 'promo': promo
      });
      
      print("Response Create Order: ${res.body}"); // DEBUG

      var data = json.decode(res.body);
      if(data['status'] == 'success') return "OK";
      return data['message'] ?? "Gagal Server";
    } catch (e) {
      return "Error Koneksi: $e";
    }
  }

  static Future<List<OrderModel>> getOrders({int? userId}) async {
    String url = '$apiBaseURL/get_orders.php';
    if(userId != null) url += '?user_id=$userId';
    try {
      final res = await http.get(Uri.parse(url));
      if(res.statusCode == 200) return (json.decode(res.body) as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch(e){ print("Error Get Orders: $e"); }
    return [];
  }
  static Future<bool> updateOrderStatus(int orderId, String status) async {
    final res = await http.post(Uri.parse('$apiBaseURL/update_status.php'), body: {'order_id': orderId.toString(), 'status': status});
    return json.decode(res.body)['status'] == 'success';
  }
  static Future<List<UserList>> getUsers() async {
    try {
      final res = await http.get(Uri.parse('$apiBaseURL/get_users.php'));
      if (res.statusCode == 200) return (json.decode(res.body) as List).map((e) => UserList.fromJson(e)).toList();
    } catch (e) { print("Error: $e"); }
    return [];
  }
  static Future<bool> deleteUser(int id) async {
    final res = await http.post(Uri.parse('$apiBaseURL/delete_user.php'), body: {'id': id.toString()});
    return json.decode(res.body)['status'] == 'success';
  }
  static Future<bool> addReview(int pid, int uid, String user, double rating, String comment) async {
    final res = await http.post(Uri.parse('$apiBaseURL/add_review.php'), body: {
      'product_id': pid.toString(), 'user_id': uid.toString(), 'username': user, 'rating': rating.toString(), 'comment': comment
    });
    return json.decode(res.body)['status'] == 'success';
  }
}

String formatRupiah(int amount) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
ImageProvider getDynamicImage(String path) {
  if (path.contains('uploads/')) return NetworkImage('$apiBaseURL/$path');
  return AssetImage(path) as ImageProvider;
}

// --- HELPER WIDGETS ---
class ModernTextField extends StatelessWidget {
  final TextEditingController controller; final String label; final IconData icon; final bool isPassword; final int maxLines; final TextInputType type;
  const ModernTextField({super.key, required this.controller, required this.label, required this.icon, this.isPassword = false, this.maxLines = 1, this.type = TextInputType.text});
  @override Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: TextField(controller: controller, obscureText: isPassword, maxLines: maxLines, keyboardType: type, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: primaryColor), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15))),
    );
  }
}
void showSuccessSnackbar(BuildContext ctx, String m) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text(m))]), backgroundColor: successColor, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
void showErrorSnackbar(BuildContext ctx, String m) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.error, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text(m))]), backgroundColor: dangerColor, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
void showConfirmDialog(BuildContext ctx, String t, String c, VoidCallback ok) {
  showDialog(context: ctx, builder: (x) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), content: Text(c), actions: [TextButton(onPressed: ()=>Navigator.pop(x), child: const Text("Batal", style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: dangerColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: (){ Navigator.pop(x); ok(); }, child: const Text("Ya"))]));
}
Widget buildStarRating(double r, {double size = 16}) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(i < r.floor() ? Icons.star : (i < r ? Icons.star_half : Icons.star_outline), size: size, color: Colors.amber)));

// ==================================================================
// 5. MAIN APP
// ==================================================================
class CampusStoreApp extends StatelessWidget {
  const CampusStoreApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusStore Pro', debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primaryColor: primaryColor, scaffoldBackgroundColor: backgroundColor, fontFamily: 'Inter', colorScheme: ColorScheme.fromSwatch().copyWith(primary: primaryColor, secondary: secondaryColor)),
      home: const LoginPage(),
    );
  }
}

// ==================================================================
// 6. AUTH PAGES
// ==================================================================
class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _L(); }
class _L extends State<LoginPage> {
  final _u=TextEditingController(); final _p=TextEditingController(); bool _l=false;
  void _do() async {
    if(_u.text.isEmpty||_p.text.isEmpty) {showErrorSnackbar(context,"Data tidak lengkap");return;}
    setState(()=>_l=true); final res = await API.login(_u.text, _p.text); setState(()=>_l=false);
    if(res['status']=='success'){ UserData u = UserData.fromMap(res); if(u.role=='admin') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const AdminDashboard())); else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainPage(user: u))); } else showErrorSnackbar(context, res['message']);
  }
  @override Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [
      Container(height: 300, decoration: const BoxDecoration(gradient: LinearGradient(colors: [primaryColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)))),
      Center(child: SingleChildScrollView(padding: const EdgeInsets.all(30), child: Card(elevation: 10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), child: Padding(padding: const EdgeInsets.all(40), child: Column(children: [
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.school, size: 50, color: primaryColor)),
        const SizedBox(height: 15), Text("CampusStore", style: titleStyle.copyWith(fontSize: 26, color: primaryColor)), const Text("Login to continue", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40), ModernTextField(controller: _u, label: "Username", icon: Icons.person), const SizedBox(height: 20), ModernTextField(controller: _p, label: "Password", icon: Icons.lock, isPassword: true),
        const SizedBox(height: 30), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _l?null:_do, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _l?const CircularProgressIndicator(color: Colors.white):const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
        const SizedBox(height: 20), TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const RegisterPage())), child: const Text("Belum punya akun? Daftar", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)))
      ])))))
    ]));
  }
}

class RegisterPage extends StatefulWidget { const RegisterPage({super.key}); @override State<RegisterPage> createState() => _R(); }
class _R extends State<RegisterPage> {
  final _u=TextEditingController(); final _p=TextEditingController(); final _f=TextEditingController(); final _n=TextEditingController();
  String _r='customer'; File? _i; bool _l=false; final ImagePicker _pk=ImagePicker();
  Future _pic() async { final x=await _pk.pickImage(source: ImageSource.gallery); if(x!=null)setState(()=>_i=File(x.path)); }
  void _reg() async {
    if(_u.text.isEmpty) return; setState(()=>_l=true);
    final res=await API.register(_u.text, _p.text, _r, _f.text, _n.text, _i); setState(()=>_l=false);
    if(res['status']=='success') { showSuccessSnackbar(context, "Berhasil!"); Navigator.pop(context); } else showErrorSnackbar(context, res['message']);
  }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text("Buat Akun"), backgroundColor: Colors.white, foregroundColor: textDark, elevation: 0), body: SingleChildScrollView(padding: const EdgeInsets.all(30), child: Column(children: [
      GestureDetector(onTap: _pic, child: CircleAvatar(radius: 50, backgroundColor: backgroundColor, backgroundImage: _i!=null?FileImage(_i!):null, child: _i==null?const Icon(Icons.camera_alt, size: 30, color: textLight):null)),
      const SizedBox(height: 10), const Text("Upload Foto", style: TextStyle(color: textLight)), const SizedBox(height: 30),
      ModernTextField(controller: _u, label: "Username", icon: Icons.alternate_email), const SizedBox(height: 15), ModernTextField(controller: _p, label: "Password", icon: Icons.lock_outline, isPassword: true), const SizedBox(height: 15),
      ModernTextField(controller: _f, label: "Nama Lengkap", icon: Icons.badge_outlined), const SizedBox(height: 15), ModernTextField(controller: _n, label: "NIM (Opsional)", icon: Icons.numbers), const SizedBox(height: 15),
      Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _r, isExpanded: true, items: const [DropdownMenuItem(value: 'customer', child: Text("Customer")), DropdownMenuItem(value: 'penjual', child: Text("Penjual"))], onChanged: (v)=>setState(()=>_r=v.toString())))),
      const SizedBox(height: 40), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _l?null:_reg, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _l?const CircularProgressIndicator(color: Colors.white):const Text("DAFTAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))))
    ])));
  }
}

// ==================================================================
// 7. MAIN PAGE CONTROLLER
// ==================================================================
class MainPage extends StatefulWidget { final UserData user; const MainPage({super.key, required this.user}); @override State<MainPage> createState()=>_MP(); }
class _MP extends State<MainPage> {
  int _idx=0; late UserData _currentUser;
  List<CartItem> globalCart = [];
  @override void initState() { super.initState(); _currentUser = widget.user; }
  void _updateUser(UserData newUser) { setState(() => _currentUser = newUser); }
  @override Widget build(BuildContext context) {
    List<Widget> pages = [HomePage(user: _currentUser, cart: globalCart), CartPage(user: _currentUser, cart: globalCart), OrdersPage(user: _currentUser), ProfilePage(user: _currentUser, onUpdateProfile: _updateUser)];
    return Scaffold(body: pages[_idx], bottomNavigationBar: NavigationBar(selectedIndex: _idx, onDestinationSelected: (i)=>setState(()=>_idx=i), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: "Home"), NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: "Cart"), NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: "Orders"), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "Profile")]));
  }
}

// ==================================================================
// 8. HOME PAGE (FIXED)
// ==================================================================
class HomePage extends StatefulWidget { final UserData user; final List<CartItem> cart; const HomePage({super.key, required this.user, required this.cart}); @override State<HomePage> createState()=>_HP(); }
class _HP extends State<HomePage> {
  List<Product> _p=[]; List<Product> _show=[]; bool _load=true;
  @override void initState() { super.initState(); _ref(); }
  void _ref() async { var d=await API.getProducts(); setState((){ _p=d; _show=d; _load=false; }); }
  void _search(String q) => setState(()=>_show = q.isEmpty ? _p : _p.where((x)=>x.nama.toLowerCase().contains(q.toLowerCase())).toList());
  void _filter(String c) => setState(()=>_show = c=='all' ? _p : _p.where((x)=>x.kategori==c).toList());
  void _add(Product p) { setState(() { int idx = widget.cart.indexWhere((c)=>c.id==p.id); if(idx!=-1){ if(widget.cart[idx].qty<p.stok) widget.cart[idx].qty++; } else { widget.cart.add(CartItem(id: p.id, nama: p.nama, img: p.img, harga: p.harga, maxStok: p.stok)); }}); showSuccessSnackbar(context, "${p.nama} added"); }
  
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(floating: true, pinned: true, expandedHeight: 160, backgroundColor: primaryColor, flexibleSpace: FlexibleSpaceBar(background: Container(padding: const EdgeInsets.fromLTRB(20, 50, 20, 0), decoration: const BoxDecoration(gradient: LinearGradient(colors: [primaryColor, Color(0xFF1565C0)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.school, color: Colors.white, size: 28)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("CampusStore", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text("Halo, ${widget.user.fullname.split(' ')[0]}", style: const TextStyle(color: Colors.white70, fontSize: 13))])]), CircleAvatar(backgroundImage: getDynamicImage(widget.user.img))]), const SizedBox(height: 15), Container(height: 45, padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: TextField(onChanged: _search, decoration: const InputDecoration(hintText: "Cari barang...", border: InputBorder.none, icon: Icon(Icons.search, color: primaryColor))))])))),
        ],
        body: _load ? const Center(child: CircularProgressIndicator()) : ListView(children: [
            SizedBox(height: 180, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(15), children: [
              _banner([primaryColor, secondaryColor], "Diskon Mahasiswa", "Kode: MHS2024", Icons.school),
              _banner([Colors.orange, Colors.redAccent], "Gratis Ongkir", "Min. Blj 50rb", Icons.local_shipping),
              _banner([Colors.purple, Colors.deepPurpleAccent], "Flash Sale", "Up to 30% Off", Icons.flash_on),
            ])),
            SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15), children: ["all","Elektronik","Pakaian","Buku"].map((c)=>Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c), selected: false, onSelected: (_)=>_filter(c)))).toList())),
            GridView.builder(padding: const EdgeInsets.all(15), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.60, crossAxisSpacing: 15, mainAxisSpacing: 15), itemCount: _show.length, itemBuilder: (c, i) {
              final p = _show[i];
              return GestureDetector(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ProductDetailPage(product: p, onAdd: _add, user: widget.user))), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Stack(children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Hero(tag: p.id, child: Image(image: getDynamicImage(p.img), width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s)=>Container(color: Colors.grey[200])))), if(widget.user.role=='penjual') Positioned(top:5,right:5,child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.delete, color: Colors.red, size: 16), onPressed: () async {if(await API.deleteProduct(p.id)) _ref();})))])),
                Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text(formatRupiah(p.harga), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Stok: ${p.stok}", style: const TextStyle(fontSize: 10, color: Colors.grey)), if(widget.user.role!='penjual') InkWell(onTap: ()=>_add(p), child: const Icon(Icons.add_circle, color: primaryColor))])]))
              ])));
            })
          ]),
      ),
      floatingActionButton: widget.user.role=='penjual' ? FloatingActionButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>AddProductPage(user: widget.user))).then((_)=>_ref()), backgroundColor: secondaryColor, child: const Icon(Icons.add)) : null,
    );
  }
  Widget _banner(List<Color> c, String t, String s, IconData i) => Container(width: 300, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: c), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: c[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0,5))]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)), child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)))])), Icon(i, size: 60, color: Colors.white30)]));
}

// ==================================================================
// 9. CART PAGE (CHECKOUT DIALOG)
// ==================================================================
class CartPage extends StatefulWidget { final UserData user; final List<CartItem> cart; const CartPage({super.key, required this.user, required this.cart}); @override State<CartPage> createState() => _CP(); }
class _CP extends State<CartPage> {
  void _showCheckoutDialog() {
    if(widget.cart.isEmpty) return;
    final addr = TextEditingController(); final promo = TextEditingController(); String pay = 'COD';
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Checkout Confirmation", style: titleStyle.copyWith(fontSize: 20)), const SizedBox(height: 20),
      ModernTextField(controller: addr, label: "Shipping Address", icon: Icons.map), const SizedBox(height: 10),
      DropdownButtonFormField(value: pay, items: ['COD','E-Wallet','Bank Transfer'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>pay=v.toString(), decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), labelText: "Payment Method")), const SizedBox(height: 10),
      ModernTextField(controller: promo, label: "Promo Code", icon: Icons.discount), const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryColor), onPressed: () async {
        int t = widget.cart.fold(0, (s, i) => s + (i.harga * i.qty));
        if(promo.text == "MHS2024") t = (t * 0.9).toInt();
        // PANGGIL API.createOrder (YANG MENGEMBALIKAN STRING)
        String result = await API.createOrder(widget.user.id, t, widget.cart, addr.text, pay, promo.text);
        if(result == "OK") { 
          setState(()=>widget.cart.clear()); 
          Navigator.pop(ctx); 
          showSuccessSnackbar(context, "Order Success!"); 
        } else { 
          Navigator.pop(ctx); 
          showErrorSnackbar(context, "Gagal: $result"); // Tampilkan pesan error asli
        }
      }, child: const Text("PLACE ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 20)
    ])));
  }
  @override Widget build(BuildContext context) {
    int t = widget.cart.fold(0, (s, i) => s + (i.harga * i.qty));
    return Scaffold(appBar: AppBar(title: const Text("Keranjang")), body: widget.cart.isEmpty ? const Center(child: Text("Keranjang Kosong")) : ListView.builder(itemCount: widget.cart.length, itemBuilder: (c,i)=>Card(margin: const EdgeInsets.all(10), child: ListTile(leading: Image(image: getDynamicImage(widget.cart[i].img), width: 50, fit: BoxFit.cover), title: Text(widget.cart[i].nama), subtitle: Text(formatRupiah(widget.cart[i].harga)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.remove_circle), onPressed: ()=>setState((){if(widget.cart[i].qty>1)widget.cart[i].qty--;else widget.cart.removeAt(i);})), Text("${widget.cart[i].qty}"), IconButton(icon: const Icon(Icons.add_circle), onPressed: ()=>setState((){if(widget.cart[i].qty<widget.cart[i].maxStok)widget.cart[i].qty++;}))])))), bottomNavigationBar: widget.cart.isNotEmpty ? Container(padding: const EdgeInsets.all(20), color: Colors.white, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total: ${formatRupiah(t)}", style: const TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: _showCheckoutDialog, child: const Text("CHECKOUT"))])) : null);
  }
}

// ==================================================================
// 10. ORDERS PAGE (TRACKING & REVIEW)
// ==================================================================
class OrdersPage extends StatefulWidget { final UserData user; const OrdersPage({super.key, required this.user}); @override State<OrdersPage> createState()=>_OP(); }
class _OP extends State<OrdersPage> {
  List<OrderModel> _o=[]; bool _l=true; @override void initState(){super.initState(); _load();}
  void _load() async { var d=await API.getOrders(userId: widget.user.id); setState((){_o=d;_l=false;}); }
  Color _c(String s) {switch(s){case 'pending':return Colors.orange; case 'packed':return Colors.blue; case 'shipped':return Colors.purple; case 'delivered':return successColor; default: return Colors.grey;}}
  void _review(int pid) {
    showDialog(context: context, builder: (ctx) {
      double _r = 5.0; final _cmt = TextEditingController();
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(title: const Text("Beri Ulasan"), content: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Rating:"), Slider(value: _r, min: 1, max: 5, divisions: 4, label: "$_r", onChanged: (v)=>setDialogState(()=>_r=v)), TextField(controller: _cmt, decoration: const InputDecoration(labelText: "Komentar"))]), actions: [ElevatedButton(onPressed: () async { await API.addReview(pid, widget.user.id, widget.user.username, _r, _cmt.text); Navigator.pop(ctx); showSuccessSnackbar(context, "Ulasan Terkirim!"); }, child: const Text("Kirim"))]);
      });
    });
  }
  Widget _step(String s) { List<String> st=['pending','packed','shipped','delivered']; int idx=st.indexOf(s); return Row(children: st.asMap().entries.map((e) => Expanded(child: Column(children: [Icon(Icons.check_circle, color: e.key<=idx?_c(s):Colors.grey[300]), Text(e.value, style: const TextStyle(fontSize: 10))]))).toList()); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Lacak Pesanan"), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]), body: _l?const Center(child: CircularProgressIndicator()):ListView.builder(padding: const EdgeInsets.all(15), itemCount: _o.length, itemBuilder: (c,i){
      final o=_o[i]; return Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Order #${o.id} - ${o.date}", style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), _step(o.status), const Divider(), ...o.items.map((x)=>ListTile(title: Text(x['product_name']), subtitle: Text("${x['quantity']}x"), trailing: o.status=='delivered'?TextButton(onPressed: ()=>_review(int.parse(x['product_id'])), child: const Text("Review")):null)), const SizedBox(height: 5), Text("Total: ${formatRupiah(o.total)}", style: TextStyle(color: _c(o.status), fontWeight: FontWeight.bold))])));
    }));
  }
}

// ==================================================================
// 11. PROFILE PAGE (MEWAH)
// ==================================================================
class ProfilePage extends StatelessWidget { final UserData user; final Function(UserData) onUpdateProfile; const ProfilePage({super.key, required this.user, required this.onUpdateProfile}); @override Widget build(BuildContext context) {
  return Scaffold(body: SingleChildScrollView(child: Column(children: [
    Container(padding: const EdgeInsets.fromLTRB(20, 60, 20, 30), decoration: const BoxDecoration(gradient: LinearGradient(colors: [primaryColor, Color(0xFF1565C0)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))), child: Row(children: [
      CircleAvatar(radius: 40, backgroundImage: getDynamicImage(user.img), backgroundColor: Colors.white), const SizedBox(width: 15),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.fullname, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(user.role.toUpperCase(), style: const TextStyle(color: secondaryColor, fontWeight: FontWeight.bold))])
    ])),
    const SizedBox(height: 20), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_walletItem(Icons.account_balance_wallet, "Rp 150.000", "Saldo"), Container(width: 1, height: 40, color: Colors.grey[300]), _walletItem(Icons.stars, "2.400", "Koin")]))),
    const SizedBox(height: 20), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Pesanan Saya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 10), Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_ico(Icons.payment, "Belum Bayar"), _ico(Icons.inventory_2, "Dikemas"), _ico(Icons.local_shipping, "Dikirim"), _ico(Icons.star, "Beri Nilai")])))])) ,
    const SizedBox(height: 20),
    _tile(Icons.person, "Edit Profil", () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage(user: user)));
        if (result != null && result is UserData) { onUpdateProfile(result); } 
    }),
    _tile(Icons.map, "Alamat Pengiriman", (){}), _tile(Icons.settings, "Pengaturan Akun", (){}), _tile(Icons.help, "Pusat Bantuan", (){}), _tile(Icons.logout, "Keluar", () => showConfirmDialog(context, "Logout", "Keluar?", ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginPage()))), isRed: true),
  ])));
}
  Widget _walletItem(IconData i, String v, String l) => Column(children: [Row(children: [Icon(i, color: primaryColor, size: 18), const SizedBox(width: 5), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]), Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey))]);
  Widget _ico(IconData i, String l) => Column(children: [Icon(i, color: primaryColor), const SizedBox(height: 5), Text(l, style: const TextStyle(fontSize: 10))]);
  Widget _tile(IconData i, String t, VoidCallback tap, {bool isRed=false}) => ListTile(leading: Icon(i, color: isRed?Colors.red:textDark), title: Text(t, style: TextStyle(color: isRed?Colors.red:textDark)), trailing: const Icon(Icons.chevron_right), onTap: tap);
}

class EditProfilePage extends StatefulWidget { final UserData user; const EditProfilePage({super.key, required this.user}); @override State<EditProfilePage> createState()=>_EPP(); }
class _EPP extends State<EditProfilePage> {
  late TextEditingController _f, _n; File? _i; final ImagePicker _p=ImagePicker();
  @override void initState(){super.initState(); _f=TextEditingController(text: widget.user.fullname); _n=TextEditingController(text: widget.user.nim);}
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Edit Profil")), body: ListView(padding: const EdgeInsets.all(20), children: [
      GestureDetector(onTap: () async { final x=await _p.pickImage(source: ImageSource.gallery); if(x!=null)setState(()=>_i=File(x.path)); }, child: CircleAvatar(radius: 50, backgroundImage: _i!=null?FileImage(_i!):getDynamicImage(widget.user.img))),
      const SizedBox(height: 20), ModernTextField(controller: _f, label: "Nama Lengkap", icon: Icons.badge), const SizedBox(height: 10), ModernTextField(controller: _n, label: "NIM", icon: Icons.numbers),
      const SizedBox(height: 30), ElevatedButton(onPressed: () async { 
          Map<String, dynamic> res = await API.updateProfile(widget.user.username, _f.text, _n.text, _i);
          if(res['status'] == 'success') { 
             showSuccessSnackbar(context, "Profil Diupdate!");
             UserData updatedUser = UserData(id: widget.user.id, username: widget.user.username, fullname: _f.text, role: widget.user.role, nim: _n.text, img: widget.user.img);
             Navigator.pop(context, updatedUser);
          } 
      }, child: const Text("SIMPAN"))
    ]));
  }
}

// ==================================================================
// 12. ADMIN DASHBOARD
// ==================================================================
class AdminDashboard extends StatefulWidget { const AdminDashboard({super.key}); @override State<AdminDashboard> createState()=>_AD(); }
class _AD extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tc; @override void initState(){super.initState(); _tc=TabController(length: 2, vsync: this);}
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Admin Panel"), bottom: TabBar(controller: _tc, labelColor: primaryColor, tabs: const [Tab(text: "Users"), Tab(text: "Orders")]), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginPage())))]), body: TabBarView(controller: _tc, children: const [AdminUserList(), AdminOrderList()]));
  }
}
class AdminUserList extends StatefulWidget { const AdminUserList({super.key}); @override State<AdminUserList> createState()=>_AUL(); }
class _AUL extends State<AdminUserList> {
  List<UserList> _u=[]; @override void initState(){super.initState();_l();}
  void _l()async{var d=await API.getUsers(); setState(()=>_u=d);}
  @override Widget build(BuildContext context) => ListView.builder(itemCount: _u.length, itemBuilder: (c,i)=>ListTile(leading: CircleAvatar(backgroundImage: getDynamicImage(_u[i].img)), title: Text(_u[i].fullname), subtitle: Text(_u[i].role), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await API.deleteUser(_u[i].id); _l(); })));
}
class AdminOrderList extends StatefulWidget { const AdminOrderList({super.key}); @override State<AdminOrderList> createState()=>_AOL(); }
class _AOL extends State<AdminOrderList> {
  List<OrderModel> _o=[]; @override void initState(){super.initState();_l();}
  void _l()async{var d=await API.getOrders(); setState(()=>_o=d);}
  void _upd(int id, String st) async { await API.updateOrderStatus(id, st); _l(); }
  @override Widget build(BuildContext context) {
    return ListView.builder(itemCount: _o.length, itemBuilder: (c,i) {
      final o = _o[i];
      return Card(margin: const EdgeInsets.all(10), child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Order #${o.id} - ${o.buyerName}", style: const TextStyle(fontWeight: FontWeight.bold)), Text("Total: ${formatRupiah(o.total)}"),
        Row(children: [const Text("Status: "), DropdownButton<String>(value: o.status, items: ['pending','packed','shipped','delivered','cancelled'].map((e)=>DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: (v)=>_upd(o.id, v!))])
      ])));
    });
  }
}

class AddProductPage extends StatefulWidget { final UserData user; const AddProductPage({super.key, required this.user}); @override State<AddProductPage> createState()=>_APP(); }
class _APP extends State<AddProductPage> {
  final _n=TextEditingController(); final _k=TextEditingController(); final _h=TextEditingController(); final _s=TextEditingController(); final _d=TextEditingController();
  File? _i; final ImagePicker _p=ImagePicker();
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Tambah Produk")), body: ListView(padding: const EdgeInsets.all(20), children: [
      GestureDetector(onTap: () async { final x=await _p.pickImage(source: ImageSource.gallery); if(x!=null)setState(()=>_i=File(x.path)); }, child: Container(height: 200, color: Colors.grey[300], child: _i==null?const Icon(Icons.add_a_photo):Image.file(_i!, fit: BoxFit.cover))),
      const SizedBox(height: 10), TextField(controller: _n, decoration: const InputDecoration(labelText: "Nama")), TextField(controller: _k, decoration: const InputDecoration(labelText: "Kategori")),
      TextField(controller: _h, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number), TextField(controller: _s, decoration: const InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
      TextField(controller: _d, decoration: const InputDecoration(labelText: "Deskripsi"), maxLines: 3),
      const SizedBox(height: 20), ElevatedButton(onPressed: () async { if(await API.addProduct(_n.text, _k.text, _h.text, _s.text, _d.text, _i, widget.user.id, widget.user.fullname)) Navigator.pop(context); }, child: const Text("SIMPAN"))
    ]));
  }
}

// ==================================================================
// 13. PRODUCT DETAIL PAGE (FIXED & COMPLETE)
// ==================================================================
class ProductDetailPage extends StatefulWidget { 
  final Product product; final UserData user; final Function(Product) onAdd; 
  const ProductDetailPage({super.key, required this.product, required this.user, required this.onAdd}); 
  @override State<ProductDetailPage> createState() => _PD(); 
}
class _PD extends State<ProductDetailPage> { 
  int qty = 1; 
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 350, pinned: true, backgroundColor: Colors.white, foregroundColor: Colors.black, flexibleSpace: FlexibleSpaceBar(background: Hero(tag: widget.product.id, child: Image(image: getDynamicImage(widget.product.img), fit: BoxFit.cover)))),
        SliverList(delegate: SliverChildListDelegate([
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(formatRupiah(widget.product.harga), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)), Row(children: [const Icon(Icons.star, color: Colors.amber), Text("${widget.product.rating}")])]),
            const SizedBox(height: 10), Text(widget.product.nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20), const Divider(),
            ListTile(leading: const Icon(Icons.store, color: primaryColor), title: Text(widget.product.sellerName), subtitle: const Text("Verified Seller"), trailing: const Icon(Icons.chevron_right)), const Divider(),
            const SizedBox(height: 10), const Text("Deskripsi Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 5),
            Text(widget.product.deskripsi, style: const TextStyle(color: Colors.grey, height: 1.5)),
            const SizedBox(height: 80)
          ]))
        ]))
      ]),
      bottomSheet: Container(padding: const EdgeInsets.all(15), color: Colors.white, child: Row(children: [
        if(widget.user.role!='penjual') ...[
          Container(decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Row(children: [IconButton(icon: const Icon(Icons.remove), onPressed: ()=>setState((){if(qty>1)qty--;})), Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.add), onPressed: ()=>setState((){if(qty<widget.product.stok)qty++;}))])),
          const SizedBox(width: 15), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: (){for(int i=0;i<qty;i++)widget.onAdd(widget.product); Navigator.pop(context);}, child: const Text("BELI SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
        ]
      ])),
    );
  }
}