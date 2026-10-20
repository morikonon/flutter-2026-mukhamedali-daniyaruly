import '../models/session.dart';
import '../models/subject.dart';

/// A function, not a constant: the dates are relative to "now".
List<Session> seedItems() {
  final now = DateTime.now();

  // DateTime normalises overflow, so day 35 of a month just rolls over.
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Session(
      id: 's1',
      // Exactly 60 characters: the longest title the form accepts.
      title: 'Recursion, Trees and Graphs: A Calm Walkthrough for Starters',
      subject: Subject.programming,
      startsAt: at(5, 15),
      seats: 12,
      location: 'Room 402, Main building',
      participants: const ['Aruzhan Bekova', 'Timur Akhmetov', 'Dana Sadykova'],
      description: 'Bring a laptop with Dart installed.',
    ),
    Session(
      id: 's2',
      // At its limit: 4 seats, 4 participants.
      title: 'Calculus I: Limits and Derivatives',
      subject: Subject.math,
      startsAt: at(2, 10),
      seats: 4,
      location: 'Room 215',
      participants: const [
        'Nurlan Serikbayev',
        'Aigerim Tulegenova',
        'Yerlan Kassymov',
        'Madina Zhunusova',
      ],
      description: 'We solve last year\'s midterm together.',
      isFavourite: true,
    ),
    Session(
      id: 's3',
      // Past: ended three days ago.
      title: 'Mechanics Problem Night',
      subject: Subject.physics,
      startsAt: at(-3, 18),
      seats: 15,
      location: 'Physics lab 1',
      participants: const ['Bekzat Omarov', 'Saule Kenzhebekova'],
      description: 'Newton\'s laws, friction and inclined planes.',
    ),
    Session(
      id: 's4',
      // Online: the location is a meeting link.
      title: 'UI Critique: Your Course Project',
      subject: Subject.design,
      startsAt: at(1, 19),
      seats: 25,
      location: 'https://meet.kbtu.kz/ui-critique',
      participants: const ['Alina Ermekova', 'Daniyar Zhakupov'],
      isOnline: true,
      description: 'Share your screen and get feedback in five minutes.',
    ),
    Session(
      id: 's5',
      // No description: the optional text stays null.
      title: 'Startup Pitch Practice',
      subject: Subject.business,
      startsAt: at(7, 16),
      seats: 30,
      location: 'Business school, room 101',
      participants: const ['Askar Nurmagambetov'],
    ),
    Session(
      id: 's6',
      // 3 seats left: shows the "N left" badge.
      title: 'English Speaking Club',
      subject: Subject.languages,
      startsAt: at(3, 17, 30),
      seats: 10,
      location: 'Library, group room B',
      participants: const [
        'Kamila Abenova',
        'Ruslan Tokayev',
        'Zarina Mukhanova',
        'Ilyas Baimukhanov',
        'Togzhan Seitkali',
        'Arman Kuanyshev',
        'Diana Ospanova',
      ],
      description: 'Topic of the week: technology and privacy.',
      isFavourite: true,
    ),
    Session(
      id: 's7',
      // Started 30 minutes ago: shows the Started countdown.
      title: 'Flutter Layout Clinic',
      subject: Subject.programming,
      startsAt: now.subtract(const Duration(minutes: 30)),
      seats: 20,
      location: 'https://meet.kbtu.kz/flutter-clinic',
      participants: const [
        'Timur Akhmetov',
        'Alina Ermekova',
        'Yerlan Kassymov',
      ],
      isOnline: true,
      description: 'Rows, Columns, Expanded and why things overflow.',
    ),
    Session(
      id: 's8',
      title: 'Linear Algebra Review',
      subject: Subject.math,
      startsAt: at(10, 11),
      seats: 40,
      location: 'Room 120, lecture hall',
      participants: const ['Madina Zhunusova', 'Bekzat Omarov'],
      description: 'Matrices, determinants and eigenvalues.',
    ),
    Session(
      id: 's9',
      title: 'Kazakh Grammar Basics',
      subject: Subject.languages,
      startsAt: at(-10, 14),
      seats: 12,
      location: 'Room 305',
      participants: const ['Kamila Abenova', 'Askar Nurmagambetov'],
      description: 'Cases and suffixes, with lots of examples.',
    ),
    Session(
      id: 's10',
      title: 'Electricity and Magnetism Q&A',
      subject: Subject.physics,
      startsAt: at(14, 18),
      seats: 18,
      location: 'https://meet.kbtu.kz/em-qa',
      isOnline: true,
      description: 'Send your questions in advance.',
    ),
    Session(
      id: 's11',
      title: 'Figma Basics for Engineers',
      subject: Subject.design,
      startsAt: at(21, 15),
      seats: 16,
      location: 'Design studio, 3rd floor',
      participants: const [
        'Daniyar Zhakupov',
        'Aruzhan Bekova',
        'Ruslan Tokayev',
      ],
      description: 'Frames, auto layout and components.',
    ),
    Session(
      id: 's12',
      title: 'Accounting 101 Study Group',
      subject: Subject.business,
      startsAt: at(30, 12),
      seats: 8,
      location: 'Business school, room 204',
      participants: const ['Saule Kenzhebekova', 'Diana Ospanova'],
      description: 'Balance sheets and the accounting equation.',
    ),
  ];
}
