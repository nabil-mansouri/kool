import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:food/location/location.dart';
import 'package:intl/intl.dart';
import '../../store/store.dart';
import '../../domain/domain.dart';

class SearchDateViewModel {
  static final DateFormat dayFormatter = DateFormat("EEE. d MMM");
  static final DateFormat hourFormatter = DateFormat.Hm();
  final Subject onHourChanged = PublishSubject();
  final FixedExtentScrollController controller = FixedExtentScrollController();
  //===public
  List<String> formattedDays;
  List<String> formattedHours = [];
  //=== private
  int _minuteRange = 30;
  int _selectedDay = 0;
  int _selectedHour = 0;
  List<DateTime> _days = [];
  List<DateTime> _hours = [];
  //===constructor
  SearchDateViewModel._internal();
  factory SearchDateViewModel.onWeekFromDate(DateTime from) {
    final List<DateTime> days = [];
    for (int i = 0; i < 7; i++) {
      final copy = from.add(Duration(days: i));
      days.add(copy);
    }
    final res = SearchDateViewModel._internal();
    res.days = days;
    res.selectedDay = 0;
    return res;
  }
  //=== selectedDay
  DateTime get selectedDayDate => this.days[selectedDay];
  set selectedDayDate(DateTime toSet) {
    for (int i = 0; i < this._days.length; i++) {
      final d = this._days[i];
      final isSameDay = d.difference(toSet).inDays == 0;
      if (isSameDay) {
        this.selectedDay = i;
        return;
      }
    }
  }

  //=== selectedHour
  DateTime get selectedHourTime => this.hours[selectedHour];
  setSelectedHourTime(DateTime toSet, bool jump) {
    for (int i = 0; i < this._hours.length; i++) {
      final d = this._hours[i];
      final isMoreOrLessSameMinuteOfTheDay =
          d.difference(toSet).inMinutes <= _minuteRange;
      if (isMoreOrLessSameMinuteOfTheDay) {
        this.setSelectedHour(i, jump);
        return;
      }
    }
  }

  //=== selectedDate
  DateTime get selectedDate {
    final day = selectedDayDate;
    final hour = selectedHourTime;
    return DateTime(
        day.year, day.month, day.day, hour.hour, hour.minute, hour.second);
  }

  setSelectedDate(DateTime d) {
    this.selectedDayDate = d;
    this.setSelectedHourTime(d, true);
  }

  //=== selectedHour
  setSelectedHour(int s, bool jump) {
    if (s < 0 || _hours.length <= s) {
      return;
    }
    this._selectedHour = s;
    if (jump) this.controller.jumpToItem(s);
  }

  int get selectedHour => _selectedHour;

  //=== selectedDay
  int get selectedDay => _selectedDay;
  set selectedDay(int s) {
    if (s < 0 || _days.length <= s) {
      return;
    }
    // update hours
    int selectedHour = 0;
    final day = this._days[s];
    final now = DateTime.now();
    final isToday = now.difference(day).inDays == 0;
    final dayMidnight = DateTime(day.year, day.month, day.day);
    final dayWithHourNow = DateTime(
        day.year, day.month, day.day, now.hour, now.minute, now.second);
    final List<DateTime> hours = [];
    for (int i = 0; i < 24 * 60; i += _minuteRange) {
      final hour = dayMidnight.add(Duration(minutes: i));
      if (isToday) {
        if (now.isBefore(hour)) hours.add(hour);
      } else {
        //set selected hour to same hour as now
        if (selectedHour == 0 && dayWithHourNow.isBefore(hour)) {
          selectedHour = hours.length;
        }
        hours.add(hour);
      }
    }
    //update hours
    this.hours = hours;
    //update indexes
    this._selectedDay = s;
    this.setSelectedHour(selectedHour, true);
    //send changed event
    onHourChanged.add(hours);
  }

  //=== hoursObject
  set hours(final List<DateTime> hours) {
    this.formattedHours = hours.map((f) => hourFormatter.format(f)).toList();
    this._hours = hours;
  }

  List<DateTime> get hours => _hours;

  //=== daysObject
  set days(final List<DateTime> days) {
    formattedDays = days.map((f) => dayFormatter.format(f)).toList();
    _days = days;
  }

  List<DateTime> get days => _days;

  dispose() {
    controller.dispose();
  }
}

class SearchViewModel extends AbstractModel<RestaurantState> {
  ModelValue<GeoPlace> location = ModelValue();
  ModelValue<DateTime> forDate = ModelValue();
  ModelValue<bool> forNow = ModelValue();
  RestaurantQuery query = RestaurantQuery();
  //
  final SearchDateViewModel dateModel =
      SearchDateViewModel.onWeekFromDate(DateTime.now());
  //TODO
  final formatter = new DateFormat("EEE. d MMMM 'dès' HH:mm");
  @override
  bool refresh(RestaurantState state) {
    bool changed = false;
    this.query = state.currentQuery;
    if (state.currentQuery?.location != this.location.stateValue) {
      //avoid empty object at init
      if (state.currentQuery?.location?.isAllNull == true) {
        this.location.stateValue = null;
      } else {
        this.location.stateValue = state.currentQuery?.location;
      }
      changed = true;
    }
    if (state.currentQuery?.forDate != this.forDate.stateValue) {
      this.forDate.stateValue = state.currentQuery?.forDate;
      changed = true;
    }
    if (state.currentQuery?.forNow != this.forNow.stateValue) {
      this.forNow.stateValue = state.currentQuery?.forNow;
      changed = true;
    }
    return changed;
  }

  List<GeoPlace> get excludedLocation =>
      location.hasAny != null ? [location.localElseState] : [];

  selectDay(int day) {
    dateModel.selectedDay = day;
    notifyListeners();
  }

  selectHour(int hour) {
    dateModel.setSelectedHour(hour, false);
    notifyListeners();
  }

  submitDate(BuildContext context) {
    final date = this.dateModel.selectedDate;
    forNow.localValue = false;
    forDate.localValue = date;
    Navigator.pop(context);
    notifyListeners();
  }

  selectLocation(GeoPlace place) {
    location.localValue = place;
    notifyListeners();
  }

  submitInit(BuildContext context, GeoPlace place) {
    location.localValue = place;
    selectNowDate();
    submitSearch(context);
    notifyListeners();
  }

  selectNowDate() {
    forDate.localValue = DateTime.now();
    forNow.localValue = true;
    notifyListeners();
  }

  cancelDate() {
    forDate.localValue = null;
    forNow.localValue = true;
    notifyListeners();
  }

  bool get canSubmit {
    if (forNow.allEmpty) return false;
    if (location.allEmpty) return false;
    if (forNow.localElseState == false) {
      if (forDate.allEmpty) return false;
    }
    return true;
  }

  bool get hasNowDate => forNow.localElseState == true;
  bool get hasCustomDate => forNow.localElseState == false;
  String get customDate {
    final val = forDate.localElseState ?? DateTime.now();
    return formatter.format(val);
  }

  submitSearch(BuildContext context) {
    query.location = location.localElseState;
    query.forDate = forDate.localElseState;
    query.forNow = forNow.localElseState;
    getStore<RestaurantStore>(context, RestaurantStore).submitSearch(query);
  }

  @override
  void onDispose() {
    dateModel.dispose();
    super.onDispose();
  }
}
