import 'package:flutter/material.dart';

import 'bill_in_time.dart';
import 'bill_over_time.dart';
import 'list_paid.dart';

class ListBill extends StatefulWidget {
  const ListBill({Key? key}) : super(key: key);

  @override
  State<ListBill> createState() => _ListBillState();
}

class _ListBillState extends State<ListBill> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.timer), text: 'Đang đậu'),
              Tab(icon: Icon(Icons.history), text: 'Nợ phí'),
              Tab(icon: Icon(Icons.payments_outlined), text: 'Đã thanh toán'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ListBillInTime(),
                ListBillOverTime(),
                ListBillIsPayment(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
