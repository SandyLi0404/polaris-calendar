import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/todo_service.dart';
import 'services/calendar_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to load .env but continue even if it fails
  try {
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully");
  } catch (e) {
    print('Environment file not found, using default configuration');
  }
  
  // Run the app regardless of whether .env was loaded
  runApp(const PolarisCalendarApp());
}

// App color themes based on reference images
class AppThemes {
  // Calendar theme (beach/coastal palette)
  static const calendarTheme = ColorScheme.light(
    primary: Color(0xFF8FB3A9),       // Seafoam green
    primaryContainer: Color(0xFFB7D8CF), // Lighter seafoam
    secondary: Color(0xFFE7A17E),     // Coral/salmon
    secondaryContainer: Color(0xFFFFD3B8), // Light coral
    tertiary: Color(0xFF7DAFCA),      // Sky blue
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFEBF5F4),    // Very light mint
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2A2A2A),
    onTertiary: Color(0xFFFFFFFF),
    onBackground: Color(0xFF2A2A2A),
    onSurface: Color(0xFF2A2A2A),
  );
  
  // Todo theme (minimalist palette)
  static const todoTheme = ColorScheme.light(
    primary: Color(0xFFADBAA2),       // Sage green
    primaryContainer: Color(0xFFD2DBC9), // Light sage
    secondary: Color(0xFFBFB6AA),     // Taupe
    secondaryContainer: Color(0xFFE6DFD7), // Light beige
    tertiary: Color(0xFFA1A2A6),      // Gray
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF5F5F5),    // Off-white
    onPrimary: Color(0xFF2A2A2A),
    onSecondary: Color(0xFF2A2A2A),
    onTertiary: Color(0xFFFFFFFF),
    onBackground: Color(0xFF2A2A2A),
    onSurface: Color(0xFF2A2A2A),
  );
  
  // Chat theme (complementary palette)
  static const chatTheme = ColorScheme.light(
    primary: Color(0xFFCBC0D3),       // Lavender
    primaryContainer: Color(0xFFE5DEE9), // Light lavender
    secondary: Color(0xFFEFD3D7),     // Soft pink
    secondaryContainer: Color(0xFFF7E9EB), // Light pink
    tertiary: Color(0xFF8E9AAF),      // Dusty blue
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF8F7FA),    // Very light lavender
    onPrimary: Color(0xFF2A2A2A),
    onSecondary: Color(0xFF2A2A2A),
    onTertiary: Color(0xFFFFFFFF),
    onBackground: Color(0xFF2A2A2A),
    onSurface: Color(0xFF2A2A2A),
  );
}

