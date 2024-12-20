import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:study_helper/api/load/load_subjects_by_date.dart';
import 'package:study_helper/components/cards/study_cards/completed_card.dart';
import 'package:study_helper/components/cards/study_cards/disabled_card.dart';
import 'package:study_helper/components/cards/study_cards/ongoing_card.dart';
import 'package:study_helper/model/subject/subject_model.dart';
import 'package:study_helper/theme/theme_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late Future<List<SubjectModel>> _futureSubject;
  bool isStudy = true;

  @override
  void initState() {
    super.initState();
    _futureSubject = _loadSubjectModel();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  bool timeValdation(String startTimeStr, String endTimeStr) {
    // 현재 시간을 가져옵니다.
    DateTime now = DateTime.now();

    // 시작 시간과 종료 시간을 파싱합니다.
    List<int> startTimeParts = startTimeStr.split(':').map(int.parse).toList();

    // 오늘 날짜의 시작 시간과 종료 시간을 생성합니다.
    DateTime startTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        startTimeParts[0],
        startTimeParts[1],
        startTimeParts[2]);
    // 현재 시간이 시작 시간과 종료 시간 사이인지 확인합니다.

    return now.isAfter(startTime);
  }

  Future<List<SubjectModel>> _loadSubjectModel() async {
    return await loadSubjectByDate(formatDate(_selectedDay), isStudy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 25,
          right: 25,
          top: 20,
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (!isStudy) {
                      setState(() {
                        isStudy = true;
                        _futureSubject = _loadSubjectModel();
                      });
                    }
                  },
                  child: Text(
                    "학습",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isStudy ? colorDefault : colorDisabled,
                    ),
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () {
                    if (isStudy) {
                      setState(() {
                        isStudy = false;
                        _futureSubject = _loadSubjectModel();
                      });
                    }
                  },
                  child: Text(
                    "복습",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isStudy ? colorDisabled : colorDefault,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8,
              ),
              child: TableCalendar(
                focusedDay: _focusedDay,
                availableCalendarFormats: const {
                  CalendarFormat.month: '월별 보기',
                  CalendarFormat.twoWeeks: '2주 보기',
                  CalendarFormat.week: '주별 보기'
                },
                headerVisible: true,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarFormat: _calendarFormat,
                locale: 'ko-kr',
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _futureSubject = _loadSubjectModel();
                  });
                },
                firstDay: DateTime(2024, 1, 1),
                lastDay: DateTime(2030, 12, 30),
                headerStyle: const HeaderStyle(
                  titleCentered: false,
                  // formatButtonShowsNext: false,
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                ),
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: false,
                  selectedDecoration: BoxDecoration(
                    color: colorBottomBarDefault,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Gap(30),
            Expanded(
              flex: 1,
              child: PhysicalModel(
                color: Colors.white,
                elevation: 0.1,
                shadowColor: const Color(0x00000010),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
                clipBehavior: Clip.hardEdge,
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 25, right: 25),
                    child: isStudy
                        ? FutureBuilder<List<SubjectModel>>(
                            future: _futureSubject,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: colorBottomBarDefault,
                                ));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.check),
                                      const Gap(12),
                                      Text(
                                        '${DateFormat('MM월 dd일').format(_selectedDay)}에 진행할 학습이 없습니다!',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Gap(2),
                                      const Text(
                                        '혹은 서버 에러일지도...? ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Column(
                                  children: snapshot.data!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    SubjectModel subject = entry.value;
                                    bool isLast =
                                        index == snapshot.data!.length - 1;
                                    if (subject.learningStatus == '학습 후' &&
                                        timeValdation(subject.startTime,
                                            subject.endTime)) {
                                      return completedCard(
                                        context: context,
                                        subjectModel: subject,
                                        isLast: isLast,
                                        dateTime: _selectedDay,
                                      );
                                    } else if (subject.learningStatus ==
                                            '학습 전' &&
                                        timeValdation(subject.startTime,
                                            subject.endTime)) {
                                      return ongoingCard(
                                        isReview: false,
                                        context: context,
                                        subjectModel: subject,
                                        isLast: isLast,
                                        dateTime: _selectedDay,
                                      );
                                    } else {
                                      return disabledCard(
                                        subjectName: subject.subjectName,
                                        timeText:
                                            "${subject.startTimeCoverted()} ~ ${subject.endTimeCoverted()}",
                                        isLast: isLast,
                                      );
                                    }
                                  }).toList(),
                                );
                              }
                            },
                          )
                        : FutureBuilder<List<SubjectModel>>(
                            future: _futureSubject,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: colorBottomBarDefault,
                                ));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.check),
                                      const Gap(12),
                                      Text(
                                        '${DateFormat('MM월 dd일').format(_selectedDay)}에 진행할 복습이 없습니다!',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Gap(2),
                                      const Text(
                                        '혹은 서버 에러일지도...? ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Column(
                                  children: snapshot.data!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    SubjectModel subject = entry.value;
                                    bool isLast =
                                        index == snapshot.data!.length - 1;
                                    if (subject.learningStatus == 'false') {
                                      return ongoingCard(
                                        isReview: true,
                                        context: context,
                                        subjectModel: subject,
                                        isLast: isLast,
                                        dateTime: _selectedDay,
                                      );
                                    } else {
                                      return completedCard(
                                        dateTime: _selectedDay,
                                        context: context,
                                        subjectModel: subject,
                                        isLast: isLast,
                                      );
                                    }
                                  }).toList(),
                                );
                              }
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
