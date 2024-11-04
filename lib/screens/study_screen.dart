import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:study_helper/buttons/button_complete.dart';
import 'package:study_helper/theme/theme_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

bool isStudy = true;
DateTime _focusedDay = DateTime.now();

class _StudyScreenState extends State<StudyScreen> {
  DateTime? _selectedDay;

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
            const Gap(10),
            TableCalendar(
              focusedDay: _focusedDay,
              headerVisible: false,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              calendarFormat: CalendarFormat.week,
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
                });
              },
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2030, 12, 30),
              // headerStyle: HeaderStyle(),
              calendarStyle: const CalendarStyle(isTodayHighlighted: false),
            ),
            const Gap(20),
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
                        const EdgeInsets.only(top: 40, left: 30, right: 30),
                    child: Column(
                      children: [
                        buttonCompleted(),
                        buttonCompleted(),
                        buttonCompleted(),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
