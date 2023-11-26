import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_fic9_ecommerce/common/constants/colors.dart';
import 'package:flutter_fic9_ecommerce/common/extensions/int_ext.dart';
import 'package:flutter_fic9_ecommerce/presentation/cart/bloc/cart/cart_bloc.dart';

import '../../common/components/button.dart';
import '../../common/components/row_text.dart';
import '../../common/components/spaces.dart';
import '../../data/models/requests/order_request_model.dart';
import '../payment/payment_page.dart';
import '../shipping_address/bloc/get_address/get_address_bloc.dart';
import '../shipping_address/shipping_address_page.dart';
import 'bloc/get_cost/get_cost_bloc.dart';
import 'bloc/order/order_bloc.dart';
import 'widgets/cart_item_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    context.read<GetAddressBloc>().add(const GetAddressEvent.getAddress());
    super.initState();
  }

  List<Item> items = [];
  int localTotalPrice = 0;

  int idAddress = 0;

  String courierName = 'jne';
  int courierPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                loaded: (carts) {
                  if (carts.isEmpty) {
                    return const Center(
                      child: Text('Keranjang Kosong'),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SpaceHeight(16.0),
                    itemCount: carts.length,
                    itemBuilder: (context, index) {
                      return CartItemWidget(
                        data: carts[index],
                      );
                    },
                  );
                },
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Button.filled(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ShippingAddressPage()),
                );
              },
              label: 'Pilih Alamat Pengiriman',
            ),
          ),
          const SpaceHeight(16.0),
          BlocBuilder<GetAddressBloc, GetAddressState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                loaded: (data) {
                  if (data.data.isEmpty) {
                    return const Center(
                      child: Text('Alamat belum ada'),
                    );
                  }
                  final address = idAddress != 0
                      ? data.data.firstWhere(
                          (element) => element.id == idAddress,
                          orElse: () => data.data.first,
                        )
                      : data.data.last;
                  context.read<GetCostBloc>().add(
                        GetCostEvent.getCost(
                          origin: '502',
                          destination:
                              address.attributes.subdistrictId.toString(),
                          courier: 'jne',
                        ),
                      );
                  idAddress = address.id;
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: ColorName.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alamat Pengiriman',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SpaceHeight(16.0),
                        Text(
                          address.attributes.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorName.grey,
                          ),
                        ),
                        const SpaceHeight(8.0),
                        Text(
                          address.attributes.address,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorName.grey,
                          ),
                        ),
                        const SpaceHeight(8.0),
                        Text(
                          address.attributes.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorName.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SpaceHeight(70.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              border: Border.all(color: ColorName.border),
            ),
            child: Column(
              children: [
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return RowText(
                          label: 'Jumlah',
                          value: 0.currencyFormatRp,
                        );
                      },
                      loaded: (carts) {
                        int totalPrice = 0;
                        carts.forEach((element) {
                          totalPrice +=
                              int.parse(element.product.attributes.price) *
                                  element.quantity;
                        });
                        localTotalPrice = totalPrice;
                        items = carts
                            .map(
                              (e) => Item(
                                id: e.product.id,
                                productName: e.product.attributes.name,
                                price: int.parse(e.product.attributes.price),
                                qty: e.quantity,
                              ),
                            )
                            .toList();
                        return RowText(
                          label: 'Jumlah',
                          value: totalPrice.currencyFormatRp,
                        );
                      },
                    );
                  },
                ),
                const SpaceHeight(12.0),
                BlocBuilder<GetCostBloc, GetCostState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return RowText(
                          label: 'Biaya Pengiriman',
                          value: 0.currencyFormatRp,
                        );
                      },
                      loaded: (cost) {
                        return RowText(
                          label: 'Biaya Pengiriman',
                          value: cost.rajaongkir.results.first.costs.first.cost
                              .first.value.currencyFormatRp,
                        );
                      },
                    );
                  },
                ),
                const SpaceHeight(10),
                const Divider(color: ColorName.border),
                const SpaceHeight(12.0),
                BlocBuilder<GetCostBloc, GetCostState>(
                  builder: (context, state2) {
                    return BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () {
                            return RowText(
                              label: 'Total Harga',
                              value: 0.currencyFormatRp,
                            );
                          },
                          loaded: (carts) {
                            int courierPrice = state2.maybeWhen(
                              orElse: () => 0,
                              loaded: (cost) => cost.rajaongkir.results.first
                                  .costs.first.cost.first.value,
                            );
                            int totalPrice = 0;
                            carts.forEach((element) {
                              totalPrice +=
                                  int.parse(element.product.attributes.price) *
                                      element.quantity;
                            });

                            totalPrice += courierPrice;
                            localTotalPrice = totalPrice;
                            return RowText(
                              label: 'Total Harga',
                              value: totalPrice.currencyFormatRp,
                              valueColor: ColorName.primary,
                              fontWeight: FontWeight.bold,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SpaceHeight(16.0),
                BlocConsumer<OrderBloc, OrderState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      orElse: () {},
                      success: (response) {
                        context.read<CartBloc>().add(const CartEvent.started());
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return PaymentPage(
                            invoiceUrl: response.invoiceUrl,
                            orderId: response.externalId,
                          );
                        }));
                      },
                    );
                  },
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return Button.filled(
                          onPressed: () {
                            context.read<OrderBloc>().add(
                                  OrderEvent.order(
                                    OrderRequestModel(
                                      data: Data(
                                        items: items,
                                        totalPrice: localTotalPrice,
                                        deliveryAddress: 'Kab. Tanah Bumbu',
                                        courierName: 'JNE',
                                        courierPrice: 0,
                                        status: 'waiting-payment',
                                      ),
                                    ),
                                  ),
                                );
                          },
                          label: 'Bayar sekarang',
                        );
                      },
                      loading: () {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
