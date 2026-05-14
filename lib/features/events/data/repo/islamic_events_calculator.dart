import '../models/islam_event_model.dart';

/// Calculates Islamic events for the current and next Hijri year
/// using the Tabular Islamic Calendar algorithm (same as prayer_times_service.dart).
/// No network required — works fully offline.
class IslamicEventsCalculator {
  // ── Hijri → Julian Day Number ─────────────────────────────────────────────
  static double _islamicToJD(int year, int month, int day) {
    return day +
        (29.5 * (month - 1)).ceil().toDouble() +
        (year - 1) * 354.0 +
        ((3 + 11 * year) ~/ 30).toDouble() +
        1948439.5 -
        1.0;
  }

  // ── Julian Day Number → Gregorian ─────────────────────────────────────────
  static DateTime _jdToGregorian(double jd) {
    final int j = jd.floor() + 1;
    final int a = j + 32044;
    final int b = (4 * a + 3) ~/ 146097;
    final int c = a - (146097 * b) ~/ 4;
    final int d = (4 * c + 3) ~/ 1461;
    final int e = c - (1461 * d) ~/ 4;
    final int m = (5 * e + 2) ~/ 153;
    final int day = e - (153 * m + 2) ~/ 5 + 1;
    final int month = m + 3 - 12 * (m ~/ 10);
    final int year = 100 * b + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }

  // ── Gregorian → Hijri year ────────────────────────────────────────────────
  static int _gregorianToHijriYear(DateTime date) {
    final int jdn = _gregorianToJDN(date.year, date.month, date.day);
    const double epoch = 1948439.5;
    final double jd = jdn + 0.5;
    return ((30.0 * (jd - epoch) + 10646.0) / 10631.0).floor();
  }

