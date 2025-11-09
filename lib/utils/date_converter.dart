class DateConverter {
  static String miladiToShamsi(DateTime d) {
    try {
      int gy = d.year;
      int gm = d.month;
      int gd = d.day;

      List<int> gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      List<int> jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];

      int gDayNo = 365 * (gy - 1600) +
          ((gy - 1600 + 3) ~/ 4) -
          ((gy - 1600 + 99) ~/ 100) +
          ((gy - 1600 + 399) ~/ 400);

      for (int i = 0; i < gm - 1; i++) {
        gDayNo += gDaysInMonth[i];
      }

      if (gm > 2 && ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0))) {
        gDayNo += 1;
      }

      gDayNo += gd - 1;

      int jDayNo = gDayNo - 79;

      int jNp = jDayNo ~/ 12053;
      jDayNo = jDayNo % 12053;

      int jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);

      jDayNo = jDayNo % 1461;

      if (jDayNo >= 366) {
        jy += (jDayNo - 1) ~/ 365;
        jDayNo = (jDayNo - 1) % 365;
      }

      int jm;
      for (jm = 0; jm < 12; jm++) {
        if (jDayNo < jDaysInMonth[jm]) {
          break;
        }
        jDayNo -= jDaysInMonth[jm];
      }

      int jd = jDayNo + 1;

      return "${jy.toString().padLeft(4, '0')}/${jm.toString().padLeft(2, '0')}/${jd.toString().padLeft(2, '0')}";
    } catch (e) {
      return "1400/01/01";
    }
  }

  static String getCurrentShamsiDate() {
    return miladiToShamsi(DateTime.now());
  }
}
