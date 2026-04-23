import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDebugPage extends StatefulWidget {
  const SecureStorageDebugPage({super.key});

  @override
  State<SecureStorageDebugPage> createState() => _SecureStorageDebugPageState();
}

class _SecureStorageDebugPageState extends State<SecureStorageDebugPage> {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Map<String, String> _items = <String, String>{};
  bool _isLoading = true;
  bool _isMaskEnabled = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    Map<String, String>? loadedItems;
    String? loadErrorMessage;
    try {
      final values = await _storage.readAll();
      loadedItems = Map<String, String>.fromEntries(
        values.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
    } catch (error) {
      loadErrorMessage = '读取失败: $error';
    }
    if (!mounted) return;
    setState(() {
      if (loadedItems != null) {
        _items = loadedItems;
      }
      _errorMessage = loadErrorMessage;
      _isLoading = false;
    });
  }

  Future<void> _deleteByKey(String key) async {
    await _storage.delete(key: key);
    await _loadItems();
  }

  Future<void> _deleteAll() async {
    await _storage.deleteAll();
    await _loadItems();
  }

  String _displayValue(String value) {
    if (!_isMaskEnabled) return value;
    if (value.isEmpty) return '(空字符串)';
    if (value.length <= 4) return '*' * value.length;
    final prefix = value.substring(0, 2);
    final suffix = value.substring(value.length - 2);
    return '$prefix${'*' * (value.length - 4)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage Debug'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: _isLoading ? null : _loadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.all(12),
            child: const Text(
              '仅用于本地调试，请勿在生产环境保留该页面入口。',
            ),
          ),
          SwitchListTile(
            title: const Text('值脱敏显示'),
            subtitle: const Text('关闭后将展示完整明文'),
            value: _isMaskEnabled,
            onChanged: (value) {
              setState(() {
                _isMaskEnabled = value;
              });
            },
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SelectableText.rich(
                TextSpan(
                  text: _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Expanded(
            child: _buildListContent(),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _items.isEmpty ? null : _deleteAll,
                  child: const Text('清空全部键值'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('当前没有存储内容'),
      );
    }
    final entries = _items.entries.toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemBuilder: (_, index) {
        final entry = entries[index];
        final value = _displayValue(entry.value);
        return Card(
          child: ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: SelectableText(value),
            trailing: IconButton(
              tooltip: '删除该键',
              onPressed: () => _deleteByKey(entry.key),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: entries.length,
    );
  }
}
