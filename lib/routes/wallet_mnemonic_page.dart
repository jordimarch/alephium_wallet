import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/mnemonic_verify/mnemonic_verify_page.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class WalletMnemonicPage extends StatefulWidget {
  final WalletStore wallet;
  final CreateWalletBloc bloc;
  const WalletMnemonicPage({
    Key? key,
    required this.wallet,
    required this.bloc,
  }) : super(key: key);

  @override
  State<WalletMnemonicPage> createState() => _WalletMnemonicPageState();
}

class _WalletMnemonicPageState extends State<WalletMnemonicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        ...widget.wallet.mnemonic
                            .split(' ')
                            .asMap()
                            .map((index, word) {
                              return MapEntry(
                                  index,
                                  Material(
                                      elevation: 0,
                                      color: WalletTheme.lightPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xff797979),
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4),
                                        child: Text(
                                          "${index + 1} - ${word}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      )));
                            })
                            .values
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Please keep this mnemonic safe and secure.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Hero(
                  tag: "Button",
                  child: OutlinedButton(
                    child: Text("Next"),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.walletVerifyMnemonic,
                        arguments: {
                          "wallet": widget.wallet,
                          "bloc": widget.bloc,
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        WalletAppBar(
          label: Text(
            'Wallet Mnemonic',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    ));
  }
}
