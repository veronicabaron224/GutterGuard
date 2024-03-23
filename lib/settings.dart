import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column (
          children: [
            _buildOption('Account', Icons.account_circle_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
              );
            }),
            _buildOption('Notifications', Icons.notifications_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
              );
            }),
            _buildOption('Privacy & Security', Icons.security_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySecuritySettingsPage()),
              );
            }),
            _buildOption('Help and Support', Icons.help_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            }),
            _buildOption('About', Icons.info_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            }),
            _buildLogoutOption(),
          ],
        ),
      )
    );
  }

  Widget _buildOption(String label, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(2.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Text(
          '>',
          style: TextStyle(fontSize: 20),
        ),
      ),
    ),
  );
}

  Widget _buildLogoutOption() {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(2.0),
      child: const ListTile(
        leading: Icon(
            Icons.logout,
            color: Colors.red,
          ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  AccountSettingsPageState createState() => AccountSettingsPageState();
}

class AccountSettingsPageState extends State<AccountSettingsPage> {
  String name = 'Poncholo Riego de Dios';
  String username = 'poncholoriegodedios';
  String email = 'poncholo.boi@example.com';
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
        padding: const EdgeInsets.all(29.0),
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
            const SizedBox(height: 12),
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
  const NotificationSettingsPage({super.key});

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
  const PrivacySecuritySettingsPage({super.key});

  @override
  PrivacySecuritySettingsPageState createState() => PrivacySecuritySettingsPageState();
}

class PrivacySecuritySettingsPageState extends State<PrivacySecuritySettingsPage> {
  bool? twoFactorAuthentication = false;
  bool? authenticationApp = false;
  bool? textMessage = false;

  // Fields for change password
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool showChangePasswordFields = false;

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
            _buildTwoFactorAuthenticationSwitch(),
            const SizedBox(height: 16),
            _buildChangePasswordButton(),
            const SizedBox(height: 30),
            _buildChangePasswordFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorAuthenticationSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
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

  Widget _buildChangePasswordButton() {
    return InkWell(
      onTap: () {
        // Toggle the visibility of change password fields
        setState(() {
          showChangePasswordFields = !showChangePasswordFields;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordFields() {
    return Visibility(
      visible: showChangePasswordFields,
      child: Column(
        children: [
          _buildPasswordTextField(oldPasswordController, 'Old Password'),
          _buildPasswordTextField(newPasswordController, 'New Password'),
          _buildPasswordTextField(confirmPasswordController, 'Confirm Password'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Change password logic here
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

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
  const AboutPage({super.key});

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