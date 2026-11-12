import 'package:flutter/material.dart';

class SleepCalcPresenter {

  double calculateSleepDuration(int age, bool isYear, bool isWakeUpOrBedtime, double wakeOrSleepTime, bool isAMOrPM) {

    double wakeUpOrBedTime = 0;
    // Calculate sleep duration based on age
    double sleepDuration = findSleepDuration(age, isYear);

    // The AM section
    // Wake up time calculation
    if (!isAMOrPM && isWakeUpOrBedtime) {
      wakeUpOrBedTime = wakeOrSleepTime - sleepDuration;
      if (wakeUpOrBedTime < 0) {
        wakeUpOrBedTime += 24; // Adjust for negative time
      }
    }
    // bedtime time calculation
    if (!isAMOrPM && !isWakeUpOrBedtime) {
      wakeUpOrBedTime = wakeOrSleepTime + sleepDuration;
    }
    // The PM section
    // Wake up time calculation
    if (isAMOrPM && isWakeUpOrBedtime) {
      wakeUpOrBedTime = wakeOrSleepTime + sleepDuration + 12;
      if (wakeUpOrBedTime < 0) {
        wakeUpOrBedTime += 24; // Adjust for negative time
      }

    }
    // bedtime time calculation
    if (isAMOrPM && !isWakeUpOrBedtime) {
      wakeUpOrBedTime = wakeOrSleepTime - sleepDuration;
    }



    return wakeUpOrBedTime;
  }

  double findSleepDuration(int age, bool isYear) {
    int ageInMonths;
    
    if (isYear) {
      ageInMonths = age;
    } else {
      ageInMonths = age * 12;
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

}