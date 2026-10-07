import 'package:flutter/material.dart';

import 'contact_card.dart';
import 'contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(
          '${contacts.length} contacts',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      // Without Expanded: "Vertical viewport was given unbounded height."
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          itemBuilder: (context, i) => ContactCard(contact: contacts[i]),
          separatorBuilder: (context, i) => const Divider(),
        ),
      ),
    ],
  );
}
