import 'package:flutter/material.dart';
import 'package:posashastd/constants.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('รายการสินค้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  Icon(Icons.person, color: Colors.black),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: kTabColor,
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Spacer(),
                  const Padding(padding: EdgeInsets.only(right: 16), child: Text('USER', style: TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
