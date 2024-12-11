import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RenewMembershipScreen extends StatefulWidget {
  @override
  _RenewMembershipScreenState createState() => _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends State<RenewMembershipScreen> {
  List members = [];
  String? selectedMember;
  String? selectedSubscriptionType;

  final List<String> subscriptionTypes = ['Monthly', 'Quarterly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final response = await http.get(Uri.parse('http://10.0.2.2/Gym/read_members.php'));
    if (response.statusCode == 200) {
      setState(() {
        members = json.decode(response.body);
      });
    }
  }

  Future<void> renewMembership() async {
    if (selectedMember == null || selectedSubscriptionType == null) return;

    await http.post(
      Uri.parse('http://10.0.2.2/Gym/renew_membership.php'),
      body: {
        'member_id': selectedMember,
        'subscription_type': selectedSubscriptionType,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membership renewed!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Renew Membership')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedMember,
              hint: Text('Select Member'),
              items: members.map<DropdownMenuItem<String>>((member) {
                return DropdownMenuItem<String>(
                  value: member['id'].toString(),
                  child: Text(member['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMember = value;
                });
              },
            ),
            DropdownButton<String>(
              value: selectedSubscriptionType,
              hint: Text('Select Subscription Type'),
              items: subscriptionTypes.map<DropdownMenuItem<String>>((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubscriptionType = value;
                });
              },
            ),
            SizedBox(height: 20), // Add some space between elements
            ElevatedButton(
              onPressed: renewMembership,
              child: Text('Renew Membership'),
            ),
          ],
        ),
      ),
    );
  }
}