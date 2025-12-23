import 'package:flutter/material.dart';

import '../related_hadis_Screen.dart';
import '../widgets/hadis_widget.dart';

class HadisListView extends StatelessWidget {
  const HadisListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return HadisWidget(
          num: "${index + 1}",
          title: 'صحيح البخاري',
          subtitle: '23 حديث',
          enTitle: 'al-Bukhari',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RelatedHadisScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
