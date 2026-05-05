import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const PCControlApp());
}

class PCControlApp extends StatelessWidget {
  const PCControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _systemInfo;
  List<dynamic>? _processes;
  Map<String, dynamic>? _networkInfo;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final results = await Future.wait([
        ApiService.getSystemInfo(),
        ApiService.getProcesses(),
        ApiService.getNetworkInfo(),
      ]);

      setState(() {
        _systemInfo = results[0];
        _processes = results[1]['data'];
        _networkInfo = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _killProcess(int processId) async {
    try {
      await ApiService.killProcess(processId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Process $processId killed')),
      );
      _loadAllData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to kill process: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Control'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSystemInfo(),
          const SizedBox(height: 24),
          _buildProcesses(),
          const SizedBox(height: 24),
          _buildNetworkInfo(),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    if (_systemInfo == null) return const SizedBox();

    final data = _systemInfo!['data'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('System Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoItem('CPU', '${data['cpu']['usage']}%')),
                Expanded(child: _buildInfoItem('Memory', '${data['memory']['percentage']}%')),
                Expanded(child: _buildInfoItem('Disk', '${data['disk']['percentage']}%')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProcesses() {
    if (_processes == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Processes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...(_processes!.map((process) => ListTile(
              title: Text(process['name']),
              subtitle: Text('CPU: ${process['cpu']}% | Memory: ${process['memory']}MB'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _killProcess(process['id']),
              ),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkInfo() {
    if (_networkInfo == null) return const SizedBox();

    final data = _networkInfo!['data'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Network Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Interface: ${data['interface']}'),
            Text('IP: ${data['ip']}'),
            Text('Upload: ${data['upload']} KB/s'),
            Text('Download: ${data['download']} KB/s'),
            Text('Latency: ${data['latency']} ms'),
          ],
        ),
      ),
    );
  }
}
