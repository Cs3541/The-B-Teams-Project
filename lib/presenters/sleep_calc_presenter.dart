

class SleepCalcPresenter {

  String calculateSleepDuration(int age, bool isYear, bool isWakeUpOrBedtime, double hours, double minutes, bool isAM) {

    double wakeUpOrBedTime = 0;
    // Calculate sleep duration based on age
    double sleepDuration = findSleepDuration(age, isYear);

    // The AM section
    if (isAM) {
      // Wake up time calculation
      if (isWakeUpOrBedtime) { //This one works
      wakeUpOrBedTime = hours - sleepDuration;
        if (wakeUpOrBedTime < 0) {
          wakeUpOrBedTime += 24; // Adjust for negative time
        }
      }
      // bedtime calculation
      else if (!isWakeUpOrBedtime) { //This one works
        wakeUpOrBedTime = hours + sleepDuration;
      }
    }
    // The PM section
    // Wake up time calculation
    if (!isAM) { //This one works
      if (isWakeUpOrBedtime) {
      wakeUpOrBedTime = hours - sleepDuration + 12;
        if (wakeUpOrBedTime < 0) {
          wakeUpOrBedTime += 12; // Adjust for negative time
        }
      }
      // bedtime calculation
      else if (!isWakeUpOrBedtime) {//This one works
        wakeUpOrBedTime = hours + sleepDuration + 12;
          if (wakeUpOrBedTime > 24) {
          wakeUpOrBedTime -= 24; // Adjust for time exceeding 24 hours
        }
      }

    }
    //Gathers the total minutes
    int totalMinutes = minuteManager(wakeUpOrBedTime, minutes);
    //handles if total minutes is >=60
    if (totalMinutes >= 60){
      totalMinutes += -60;
      wakeUpOrBedTime +=1;
    }
    //handles if total minutes is below 0
    if (totalMinutes < 0){
      totalMinutes += 60;
      wakeUpOrBedTime -= 1;
    }
    
    //finds if it is AM or PM and adjusts wakeUpOrBedTime accordingly
    String infoText = '';
    double totalTime = wakeUpOrBedTime + (minutes / 60.0);

      if (totalTime >= 12) {
      infoText = 'PM';
      wakeUpOrBedTime = wakeUpOrBedTime - 12;
    } else {
      infoText = 'AM';
    }

    
    //Adds extra zeros to the hours and minutes section to match "00:00" format 
    if (wakeUpOrBedTime < 12) {
      if (totalMinutes < 10){
          return "0${wakeUpOrBedTime.toInt()}:0$totalMinutes $infoText";
      }
      else{
          return "0${wakeUpOrBedTime.toInt()}:$totalMinutes $infoText";
      }
    }
    if (wakeUpOrBedTime >= 12) {
      if (totalMinutes < 10){
          return "${wakeUpOrBedTime.toInt()}:0$totalMinutes $infoText";
      }
      else{
          return "${wakeUpOrBedTime.toInt()}:$totalMinutes $infoText";
      }
    }
  return "Something Broke";
  }

  double findSleepDuration(int age, bool isYear) {
    int ageInMonths;

    if (isYear) {
      ageInMonths = age * 12;
    } else {
      ageInMonths = age;
    }
    
    double sleepDuration;
        if (ageInMonths <= 3) {
      sleepDuration = 16; // 0-3 months old
    } else if (ageInMonths > 3 && ageInMonths <= 12) {
      sleepDuration = 14; // 4-12 months old
    } else if (ageInMonths > 12 && ageInMonths <= 24) {
      sleepDuration = 12.5; // 1-2 years old
    } else if (ageInMonths > 24 && ageInMonths <= 60) {
      sleepDuration = 11.5; // 3-5 years old
    } else if (ageInMonths > 60 && ageInMonths <= 144) {
      sleepDuration = 10.5; // 6-12 years old
    } else if (ageInMonths > 144 && ageInMonths <= 204) {
      sleepDuration = 9; // 13-17 years old
    } else {
      sleepDuration = 8; // 18+ years old
    }

    return sleepDuration;
  }


  int minuteManager(double wakeUpOrBedTime, double minutes) {
  int wholeHours = wakeUpOrBedTime.toInt();
  int minutesInHours = ((wakeUpOrBedTime - wholeHours.toDouble()) * 60 + minutes).toInt();
    
    
    return minutesInHours;
  }

}