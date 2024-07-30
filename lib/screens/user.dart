import 'package:flutter/material.dart';
import 'package:parking_fee/screens/user_over_time_parking_list.dart';
import 'package:parking_fee/screens/user_parking_list.dart';
import 'package:parking_fee/screens/user_parking_paid.dart';


class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with SingleTickerProviderStateMixin {
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
                UserParkingListScreen(),
                UserOverTimeParkingListScreen(),
                UserParkingPaidListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