class PolarisCalendarApp extends StatelessWidget {
  const PolarisCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polaris Calendar',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF8E9AAF),
        scaffoldBackgroundColor: const Color(0xFFF8F7FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8E9AAF),
          secondary: Color(0xFFCBC0D3),
          tertiary: Color(0xFFEFD3D7),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF8F7FA),
          onBackground: Color(0xFF2A2A2A),
          onSurface: Color(0xFF2A2A2A),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCBC0D3),
          foregroundColor: Color(0xFF2A2A2A),
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF8E9AAF),
          unselectedItemColor: Color(0xFFAAAAAA),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          displayMedium: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          displaySmall: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          headlineLarge: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          headlineMedium: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          headlineSmall: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          titleLarge: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          titleMedium: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          titleSmall: TextStyle(fontFamily: 'Georgia', color: Color(0xFF2A2A2A)),
          bodyLarge: TextStyle(color: Color(0xFF2A2A2A)),
          bodyMedium: TextStyle(color: Color(0xFF2A2A2A)),
          bodySmall: TextStyle(color: Color(0xFF2A2A2A)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF8E9AAF),
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

  // Get theme colors based on selected tab
  ColorScheme _getTabColorScheme() {
    switch (_selectedIndex) {
      case 0:
        return AppThemes.calendarTheme;
      case 1:
        return AppThemes.todoTheme;
      case 2:
        return AppThemes.chatTheme;
      default:
        return AppThemes.calendarTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabColorScheme = _getTabColorScheme();
    
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: tabColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: tabColorScheme.primaryContainer,
          foregroundColor: tabColorScheme.onPrimary,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Polaris Calendar',
            style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
          ),
        ),
        body: _selectedIndex == 0 && _firstLaunch
            ? _buildWelcomeScreen()
            : _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: tabColorScheme.primary,
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
      ),
    );
  }

  bool _firstLaunch = true;

  Widget _buildWelcomeScreen() {
    final tabColorScheme = _getTabColorScheme();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tabColorScheme.background,
            tabColorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 100,
              color: tabColorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Polaris Calendar',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
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
                backgroundColor: tabColorScheme.primary,
                foregroundColor: tabColorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

// Sample event data
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color color;
  final String location;
  final bool isAllDay;
  final String tag;
  final int? todoId; // Reference to linked Todo item

  Event({
    String? id,
    required this.title,
    this.description = '',
    required this.start,
    required this.end,
    required this.color,
    this.location = '',
    this.isAllDay = false,
    required this.tag,
    this.todoId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

// Event tag data
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
    return _eventTags.firstWhere(
      (tag) => tag.name.toLowerCase() == name.toLowerCase(),
      orElse: () => _eventTags.first,
    );
  }

  // All available tags
  static final List<EventTag> _eventTags = [
    const EventTag(
      name: 'Work',
      color: Colors.blue,
      icon: Icons.work,
    ),
    const EventTag(
      name: 'Personal',
      color: Colors.orange,
      icon: Icons.person,
    ),
    const EventTag(
      name: 'Health',
      color: Colors.green,
      icon: Icons.medical_services,
    ),
    const EventTag(
      name: 'Social',
      color: Colors.purple,
      icon: Icons.people,
    ),
    const EventTag(
      name: 'Holiday',
      color: Colors.red,
      icon: Icons.celebration,
    ),
  ];

  // Get all tags
  static List<EventTag> getAll() => _eventTags;
}

// Todo data model
class Todo {
  int? id;
  String title;
  String description;
  bool completed;
  String priority;
  DateTime? deadline;
  bool addedToCalendar;
  String? eventId; // Reference to linked Calendar event

  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.priority = 'normal',
    this.deadline,
    this.addedToCalendar = false,
    this.eventId,
  });
}

