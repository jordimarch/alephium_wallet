import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';

class NewWalletCheckbox extends StatelessWidget {
  final String title;
  final String value;
  final String? selected;
  final Function(String) onTap;
  final String description;
  final IconData icon;
  const NewWalletCheckbox({
    Key? key,
    this.selected,
    required this.title,
    required this.value,
    required this.onTap,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          elevation: value == selected ? 5 : 0,
          color: Theme.of(context).primaryColor,
          shadowColor: Color(0xff1902d5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: InkWell(
            onTap: () {
              onTap(value);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (value == selected)
                    GradientIcon(
                        icon: icon,
                        size: 50,
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            WalletTheme.instance.gradientOne,
                            WalletTheme.instance.gradientTwo,
                          ],
                        ))
                  else
                    Icon(
                      icon,
                      size: 50,
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
