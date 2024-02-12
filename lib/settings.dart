import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy & Security'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySecuritySettingsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Help and Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
}

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  AccountSettingsPageState createState() => AccountSettingsPageState();
}

class AccountSettingsPageState extends State<AccountSettingsPage> {
  // Sample user details (replace with your actual user data)
  String name = 'John Doe';
  String username = 'johndoe';
  String email = 'john.doe@example.com';
  String phoneNumber = '+1 123-456-7890';

  Map<String, bool> isEditing = {
    'Name': false,
    'Username': false,
    'Email': false,
    'Phone Number': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Account Settings'),
            if (isEditing.containsValue(true))
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  setState(() {
                    isEditing = isEditing.map((key, value) => MapEntry(key, false));
                  });
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Icon (Editable)
            GestureDetector(
              onTap: () {
                // Implement profile icon editing/uploading functionality
              },
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/default_profile_icon.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            // User Profile Details
            _buildEditableField('Name', name, Icons.person),
            _buildEditableField('Username', username, Icons.account_circle),
            _buildEditableField('Email', email, Icons.email),
            _buildEditableField('Phone Number', phoneNumber, Icons.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(
            child: isEditing[label]!
                ? TextField(
                    controller: TextEditingController(text: value),
                    onChanged: (newValue) {
                      _updateFieldValue(label, newValue);
                    },
                  )
                : Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = isEditing.map((key, value) =>
                    key == label ? MapEntry(key, true) : MapEntry(key, false));
              });
            },
          ),
        ],
      ),
    );
  }

  void _updateFieldValue(String fieldName, String newValue) {
    setState(() {
      switch (fieldName) {
        case 'Name':
          name = newValue;
          break;
        case 'Username':
          username = newValue;
          break;
        case 'Email':
          email = newValue;
          break;
        case 'Phone Number':
          phoneNumber = newValue;
          break;
      }
    });
  }
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  NotificationSettingsPageState createState() => NotificationSettingsPageState();
}

class NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool? pushNotifications = true;
  bool? emailNotifications = false;
  bool? smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNotificationSetting(
              'Push Notifications',
              Icons.notifications,
              pushNotifications ?? false,
              (value) {
                setState(() {
                  pushNotifications = value;
                });
              },
            ),
            _buildNotificationSetting(
              'Email Notifications',
              Icons.email,
              emailNotifications ?? false,
              (value) {
                setState(() {
                  emailNotifications = value;
                });
              },
            ),
            _buildNotificationSetting(
              'SMS Notifications',
              Icons.sms,
              smsNotifications ?? false,
              (value) {
                setState(() {
                  smsNotifications = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSetting(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Switch(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
          },
        ),
      ),
    );
  }
}

class PrivacySecuritySettingsPage extends StatefulWidget {
  const PrivacySecuritySettingsPage({Key? key}) : super(key: key);

  @override
  PrivacySecuritySettingsPageState createState() => PrivacySecuritySettingsPageState();
}

class PrivacySecuritySettingsPageState extends State<PrivacySecuritySettingsPage> {
  bool? twoFactorAuthentication = false;
  bool? authenticationApp = false;
  bool? textMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChangePasswordButton(),
            const SizedBox(height: 16),
            _buildTwoFactorAuthenticationSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return ElevatedButton(
      onPressed: () {
        // Implement change password functionality
      },
      child: const Text('Change Password'),
    );
  }

  Widget _buildTwoFactorAuthenticationSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Two-Factor Authentication',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Enable Two-Factor Authentication'),
          value: twoFactorAuthentication ?? false,
          onChanged: (value) {
            setState(() {
              twoFactorAuthentication = value;
              authenticationApp = false;
              textMessage = false;
            });
          },
        ),
        if (twoFactorAuthentication ?? false) ...[
          _buildTwoFactorOption('Authentication App', authenticationApp ?? false, (value) {
            setState(() {
              authenticationApp = value;
              textMessage = !value; // Ensure only one option is selected
            });
          }),
          _buildTwoFactorOption('Text Message (SMS)', textMessage ?? false, (value) {
            setState(() {
              textMessage = value;
              authenticationApp = !value; // Ensure only one option is selected
            });
          }),
        ],
      ],
    );
  }

  Widget _buildTwoFactorOption(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: (newValue) {
          onChanged(newValue!);
        },
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help and Support'),
      ),
      body: const Center(
        child: Text('Help meeeee'),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Center(
        child: Text('About whaatt'),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SettingsPage(),
  ));
}