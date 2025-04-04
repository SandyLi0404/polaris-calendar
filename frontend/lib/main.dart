import 'package:flutter/material.dart';

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
        primaryColor: const Color(0xFF6C5CE7),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C5CE7),
          secondary: Color(0xFFA29BFE),
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

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 80,
            color: Color(0xFF6C5CE7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Calendar View',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'You would see your calendar events here',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildEventTile(
                  'Team Meeting',
                  'Today at 2:00 PM',
                  Icons.people,
                  const Color(0xFFFF5252),
                ),
                const Divider(),
                _buildEventTile(
                  'Doctor Appointment',
                  'Tomorrow at 10:00 AM',
                  Icons.medical_services,
                  const Color(0xFF2ECC71),
                ),
                const Divider(),
                _buildEventTile(
                  'Project Deadline',
                  'Friday at 5:00 PM',
                  Icons.assignment_turned_in,
                  const Color(0xFF3498DB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
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