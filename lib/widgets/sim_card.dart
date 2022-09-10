import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimCard extends StatelessWidget {
  final String phoneNumber;
  final DateTime time;
  final bool isTemplate;
  final void Function() onTap;
  const SimCard({
    Key? key,
    required this.phoneNumber,
    required this.time,
    required this.onTap,
  })  : isTemplate = false,
        super(key: key);

  SimCard.template({
    Key? key,
    required this.onTap,
  })  : isTemplate = true,
        phoneNumber = "",
        time = DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTemplate) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: const Color.fromARGB(86, 146, 117, 174),
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: InkWell(
              onTap: () => onTap(),
              child: const Center(
                  child: Icon(
                Icons.add,
                color: Colors.white,
              )),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff6F28B4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              const Spacer(),
              // format the phone like this "07 98 39 85 45"
              Row(
                children: _spreadPhone(phoneNumber)
                    .map(
                      (e) => Expanded(
                          child: Text(e,
                              style: const TextStyle(
                                fontSize: 23,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left)),
                    )
                    .toList(),
              ),
              const Spacer(),

              Row(
                children: [
                  Text(
                      "${time.year} / ${time.month.toString().padLeft(2, "0")}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      )),
                  const Spacer(),
                  Image.asset(
                    "lib/assets/dezzy.png",
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _spreadPhone(String phone) {
    phone = phone.padLeft(10, "0");
    final List<List<String>> list = [[]];
    for (var i = 0; i < phone.length; i++) {
      if (i % 2 == 0 && i != 0) {
        list.add([]);
      }
      list.last.add(phone[i]);
    }
    return list.map((e) => e.join("")).toList();
  }
}
