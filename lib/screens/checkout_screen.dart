import 'package:flutter/material.dart';
import 'package:mini_shop/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/app/theme.dart';
import 'package:mini_shop/cubits/cart_cubit.dart';
import 'package:mini_shop/cubits/orders_cubit.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/models/order_model.dart';
import 'package:mini_shop/screens/cart_screen.dart';

/// Validates the field is filled in.
String? required(String? v, String what) => (v == null || v.trim().isEmpty) ? 'Please enter your $what' : null;

/// Egyptian-style or international phone numbers: digits, spaces, + and dashes, 8-15 digits.
String? validatePhone(String? v) {
  final digits = (v ?? '').replaceAll(RegExp(r'[\s\-+()]'), '');
  if (digits.isEmpty) return 'Please enter your phone number';
  if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) return 'Enter a valid phone number';
  return null;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const CheckoutScreen());

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  String _payment = 'Cash on delivery';
  bool _placing = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _city, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _place() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _placing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final cart = context.read<CartCubit>();
    final order = context.read<OrdersCubit>().place(
          items: cart.state.items,
          summary: cart.state.summary,
          name: _name.text.trim(),
          address: '${_address.text.trim()}, ${_city.text.trim()}',
          payment: _payment,
        );
    cart.clear();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OrderPlacedScreen(order: order)));
  }

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<CartCubit>().state.summary;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Checkout'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _Step(number: 1, title: context.t('Delivery details')),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(labelText: context.t('Full name'), prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => required(v, 'name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.streetAddressLine1],
              decoration: InputDecoration(labelText: context.t('Street address'), prefixIcon: Icon(Icons.home_outlined)),
              validator: (v) => required(v, 'address'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _city,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: context.t('City'), prefixIcon: Icon(Icons.location_city_outlined)),
                    validator: (v) => required(v, 'city'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: InputDecoration(labelText: context.t('Phone'), prefixIcon: Icon(Icons.phone_outlined)),
                    validator: validatePhone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Step(number: 2, title: context.t('Payment')),
            for (final (label, icon, note) in const [
              ('Cash on delivery', Icons.payments_outlined, 'Pay when your order arrives'),
              ('Card', Icons.credit_card_outlined, 'Demo only: no card is charged'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: _payment == label ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => setState(() => _payment = label),
                    leading: Icon(icon),
                    title: Text(context.t(label), style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(context.t(note)),
                    trailing: Icon(
                      _payment == label ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            _Step(number: 3, title: context.t('Review')),
            SummaryCard(summary: summary),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _placing || summary.itemCount == 0 ? null : _place,
            child: _placing
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('${context.t('Place order')} · ${money(summary.total)}'),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 13, backgroundColor: brand, child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(color: brand, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
                ),
              ),
              const SizedBox(height: 28),
              Text(context.t('Order placed!'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                'Thanks, ${order.name.split(' ').first}. Order ${order.id} is on its way to ${order.address}.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text('${order.itemCount} ${context.t('items')} · ${money(order.total)} · ${order.payment}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Text(context.t('Continue shopping')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
