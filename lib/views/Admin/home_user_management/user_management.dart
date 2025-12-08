import 'package:flutter/material.dart';
import 'package:wood_service/views/Admin/admin_model.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [
    User(
      id: '1',
      name: 'John Smith',
      email: 'john@example.com',
      type: 'Buyer',
      avatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      isBlocked: false,
      joinDate: DateTime(2024, 1, 15),
    ),

    User(
      id: '3',
      name: 'Mike Wilson',
      email: 'mike@example.com',
      type: 'Buyer',
      avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      isBlocked: true,
      joinDate: DateTime(2024, 1, 10),
    ),
    User(
      id: '4',
      name: 'Emma Davis',
      email: 'emma@example.com',
      type: 'Seller',
      avatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      isBlocked: false,
      joinDate: DateTime(2024, 3, 5),
    ),
    User(
      id: '5',
      name: 'Robert Brown',
      email: 'robert@example.com',
      type: 'Buyer',
      avatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      isBlocked: false,
      joinDate: DateTime(2024, 2, 28),
    ),
    User(
      id: '6',
      name: 'Lisa Anderson',
      email: 'lisa@example.com',
      type: 'Seller',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      isBlocked: false,
      joinDate: DateTime(2024, 1, 30),
    ),
    User(
      id: '7',
      name: 'David Miller',
      email: 'david@example.com',
      type: 'Buyer',
      avatar:
          'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=150',
      isBlocked: true,
      joinDate: DateTime(2024, 3, 12),
    ),
    User(
      id: '8',
      name: 'Jennifer Taylor',
      email: 'jennifer@example.com',
      type: 'Seller',
      avatar:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      isBlocked: false,
      joinDate: DateTime(2024, 2, 15),
    ),
  ];

  String filter = 'All';

  List<User> get filteredUsers {
    if (filter == 'All') return users;
    if (filter == 'Buyers')
      return users.where((user) => user.type == 'Buyer').toList();
    if (filter == 'Sellers')
      return users.where((user) => user.type == 'Seller').toList();
    if (filter == 'Pending')
      return users.where((user) => user.isBlocked == false).toList();
    if (filter == 'Blocked')
      return users.where((user) => user.isBlocked == true).toList();
    return users;
  }

  void _toggleBlockUser(User user) {
    setState(() {
      users = users.map((u) {
        if (u.id == user.id) {
          return User(
            id: u.id,
            name: u.name,
            email: u.email,
            type: u.type,
            avatar: u.avatar,
            isBlocked: !u.isBlocked,
            joinDate: u.joinDate,
          );
        }
        return u;
      }).toList();
    });

    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user.name} ${user.isBlocked ? 'unblocked' : 'blocked'}',
        ),
        backgroundColor: user.isBlocked ? Colors.green : Colors.red,
      ),
    );
  }

  void _viewUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.avatar),
                radius: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${user.name}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Email: ${user.email}'),
            Text('Type: ${user.type}'),
            Text('Status: ${user.isBlocked ? 'Blocked' : 'Active'}'),
            Text('Joined: ${_formatDate(user.joinDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Statistics Cards
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Users',
                  users.length.toString(),
                  Colors.blue,
                ),
                SizedBox(width: 10),
                _buildStatCard(
                  'Buyers',
                  users.where((u) => u.type == 'Buyer').length.toString(),
                  Colors.green,
                ),
                SizedBox(width: 10),
                _buildStatCard(
                  'Sellers',
                  users.where((u) => u.type == 'Seller').length.toString(),
                  Colors.orange,
                ),
                SizedBox(width: 10),
                _buildStatCard(
                  'Blocked',
                  users.where((u) => u.isBlocked).length.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Buyers', 'Sellers', 'Pending', 'Blocked']
                    .map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: filter == type,
                          onSelected: (selected) =>
                              setState(() => filter = type),
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // User List
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) =>
                        _buildUserCard(filteredUsers[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
              backgroundColor: Colors.grey[200],
              radius: 25,
            ),

            const SizedBox(width: 12),

            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Type
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: user.isBlocked ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        user.type,
                        style: TextStyle(
                          color: user.type == 'Buyer'
                              ? Colors.blue
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  const SizedBox(height: 8),

                  // Status and Join Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isBlocked
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.isBlocked ? 'Blocked' : 'Active',
                          style: TextStyle(
                            color: user.isBlocked ? Colors.red : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'Joined ${_formatDate(user.joinDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.visibility, size: 20, color: Colors.blue),
                  onPressed: () => _viewUserDetails(user),
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  icon: Icon(
                    user.isBlocked ? Icons.lock_open : Icons.block,
                    size: 20,
                    color: user.isBlocked ? Colors.green : Colors.red,
                  ),
                  onPressed: () => _toggleBlockUser(user),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
