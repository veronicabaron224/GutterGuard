import 'package:flutter/material.dart';
import 'firebase_data.dart';

class MaintenanceHistory extends StatefulWidget {
  const MaintenanceHistory({super.key});

  @override
  MaintenanceHistoryState createState() => MaintenanceHistoryState();
}

class MaintenanceHistoryState extends State<MaintenanceHistory> {
  @override
  void initState() {
    super.initState();
    fetchGutterLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchGutterLocations(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData) {
              List<GutterLocation> locations = snapshot.data!['locations'];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 17.0),
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    GutterLocation location = locations[index];
                    String statusText = getStatusText(location.maintenanceStatus);
                    return ListTile(
                      title: Text(location.name),
                      subtitle: Text('Status: $statusText'),
                      trailing: Icon(location.isClogged ? Icons.warning : Icons.check_circle),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: Text('Error fetching data.'),
              );
            }
          }
        },
      ),
    );
  }

  String getStatusText(String status) {
    switch (status) {
      case 'nomaintenancereq':
        return 'No maintenance required';
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In progress';
      default:
        return 'Unknown';
    }
  }
}