  static int _gregorianToJDN(int year, int month, int day) {
    final int a = (14 - month) ~/ 12;
    final int y = year + 4800 - a;
    final int m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  // ── Hijri date → Gregorian DateTime ───────────────────────────────────────
  static DateTime hijriToGregorian(int hYear, int hMonth, int hDay) {
    return _jdToGregorian(_islamicToJD(hYear, hMonth, hDay));
  }

  // ── Fixed Hijri events (month, day, title, description, wikiLink) ─────────
  static const List<_HijriEvent> _events = [
    _HijriEvent(
      month: 1, day: 1,
      title: 'رأس السنة الهجرية',
      description:
          'بداية العام الهجري الجديد. يُحيي المسلمون ذكرى هجرة النبي ﷺ من مكة إلى المدينة المنورة، وهي الحادثة التي اتُّخذت مبدأً للتقويم الهجري.',
      link: 'https://ar.wikipedia.org/wiki/السنة_الهجرية',
    ),
    _HijriEvent(
      month: 1, day: 10,
      title: 'يوم عاشوراء',
      description:
          'اليوم العاشر من شهر محرم. يصوم فيه كثير من المسلمين شكراً لله تعالى، اقتداءً بالنبي موسى عليه السلام الذي أُنجي فيه من فرعون.',
      link: 'https://ar.wikipedia.org/wiki/عاشوراء',
    ),
    _HijriEvent(
      month: 3, day: 12,
      title: 'ذكرى المولد النبوي الشريف',
      description:
          'الذكرى السنوية لمولد سيدنا محمد ﷺ في الثاني عشر من ربيع الأول. يحتفل بها المسلمون بتلاوة القرآن والصلاة على النبي وإحياء سيرته العطرة.',
      link: 'https://ar.wikipedia.org/wiki/المولد_النبوي',
    ),
    _HijriEvent(
      month: 7, day: 27,
      title: 'ليلة الإسراء والمعراج',
      description:
          'في ليلة السابع والعشرين من رجب أُسري بالنبي ﷺ من مكة إلى المسجد الأقصى، ثم عُرج به إلى السماوات العُلا، وفُرضت فيها الصلوات الخمس.',
      link: 'https://ar.wikipedia.org/wiki/الإسراء_والمعراج',
    ),
    _HijriEvent(
      month: 8, day: 15,
      title: 'ليلة النصف من شعبان',
      description:
          'ليلة الخامس عشر من شعبان. يُستحب فيها إحياء الليل بالذكر والدعاء والاستغفار، وهي من الليالي الفاضلة عند جمهور العلماء.',
      link: 'https://ar.wikipedia.org/wiki/ليلة_النصف_من_شعبان',
    ),
    _HijriEvent(
      month: 9, day: 1,
      title: 'بداية شهر رمضان المبارك',
      description:
          'أول أيام شهر رمضان، شهر الصيام والقرآن. يُمسك المسلمون عن الطعام والشراب من الفجر حتى الغروب، ويتقربون إلى الله بالصلاة والذكر والصدقة.',
      link: 'https://ar.wikipedia.org/wiki/رمضان',
    ),
    _HijriEvent(
      month: 9, day: 27,
      title: 'ليلة القدر',
      description:
          'ليلة القدر خير من ألف شهر. تُلتمس في الليالي الوتر من العشر الأواخر من رمضان، وهي الليلة التي أُنزل فيها القرآن الكريم.',
      link: 'https://ar.wikipedia.org/wiki/ليلة_القدر',
    ),
    _HijriEvent(
      month: 10, day: 1,
      title: 'عيد الفطر المبارك',
      description:
          'يوم الاحتفال بانتهاء شهر رمضان المبارك. يؤدي المسلمون صلاة العيد ويتبادلون التهاني، ويُخرجون زكاة الفطر طهارةً للصائم.',
      link: 'https://ar.wikipedia.org/wiki/عيد_الفطر',
    ),
    _HijriEvent(
      month: 12, day: 9,
      title: 'يوم عرفة',
      description:
          'أعظم أيام السنة وسيد أيام العشر. يقف فيه الحجاج على جبل عرفة، ويُستحب صيامه لغير الحاج، فقد قال النبي ﷺ إنه يُكفِّر السنة الماضية والقادمة.',
      link: 'https://ar.wikipedia.org/wiki/يوم_عرفة',
    ),
    _HijriEvent(
      month: 12, day: 10,
      title: 'عيد الأضحى المبارك',
      description:
          'أكبر أعياد الإسلام. يُذبح فيه الأضحية إحياءً لسنة سيدنا إبراهيم عليه السلام، ويؤدي المسلمون مناسك الحج الكبرى في مكة المكرمة.',
      link: 'https://ar.wikipedia.org/wiki/عيد_الأضحى',
    ),
    _HijriEvent(
      month: 12, day: 11,
      title: 'أيام التشريق',
      description:
          'أيام الحادي عشر والثاني عشر والثالث عشر من ذي الحجة. قال النبي ﷺ: "أيام التشريق أيام أكل وشرب وذكر لله". ولا يجوز صومها.',
      link: 'https://ar.wikipedia.org/wiki/أيام_التشريق',
    ),
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns all Islamic events for the current and next Hijri year,
  /// sorted by date (soonest first). Events from the past 7 days are
  /// also included so users can see recently-passed occasions.
  static List<IslamicEvent> getEvents() {
    final now = DateTime.now();
    final currentHijriYear = _gregorianToHijriYear(now);
    final cutoff = now.subtract(const Duration(days: 7));

    final results = <_Dated>[];

    for (final hYear in [currentHijriYear, currentHijriYear + 1]) {
      for (final ev in _events) {
        try {
          final gregorian = hijriToGregorian(hYear, ev.month, ev.day);
          if (gregorian.isAfter(cutoff)) {
            results.add(_Dated(gregorian, ev, hYear));
          }
        } catch (_) {}
      }
    }

    results.sort((a, b) => a.date.compareTo(b.date));

    // Deduplicate (same event can appear for two consecutive years if cutoff
    // catches a very recent date and also the same event next year).
    final seen = <String>{};
    final deduped = <_Dated>[];
    for (final d in results) {
      final key = '${d.event.title}-${d.hijriYear}';
      if (seen.add(key)) deduped.add(d);
    }

    return deduped.map((d) {
      final g = d.date;
      final remaining = g.difference(now);
      final String status;
      if (remaining.isNegative) {
        status = 'مرّ منذ ${(-remaining.inDays)} يوم';
      } else if (remaining.inDays == 0) {
        status = 'اليوم 🎉';
      } else if (remaining.inDays == 1) {
        status = 'غداً';
      } else {
        status = 'بعد ${remaining.inDays} يوماً';
      }

      final String arabicDate =
          '${d.event.day} ${_monthName(d.event.month)} ${d.hijriYear} هـ  •  '
          '${g.day}/${g.month}/${g.year} م  ($status)';

      return IslamicEvent(
        title: d.event.title,
        date: arabicDate,
        description: d.event.description,
        link: d.event.link,
      );
    }).toList();
  }

  static const List<String> _hijriMonths = [
    '', 'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static String _monthName(int m) =>
      (m >= 1 && m <= 12) ? _hijriMonths[m] : '';
}

class _HijriEvent {
  final int month;
  final int day;
  final String title;
  final String description;
  final String link;
  const _HijriEvent({
    required this.month,
    required this.day,
    required this.title,
    required this.description,
    required this.link,
  });
}

class _Dated {
  final DateTime date;
  final _HijriEvent event;
  final int hijriYear;
  const _Dated(this.date, this.event, this.hijriYear);
}
