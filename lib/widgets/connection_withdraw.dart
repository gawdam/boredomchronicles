import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/services/manage_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawConnectionRequest extends ConsumerWidget {
  const WithdrawConnectionRequest({Key? key, required this.userData})
      : super(key: key);

  final UserData userData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: 'Connection sent to ',
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
            children: <TextSpan>[
              TextSpan(
                text: userData.connectedToUsername,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // You can set your desired color
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            await ManageConnection.withdrawConnection(
                userData.uid, userData.connectionID!);
            ref.invalidate(userProvider);
          },
          child: const Text('Withdraw Request'),
        ),
      ],
    );
  }
}
