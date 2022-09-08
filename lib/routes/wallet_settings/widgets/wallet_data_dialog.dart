import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletSettingDataDialog extends StatelessWidget {
  final String data;
  final String title;
  const WalletSettingDataDialog({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        width: MediaQuery.of(context).size.width * .70,
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16.0),
            color: Color.fromARGB(255, 240, 240, 240),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    data,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(wordSpacing: 2.0),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Close",
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
    ;
  }
}