// Sample events
final List<Event> sampleEvents = [
  Event(
    id: '1',
    title: 'Team Meeting',
    description: 'Weekly team sync',
    start: DateTime.now().add(const Duration(hours: 1)),
    end: DateTime.now().add(const Duration(hours: 2)),
    color: Colors.blue,
    tag: 'Work',
  ),
  Event(
    id: '2',
    title: 'Doctor Appointment',
    description: 'Annual checkup',
    start: DateTime.now().add(const Duration(days: 1, hours: 10)),
    end: DateTime.now().add(const Duration(days: 1, hours: 11)),
    color: Colors.green,
    location: 'Medical Center',
    tag: 'Health',
  ),
  Event(
    id: '3',
    title: 'Birthday Party',
    description: 'John\'s birthday celebration',
    start: DateTime.now().add(const Duration(days: 2, hours: 18)),
    end: DateTime.now().add(const Duration(days: 2, hours: 22)),
    color: Colors.purple,
    location: 'Skybar',
    tag: 'Social',
  ),
  // More events
  Event(
    id: '4',
    title: 'Project Deadline',
    description: 'Submit final deliverables',
    start: DateTime.now().add(const Duration(days: 3)),
    end: DateTime.now().add(const Duration(days: 3, hours: 2)),
    color: Colors.red,
    tag: 'Work',
  ),
  Event(
    id: '5',
    title: 'Yoga Class',
    description: 'Weekly yoga session',
    start: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    end: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    color: Colors.teal,
    location: 'Fitness Center',
    tag: 'Health',
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
  bool _isLoading = true;
  
  // Map to store events by date
  Map<DateTime, List<Event>> _eventsByDay = {};
  List<Event> _allEvents = [];
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load events from service instead of using sample data
      final events = await CalendarService.getEvents();
      
      setState(() {
        _allEvents = events;
        _organizeEventsByDay(events);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _organizeEventsByDay(List<Event> events) {
    _eventsByDay = {};
    for (final event in events) {
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

  // Add a new event
  Future<void> _addEvent(Event event) async {
    try {
      // Add event to calendar
      final newEvent = await CalendarService.addEvent(event);
      
      // If the event should be linked to a todo
      if (event.todoId != null) {
        // Find the todo and update it
        final todo = await TodoService.findById(event.todoId!);
        if (todo != null) {
          await TodoService.updateTodo(todo['id'], {
            'title': todo['title'],
            'description': todo['description'],
            'priority': todo['priority'],
            'deadline': todo['deadline'],
            'added_to_calendar': true,
            'event_id': newEvent.id,
          });
        }
      }
      
      // Refresh events
      await _loadEvents();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event: $e')),
      );
    }
  }

  // Update an existing event
  Future<void> _updateEvent(Event event) async {
    try {
      // Update event in calendar
      await CalendarService.updateEvent(event.id, event);
      
      // If the event is linked to a todo
      if (event.todoId != null) {
        // Find the todo and update it
        final todo = await TodoService.findById(event.todoId!);
        if (todo != null) {
          await TodoService.updateTodo(todo['id'], {
            'title': event.title,
            'description': event.description,
            'deadline': event.start.toIso8601String(),
            'added_to_calendar': true,
            'event_id': event.id,
          });
        }
      }
      
      // Refresh events
      await _loadEvents();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating event: $e')),
      );
    }
  }

  // Delete an event
  Future<void> _deleteEvent(Event event) async {
    try {
      // Delete event from calendar
      await CalendarService.deleteEvent(event.id);
      
      // If the event is linked to a todo
      if (event.todoId != null) {
        // Find the todo and update it
        final todo = await TodoService.findById(event.todoId!);
        if (todo != null) {
          await TodoService.updateTodo(todo['id'], {
            'title': todo['title'],
            'description': todo['description'],
            'priority': todo['priority'],
            'deadline': todo['deadline'],
            'added_to_calendar': false,
            'event_id': null,
          });
        }
      }
      
      // Refresh events
      await _loadEvents();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }

  // Create a todo from the event
  Future<void> _addEventAsTodo(Event event) async {
    try {
      // Only proceed if not already a todo
      if (event.todoId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This event is already in your todo list')),
        );
        return;
      }
      
      // Create a todo from the event
      final todo = SyncService.createTodoFromEvent(event);
      
      // Add to todos
      final newTodo = await TodoService.createTodo({
        'title': todo.title,
        'description': todo.description,
        'priority': todo.priority,
        'deadline': todo.deadline?.toIso8601String(),
        'added_to_calendar': true,
        'event_id': event.id,
      });
      
      // Update the event with the todo ID
      final updatedEvent = Event(
        id: event.id,
        title: event.title,
        description: event.description,
        start: event.start,
        end: event.end,
        color: event.color,
        tag: event.tag,
        location: event.location,
        isAllDay: event.isAllDay,
        todoId: newTodo['id'],
      );
      
      await CalendarService.updateEvent(event.id, updatedEvent);
      await _loadEvents();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added to your todo list')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event as todo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.background,
            colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
      ),
      child: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            _buildCalendarHeader(),
            if (_isMonthView) _buildMonthView() else _buildWeekView(),
          ],
        ),
    );
  }
  
  Widget _buildCalendarHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.yMMMM().format(_focusedDay),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
              color: colorScheme.onBackground,
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
                selectedBorderColor: colorScheme.primary,
                selectedColor: colorScheme.onPrimary,
                fillColor: colorScheme.primary,
                color: colorScheme.primary,
                constraints: const BoxConstraints(minWidth: 80, minHeight: 36),
                children: const [
                  Text('Month'),
                  Text('Week'),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.today, color: colorScheme.primary),
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
    final colorScheme = Theme.of(context).colorScheme;
    
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
              markerDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerVisible: false,
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
                      _deleteEvent(event);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  if (event.todoId == null) // Only show if not already a todo
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _addEventAsTodo(event);
                      },
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add to Todo'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
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
                    children: EventTag.getAll().map((tag) {
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
  List<Todo> _todos = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _syncCalendarToTodos();
  }

  Future<void> _loadTodos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final todos = await TodoService.getTodos();
      setState(() {
        _todos = todos.map((todo) => Todo(
          id: todo['id'],
          title: todo['title'],
          description: todo['description'] ?? '',
          completed: todo['is_completed'],
          priority: todo['priority'].toString().toLowerCase(),
          deadline: todo['deadline'] != null ? DateTime.parse(todo['deadline']) : null,
          addedToCalendar: todo['added_to_calendar'] ?? false,
          eventId: todo['event_id'],
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading todos: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading todos: $e')),
      );
    }
  }

  Future<void> _syncCalendarToTodos() async {
    try {
      // Get today's events from calendar
      final events = await CalendarService.getTodayEvents();
      
      // For each event, see if it's already in the todo list
      for (final event in events) {
        // Skip events that don't have a deadline today
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final eventDate = DateTime(event.start.year, event.start.month, event.start.day);
        if (eventDate != today) continue;
        
        // Check if we already have this event as a todo
        final existingTodo = await TodoService.findByEventId(event.id);
        if (existingTodo != null) continue;
        
        // Create a new todo from the event
        final todo = SyncService.createTodoFromEvent(event);
        final newTodo = await TodoService.createTodo({
          'title': todo.title,
          'description': todo.description,
          'priority': todo.priority,
          'deadline': todo.deadline?.toIso8601String(),
          'added_to_calendar': true,
          'event_id': event.id,
        });
        
        // Add to local todos list
        setState(() {
          _todos.add(Todo(
            id: newTodo['id'],
            title: newTodo['title'],
            description: newTodo['description'],
            priority: newTodo['priority'],
            deadline: newTodo['deadline'] != null ? DateTime.parse(newTodo['deadline']) : null,
            addedToCalendar: true,
            eventId: newTodo['event_id'],
          ));
        });
      }
    } catch (e) {
      print('Error syncing calendar to todos: $e');
    }
  }

  Future<void> _createTodo(Todo todo) async {
    try {
      final response = await TodoService.createTodo({
        'title': todo.title,
        'description': todo.description,
        'priority': todo.priority,
        'deadline': todo.deadline?.toIso8601String(),
        'added_to_calendar': todo.addedToCalendar,
        'event_id': todo.eventId,
      });
      
      final newTodo = Todo(
        id: response['id'],
        title: response['title'],
        description: response['description'] ?? '',
        completed: response['is_completed'],
        priority: response['priority'].toString().toLowerCase(),
        deadline: response['deadline'] != null ? DateTime.parse(response['deadline']) : null,
        addedToCalendar: response['added_to_calendar'] ?? false,
        eventId: response['event_id'],
      );
      
      setState(() {
        _todos.add(newTodo);
      });
      
      // If marked for calendar, create calendar event
      if (newTodo.addedToCalendar && newTodo.deadline != null) {
        await _addTodoToCalendar(newTodo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating todo: $e')),
      );
    }
  }

  Future<void> _updateTodo(Todo todo) async {
    try {
      final response = await TodoService.updateTodo(todo.id!, {
        'title': todo.title,
        'description': todo.description,
        'priority': todo.priority,
        'deadline': todo.deadline?.toIso8601String(),
        'added_to_calendar': todo.addedToCalendar,
        'event_id': todo.eventId,
      });
      
      final updatedTodo = Todo(
        id: response['id'],
        title: response['title'],
        description: response['description'] ?? '',
        completed: response['is_completed'],
        priority: response['priority'].toString().toLowerCase(),
        deadline: response['deadline'] != null ? DateTime.parse(response['deadline']) : null,
        addedToCalendar: response['added_to_calendar'] ?? false,
        eventId: response['event_id'],
      );
      
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = updatedTodo;
        }
      });
      
      // Handle calendar sync
      if (updatedTodo.addedToCalendar && updatedTodo.deadline != null) {
        if (updatedTodo.eventId != null) {
          // Update existing calendar event
          await _updateCalendarEvent(updatedTodo);
        } else {
          // Create new calendar event
          await _addTodoToCalendar(updatedTodo);
        }
      } else if (!updatedTodo.addedToCalendar && updatedTodo.eventId != null) {
        // Remove from calendar if unchecked
        await _removeFromCalendar(updatedTodo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    try {
      await TodoService.deleteTodo(todo.id!);
      
      setState(() {
        _todos.removeWhere((t) => t.id == todo.id);
      });
      
      // If it has a calendar event, remove it
      if (todo.eventId != null) {
        await _removeFromCalendar(todo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  Future<void> _toggleTodoCompletion(Todo todo) async {
    try {
      final response = await TodoService.toggleTodoCompletion(todo.id!);
      
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = Todo(
            id: response['id'],
            title: response['title'],
            description: response['description'] ?? '',
            completed: response['is_completed'],
            priority: response['priority'].toString().toLowerCase(),
            deadline: response['deadline'] != null ? DateTime.parse(response['deadline']) : null,
            addedToCalendar: response['added_to_calendar'] ?? false,
            eventId: response['event_id'],
          );
        }
      });
      
      // If this is now complete and has a calendar event, update it
      if (todo.eventId != null && response['is_completed']) {
        // You could update the calendar event to show it's completed
        // This is optional based on your requirements
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling todo completion: $e')),
      );
    }
  }
  
  // Add a todo to the calendar
  Future<void> _addTodoToCalendar(Todo todo) async {
    try {
      // Create a calendar event from todo
      final event = SyncService.createEventFromTodo(todo);
      
      // Save to calendar
      final createdEvent = await CalendarService.addEvent(event);
      
      // Update todo with event ID
      final updatedTodo = await TodoService.updateTodo(todo.id!, {
        'title': todo.title,
        'description': todo.description,
        'priority': todo.priority,
        'deadline': todo.deadline?.toIso8601String(),
        'added_to_calendar': true,
        'event_id': createdEvent.id,
      });
      
      // Update local todo
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = Todo(
            id: updatedTodo['id'],
            title: updatedTodo['title'],
            description: updatedTodo['description'] ?? '',
            completed: updatedTodo['is_completed'],
            priority: updatedTodo['priority'].toString().toLowerCase(),
            deadline: updatedTodo['deadline'] != null ? DateTime.parse(updatedTodo['deadline']) : null,
            addedToCalendar: true,
            eventId: updatedTodo['event_id'],
          );
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added to calendar')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to calendar: $e')),
      );
    }
  }
  
  // Update a calendar event from a todo
  Future<void> _updateCalendarEvent(Todo todo) async {
    try {
      // Find existing event
      final existingEvent = await CalendarService.findById(todo.eventId!);
      if (existingEvent == null) {
        // Event doesn't exist anymore, create new one
        await _addTodoToCalendar(todo);
        return;
      }
      
      // Create updated event
      final event = Event(
        id: existingEvent.id,
        title: todo.title,
        description: todo.description,
        start: todo.deadline ?? DateTime.now(),
        end: (todo.deadline ?? DateTime.now()).add(const Duration(hours: 1)),
        color: existingEvent.color,
        tag: existingEvent.tag,
        location: existingEvent.location,
        isAllDay: existingEvent.isAllDay,
        todoId: todo.id,
      );
      
      // Update calendar
      await CalendarService.updateEvent(event.id, event);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar event updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating calendar event: $e')),
      );
    }
  }
  
  // Remove a todo from the calendar
  Future<void> _removeFromCalendar(Todo todo) async {
    try {
      if (todo.eventId != null) {
        await CalendarService.deleteEvent(todo.eventId!);
        
        // Update todo to reflect removal from calendar
        final updatedTodo = await TodoService.updateTodo(todo.id!, {
          'title': todo.title,
          'description': todo.description,
          'priority': todo.priority,
          'deadline': todo.deadline?.toIso8601String(),
          'added_to_calendar': false,
          'event_id': null,
        });
        
        // Update local todo
        setState(() {
          final index = _todos.indexWhere((t) => t.id == todo.id);
          if (index != -1) {
            _todos[index] = Todo(
              id: updatedTodo['id'],
              title: updatedTodo['title'],
              description: updatedTodo['description'] ?? '',
              completed: updatedTodo['is_completed'],
              priority: updatedTodo['priority'].toString().toLowerCase(),
              deadline: updatedTodo['deadline'] != null ? DateTime.parse(updatedTodo['deadline']) : null,
              addedToCalendar: false,
              eventId: null,
            );
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from calendar')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from calendar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodos,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    List<Todo> filteredTodos = _todos;
    
    if (_selectedFilter == 'completed') {
      filteredTodos = _todos.where((todo) => todo.completed).toList();
    } else if (_selectedFilter == 'active') {
      filteredTodos = _todos.where((todo) => !todo.completed).toList();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.background,
            colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterTab('all', 'All'),
                  _buildFilterTab('active', 'Active'),
                  _buildFilterTab('completed', 'Completed'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredTodos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(
                                  color: colorScheme.onBackground.withOpacity(0.6),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index];
                            return _buildTodoItem(todo);
                          },
                        ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showAddTaskDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterTab(String filter, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == filter;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? colorScheme.primary 
                : colorScheme.onBackground.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'high':
          return colorScheme.secondary; 
        case 'normal':
          return colorScheme.primary;
        case 'low':
          return colorScheme.tertiary;
        default:
          return colorScheme.primary;
      }
    }
    
    IconData getPriorityIcon(String priority) {
      switch (priority) {
        case 'high':
          return Icons.flag;
        case 'normal':
          return Icons.flag_outlined;
        case 'low':
          return Icons.outlined_flag;
        default:
          return Icons.flag_outlined;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Checkbox(
            value: todo.completed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? value) {
              _toggleTodoCompletion(todo);
            },
            activeColor: const Color(0xFF8E9AAF),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Row(
            children: [
              if (todo.deadline != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: const Color(0xFF8E9AAF),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().format(todo.deadline!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getPriorityColor(todo.priority).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getPriorityIcon(todo.priority),
                      size: 12,
                      color: getPriorityColor(todo.priority),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todo.priority.capitalize(),
                      style: TextStyle(
                        color: getPriorityColor(todo.priority),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (todo.addedToCalendar) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.event_available,
                  size: 14,
                  color: Color(0xFF8E9AAF),
                ),
              ],
            ],
          ),
          children: [
            if (todo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    todo.description,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showAddTaskDialog(todo: todo),
                    color: const Color(0xFF8E9AAF),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      _deleteTodo(todo);
                    },
                    color: const Color(0xFFEFD3D7),
                  ),
                  if (!todo.addedToCalendar && todo.deadline != null)
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Add to Calendar'),
                      onPressed: () {
                        setState(() {
                          todo.addedToCalendar = true;
                          _updateTodo(todo);
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8FB3A9),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog({Todo? todo}) {
    final isEditing = todo != null;
    final titleController = TextEditingController(text: isEditing ? todo.title : '');
    final descriptionController = TextEditingController(text: isEditing ? todo.description : '');
    
    DateTime? selectedDate = isEditing ? todo.deadline : null;
    String priority = isEditing ? todo.priority : 'normal';
    bool addToCalendar = isEditing ? todo.addedToCalendar : false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: const TextStyle(fontFamily: 'Georgia'),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Priority:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityButton('low', 'Low', priority, setState),
                        const SizedBox(width: 8),
                        _buildPriorityButton('normal', 'Normal', priority, setState),
                        const SizedBox(width: 8),
                        _buildPriorityButton('high', 'High', priority, setState),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Deadline:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              selectedDate == null
                                  ? 'Select date'
                                  : DateFormat.yMMMd().format(selectedDate!),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (selectedDate != null)
                      CheckboxListTile(
                        title: const Text('Add to calendar'),
                        value: addToCalendar,
                        onChanged: (value) {
                          setState(() {
                            addToCalendar = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a title')),
                      );
                      return;
                    }
                    
                    final newTodo = Todo(
                      title: titleController.text,
                      description: descriptionController.text,
                      priority: priority,
                      deadline: selectedDate,
                      addedToCalendar: addToCalendar,
                    );
                    
                    if (isEditing) {
                      newTodo.id = todo!.id;
                      _updateTodo(newTodo);
                    } else {
                      _createTodo(newTodo);
                    }
                    
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E9AAF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildPriorityButton(String value, String label, String groupValue, Function setState) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color getColor(String priority) {
      switch (priority) {
        case 'high':
          return colorScheme.secondary;
        case 'normal':
          return colorScheme.primary;
        case 'low':
          return colorScheme.tertiary;
        default:
          return colorScheme.primary;
      }
    }
    
    final isSelected = value == groupValue;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            groupValue = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? getColor(value).withOpacity(0.3) : Colors.transparent,
            border: Border.all(
              color: isSelected ? getColor(value) : Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == 'high' ? Icons.flag :
                value == 'normal' ? Icons.flag_outlined : Icons.outlined_flag,
                color: isSelected ? getColor(value) : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? getColor(value) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.background,
            colorScheme.primaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: colorScheme.primary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image upload would open here'))
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mic, color: colorScheme.primary),
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
                      fillColor: colorScheme.primaryContainer.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: colorScheme.primary,
                  child: Icon(Icons.send, color: colorScheme.onPrimary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser 
              ? colorScheme.primary
              : colorScheme.secondaryContainer,
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
              style: TextStyle(
                color: isUser 
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: (isUser ? colorScheme.onPrimary : colorScheme.onSecondary)
                    .withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 