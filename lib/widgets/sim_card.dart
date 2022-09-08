import 'package:flutter/material.dart';

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
    return Container(
      width: MediaQuery.of(context).size.width * .6,
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => onTap(),
        child: isTemplate
            ? Center(child: Icon(Icons.add))
            : Column(
                children: [
                  // todo format the phone like this "07 98 39 85 45"

                  Text(phoneNumber),
                  Row(
                    children: [
                      Text("${time.year} / ${time.month}"),
                      Spacer(),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
