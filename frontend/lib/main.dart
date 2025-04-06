import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const PolarisCalendarApp());
}

class PolarisCalendarApp extends StatelessWidget {
  const PolarisCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polaris Calendar',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: const Color(0xFF8E9AAF),
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8E9AAF),
          secondary: Color(0xFFCBC0D3),
          tertiary: Color(0xFFEFD3D7),
          surface: Color(0xFF2A2A2A),
          background: Color(0xFF1F1F1F),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const CalendarScreen(),
    const TodoScreen(),
    const ChatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polaris Calendar'),
      ),
      body: _selectedIndex == 0 && _firstLaunch
          ? _buildWelcomeScreen()
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  bool _firstLaunch = true;

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_month,
            size: 100,
            color: Color(0xFF6C5CE7),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome to Polaris Calendar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'A modern calendar and todo application',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Mark as not first launch to show the actual screen
              setState(() {
                _firstLaunch = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

// Sample event data
class Event {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color color;
  final String location;
  final bool isAllDay;
  final String tag;

  const Event({
    required this.title,
    this.description = '',
    required this.start,
    required this.end,
    required this.color,
    this.location = '',
    this.isAllDay = false,
    required this.tag,
  });
}

// Tag definitions
class EventTag {
  final String name;
  final Color color;
  final IconData icon;

  const EventTag({
    required this.name,
    required this.color,
    required this.icon,
  });

  // Get tag by name
  static EventTag getByName(String name) {
    return tags.firstWhere(
      (tag) => tag.name.toLowerCase() == name.toLowerCase(),
      orElse: () => tags[0],
    );
  }

  // Default tags
  static const List<EventTag> tags = [
    EventTag(
      name: 'Work',
      color: Color(0xFF8E9AAF),
      icon: Icons.work,
    ),
    EventTag(
      name: 'Social',
      color: Color(0xFFCBC0D3),
      icon: Icons.people,
    ),
    EventTag(
      name: 'Holiday',
      color: Color(0xFFEFD3D7),
      icon: Icons.celebration,
    ),
    EventTag(
      name: 'Personal',
      color: Color(0xFF8FB3A9),
      icon: Icons.person,
    ),
    EventTag(
      name: 'Health',
      color: Color(0xFFD0ECE7),
      icon: Icons.favorite,
    ),
  ];
}

// Sample events
final List<Event> sampleEvents = [
  Event(
    title: 'Team Meeting',
    description: 'Weekly team sync',
    start: DateTime.now().copyWith(hour: 14, minute: 0),
    end: DateTime.now().copyWith(hour: 15, minute: 0),
    color: EventTag.getByName('Work').color,
    location: 'Conference Room A',
    tag: 'Work',
  ),
  Event(
    title: 'Doctor Appointment',
    description: 'Annual checkup',
    start: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0),
    end: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 11, minute: 0),
    color: EventTag.getByName('Health').color,
    location: 'Downtown Clinic',
    tag: 'Health',
  ),
  Event(
    title: 'Project Deadline',
    description: 'Submit final report',
    start: DateTime.now().add(const Duration(days: 4)).copyWith(hour: 17, minute: 0),
    end: DateTime.now().add(const Duration(days: 4)).copyWith(hour: 18, minute: 0),
    color: EventTag.getByName('Work').color,
    tag: 'Work',
  ),
  Event(
    title: 'Lunch with Sarah',
    description: 'Discuss new project',
    start: DateTime.now().add(const Duration(days: 2)).copyWith(hour: 12, minute: 30),
    end: DateTime.now().add(const Duration(days: 2)).copyWith(hour: 13, minute: 30),
    color: EventTag.getByName('Social').color,
    location: 'Cafe Downtown',
    tag: 'Social',
  ),
  Event(
    title: 'Family Reunion',
    description: 'Annual family gathering',
    start: DateTime.now().add(const Duration(days: 7)),
    end: DateTime.now().add(const Duration(days: 8)),
    color: EventTag.getByName('Social').color,
    location: 'City Park',
    isAllDay: true,
    tag: 'Social',
  ),
  // US Holidays
  Event(
    title: 'New Year\'s Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 1, 1),
    end: DateTime(DateTime.now().year, 1, 1),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Martin Luther King Jr. Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 1, 20), // Third Monday in January (approximation)
    end: DateTime(DateTime.now().year, 1, 20),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Presidents Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 2, 17), // Third Monday in February (approximation)
    end: DateTime(DateTime.now().year, 2, 17),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Memorial Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 5, 31), // Last Monday in May (approximation)
    end: DateTime(DateTime.now().year, 5, 31),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Independence Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 7, 4),
    end: DateTime(DateTime.now().year, 7, 4),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Labor Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 9, 5), // First Monday in September (approximation)
    end: DateTime(DateTime.now().year, 9, 5),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Columbus Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 10, 14), // Second Monday in October (approximation)
    end: DateTime(DateTime.now().year, 10, 14),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Veterans Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 11, 11),
    end: DateTime(DateTime.now().year, 11, 11),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Thanksgiving',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 11, 28), // Fourth Thursday in November (approximation)
    end: DateTime(DateTime.now().year, 11, 28),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
  Event(
    title: 'Christmas Day',
    description: 'Federal Holiday',
    start: DateTime(DateTime.now().year, 12, 25),
    end: DateTime(DateTime.now().year, 12, 25),
    color: EventTag.getByName('Holiday').color,
    isAllDay: true,
    tag: 'Holiday',
  ),
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isMonthView = true;
  
  // Map to store events by date
  Map<DateTime, List<Event>> _eventsByDay = {};
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // Organize sample events by day
    for (final event in sampleEvents) {
      final day = DateTime(event.start.year, event.start.month, event.start.day);
      if (_eventsByDay[day] == null) {
        _eventsByDay[day] = [];
      }
      _eventsByDay[day]!.add(event);
    }
  }
  
  List<Event> _getEventsForDay(DateTime day) {
    final events = _eventsByDay[DateTime(day.year, day.month, day.day)] ?? [];
    return events;
  }
  
  List<Event> _getEventsForWeek() {
    final startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final allEvents = <Event>[];
    for (var day = startOfWeek; day.isBefore(endOfWeek.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      allEvents.addAll(_getEventsForDay(day));
    }
    
    return allEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        if (_isMonthView) _buildMonthView() else _buildWeekView(),
      ],
    );
  }
  
  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.yMMMM().format(_focusedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              ToggleButtons(
                isSelected: [_isMonthView, !_isMonthView],
                onPressed: (index) {
                  setState(() {
                    _isMonthView = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedBorderColor: const Color(0xFF6C5CE7),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF6C5CE7),
                color: Colors.white70,
                constraints: const BoxConstraints(minWidth: 80, minHeight: 36),
                children: const [
                  Text('Month'),
                  Text('Week'),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = _focusedDay;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthView() {
    return Expanded(
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: const BoxDecoration(
                color: Color(0xFF6C5CE7),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF6C5CE7),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSelectedDayEvents(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectedDayEvents() {
    final events = _getEventsForDay(_selectedDay!);
    
    if (events.isEmpty) {
      return const Center(
        child: Text('No events for this day'),
      );
    }
    
    return ListView.builder(
      itemCount: events.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final event = events[index];
        final tag = EventTag.getByName(event.tag);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 12,
              height: double.infinity,
              color: event.color,
            ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.isAllDay 
                      ? 'All day'
                      : '${DateFormat.Hm().format(event.start)} - ${DateFormat.Hm().format(event.end)}',
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(tag.icon, size: 14, color: tag.color),
                    const SizedBox(width: 4),
                    Text(
                      tag.name,
                      style: TextStyle(
                        color: tag.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showEventDetails(event);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildWeekView() {
    final now = DateTime.now();
    final startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    
    return Expanded(
      child: Column(
        children: [
          // Days of week header
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: List.generate(7, (index) {
                final day = startOfWeek.add(Duration(days: index));
                final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
                
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFF6C5CE7).withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(day),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? const Color(0xFF6C5CE7) : null,
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // 24-hour timeline
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                height: 1440, // 24 hours * 60 pixels per hour
                child: Stack(
                  children: [
                    // Hour lines
                    ...List.generate(24, (hour) {
                      return Positioned(
                        top: hour * 60.0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    // Current time indicator
                    if (_focusedDay.year == now.year && 
                        _focusedDay.month == now.month && 
                        _focusedDay.day == now.day)
                      Positioned(
                        top: now.hour * 60.0 + now.minute,
                        left: 50,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.red,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Events for the week
                    ..._getEventsForWeek().map((event) {
                      // Calculate position and height based on event time
                      final startMinutes = event.start.hour * 60 + event.start.minute;
                      final endMinutes = event.end.hour * 60 + event.end.minute;
                      final dayOfWeek = event.start.weekday - 1; // 0-based index
                      
                      // Check if the event is for the current week view
                      if (event.start.year == startOfWeek.year &&
                          event.start.month == startOfWeek.month &&
                          event.start.day >= startOfWeek.day &&
                          event.start.day < startOfWeek.add(const Duration(days: 7)).day) {
                        
                        final dayOffset = event.start.difference(startOfWeek).inDays;
                        final dayWidth = (MediaQuery.of(context).size.width - 50) / 7;
                        
                        return Positioned(
                          top: startMinutes.toDouble(),
                          left: 50 + (dayOffset * dayWidth),
                          width: dayWidth,
                          height: (endMinutes - startMinutes).toDouble(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              onTap: () => _showEventDetails(event),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: event.color.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (endMinutes - startMinutes > 30)
                                      Text(
                                        '${DateFormat.Hm().format(event.start)} - ${DateFormat.Hm().format(event.end)}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    if (endMinutes - startMinutes > 60 && event.location.isNotEmpty)
                                      Text(
                                        event.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container(); // Event not in this week
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEventDetails(Event event) {
    final tag = EventTag.getByName(event.tag);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 24,
                    color: event.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    event.isAllDay
                        ? 'All day'
                        : '${DateFormat.yMd().format(event.start)} ${DateFormat.Hm().format(event.start)} - ${DateFormat.Hm().format(event.end)}',
                  ),
                ],
              ),
              if (event.location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Text(event.location),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(tag.icon, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    tag.name,
                    style: TextStyle(
                      color: tag.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(event.description),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditEventDialog(event);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showEditEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedTag = event.tag;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tag:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: EventTag.tags.map((tag) {
                      return ChoiceChip(
                        label: Text(tag.name),
                        selected: selectedTag == tag.name,
                        onSelected: (selected) {
                          setState(() {
                            selectedTag = tag.name;
                          });
                        },
                        selectedColor: tag.color.withOpacity(0.8),
                        backgroundColor: tag.color.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Map<String, dynamic>> _todos = [
    {
      'title': 'Buy groceries',
      'completed': false,
      'priority': 'high',
    },
    {
      'title': 'Prepare presentation',
      'completed': false,
      'priority': 'high',
    },
    {
      'title': 'Call mom',
      'completed': true,
      'priority': 'low',
    },
    {
      'title': 'Pay utility bills',
      'completed': false,
      'priority': 'high',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo['completed'],
                      onChanged: (bool? value) {
                        setState(() {
                          todo['completed'] = value;
                        });
                      },
                    ),
                    title: Text(
                      todo['title'],
                      style: TextStyle(
                        decoration: todo['completed'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: todo['priority'] == 'high'
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF8BC34A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo['priority'].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Show dialog to add new task
              _showAddTaskDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: const Text('This would open a form to add a new task.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! How can I help you today?',
      'isUser': false,
      'time': '10:00 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(
                message['text'],
                message['isUser'],
                message['time'],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image upload would open here'))
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice recording would start here'))
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF6C5CE7),
                child: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final now = DateTime.now();
      final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isUser': true,
          'time': time,
        });
        
        // Add a simulated response
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _messages.add({
              'text': 'Thanks for your message! This is a placeholder response.',
              'isUser': false,
              'time': time,
            });
          });
        });
      });
      
      _messageController.clear();
    }
  }

  Widget _buildMessageBubble(String text, bool isUser, String time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6C5CE7) : const Color(0xFF424242),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 