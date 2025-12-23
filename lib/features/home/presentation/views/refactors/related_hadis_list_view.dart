import 'package:flutter/widgets.dart';

import '../widgets/related_hadis_widget.dart';

class RelatedHadisListView extends StatelessWidget {
  const RelatedHadisListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return RelatedHadisWidget(
          num: "${index + 1}",
          arHadis:
              'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم:\n"خير يوم طلعت عليه الشمس يوم الجمعة، فيه خلق آدم، وفيه أدخل الجنة، وفيه أخرج منها، ولا تقوم الساعة إلا في يوم الجمعة."',
          enHadis:
              'On the authority of Abu Huraira, may Allah be pleased with him, who said that the Messenger of Allah, peace and blessings be upon him, said:\n"The best day on which the sun has risen is Friday; on it Adam was created, on it he was admitted into Paradise, and on it he was expelled from it. And the Hour will not be established except on Friday',
          copyTap: () {},
          shareTap: () {},
          saveTap: () {},
        );
      },
    );
  }
}
