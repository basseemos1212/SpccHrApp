import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/menu/menu_items.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final controller = MenuItems();
  int currentItem = 0;
  bool selectedItem = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            background(Column(
              children: [
                Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.contain,
                  height: 250,
                ),
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                    flex: 4,
                    child: ListView.builder(
                        itemBuilder: (context, index) {
                          selectedItem = currentItem == index;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: selectedItem
                                    ? primaryColor.withOpacity(0.7)
                                    : Colors.transparent),
                            child: ListTile(
                              leading: Icon(
                                controller.items[index].icon,
                                color:
                                    selectedItem ? Colors.white : Colors.black,
                              ),
                              title: Text(
                                controller.items[index].title,
                                style: TextStyle(
                                    color: selectedItem
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              onTap: () {
                                setState(() {
                                  currentItem = index;
                                });
                              },
                            ),
                          );
                        },
                        itemCount: controller.items.length)),
                Center(
                  child: Lottie.asset('assets/lottie/loading.json',
                      fit: BoxFit.contain, repeat: true),
                )
              ],
            )),
            Expanded(
                child: PageView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                return controller.items[currentItem].widget;
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget background(Widget child) {
    return Container(
      width: 400,
      height: double.infinity,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            blurRadius: 1,
            spreadRadius: 0),
      ], borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: child,
    );
  }
}
