import 'package:flutter/material.dart';
import 'package:gym/pages/renew_membership_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List members = [];
  List filteredMembers = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String? selectedStatus;
  String? selectedSubscriptionType;

  final List<String> statuses = ['Active', 'Inactive'];
  final List<String> subscriptionTypes = ['Monthly', 'Quarterly', 'Yearly'];

  // Define color constants
  static const Color primaryColor = Colors.green; // Green color for the theme
  static const Color secondaryColor = Colors.black; // Black color for the theme

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final response = await http.get(Uri.parse('http://10.0.2.2/Gym/read_members.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        members = data.map((member) {
          return {
            'id': int.parse(member['id'].toString()), // Ensure ID is parsed as int
            'name': member['name'],
            'email': member['email'],
            'phone': member['phone'],
            'subscription_type': member['subscription_type'],
            'status': member['status'],
          };
        }).toList();
        filteredMembers = List.from(members); // Initialize the filtered list
      });
    }
  }

  Future<void> addMember() async {
    await http.post(
      Uri.parse('http://10.0.2.2/Gym/create_member.php'),
      body: {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'subscription_type': selectedSubscriptionType,
        'status': selectedStatus,
      },
    );
    fetchMembers();
    showSnackBar('Member added successfully!'); // Alert for add operation
  }

  Future<void> updateMember(int id) async {
    await http.post(
      Uri.parse('http://10.0.2.2/Gym/update_member.php'),
      body: {
        'id': id.toString(),
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'subscription_type': selectedSubscriptionType,
        'status': selectedStatus,
      },
    );
    fetchMembers();
    showSnackBar('Member updated successfully!'); // Alert for update operation
  }

  Future<void> deleteMember(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await http.post(
        Uri.parse('http://10.0.2.2/Gym/delete_member.php'),
        body: {'id': id.toString()},
      );
      fetchMembers();
      showSnackBar('Member deleted successfully!'); // Alert for delete operation
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openMemberDialog([Map? member]) {
    if (member != null) {
      nameController.text = member['name'];
      emailController.text = member['email'];
      phoneController.text = member['phone'];
      selectedSubscriptionType = subscriptionTypes.contains(member['subscription_type'])
          ? member['subscription_type']
          : null; // Handle unexpected values
      selectedStatus = statuses.contains(member['status']) ? member['status'] : null;
    } else {
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      selectedSubscriptionType = null;
      selectedStatus = null;
 }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member == null ? 'Add Member' : 'Update Member'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
              DropdownButtonFormField<String>(
                value: selectedSubscriptionType,
                decoration: InputDecoration(labelText: 'Subscription Type'),
                items: subscriptionTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubscriptionType = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(labelText: 'Status'),
                items: statuses
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (member == null) {
                addMember();
              } else {
                updateMember(member['id']);
              }
              Navigator.pop(context);
            },
            child: Text(member == null ? 'Add' : 'Update'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void filterMembers(String query) {
    setState(() {
      filteredMembers = members
          .where((member) =>
              member['name'].toLowerCase().contains(query.toLowerCase()) ||
              member['email'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Members'),
        backgroundColor: secondaryColor, // Set AppBar color to black
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMembers,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: filterMembers,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                return ListTile(
                  title: Text(member['name']),
                  subtitle: Text('Email: ${member['email']} | Phone: ${member['phone']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => openMemberDialog(member),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteMember(member['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => openMemberDialog(),
            child: Text('Add Member'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor), // Set button color to green
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RenewMembershipScreen()),
              );
            },
            child: Text('Go to Renew Page'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor), // Set button color to green
          ),
        ],
      ),
    );
  }
}

class RenewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Renew Subscription'), backgroundColor: _HomeScreenState.secondaryColor),
      body: Center(child: Text('Renew Subscription Page')),
    );
  }
}