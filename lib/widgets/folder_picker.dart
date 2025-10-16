import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../services/folder_service.dart';
import '../services/sync_service.dart';

/// FolderSelection
/// Wrapper to distinguish between canceled and selected folder
class FolderSelection {
  final Folder? folder;
  final bool wasCanceled;

  FolderSelection({this.folder, this.wasCanceled = false});
  
  factory FolderSelection.canceled() => FolderSelection(wasCanceled: true);
  factory FolderSelection.noFolder() => FolderSelection(folder: null, wasCanceled: false);
  factory FolderSelection.selected(Folder folder) => FolderSelection(folder: folder, wasCanceled: false);
}

/// FolderPicker
/// Dialog to select or create a folder for a note
class FolderPicker extends StatefulWidget {
  final String? currentFolderId;
  final VoidCallback? onFolderChanged;

  const FolderPicker({
    super.key,
    this.currentFolderId,
    this.onFolderChanged,
  });

  @override
  State<FolderPicker> createState() => _FolderPickerState();
}

class _FolderPickerState extends State<FolderPicker> {
  final FolderService _folderService = FolderService();
  List<Folder> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    try {
      final folders = await _folderService.getAllFoldersWithNoteCounts();
      setState(() {
        _folders = folders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading folders: $e')),
        );
      }
    }
  }

  void _selectFolder(Folder? folder) {
    if (folder == null) {
      Navigator.of(context).pop(FolderSelection.noFolder());
    } else {
      Navigator.of(context).pop(FolderSelection.selected(folder));
    }
    widget.onFolderChanged?.call();
  }

  void _createNewFolder() async {
    final result = await showDialog<Folder>(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );

    if (result != null) {
      await _loadFolders();
      _selectFolder(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Move to Folder'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // No folder option
                  ListTile(
                    leading: const Icon(Icons.folder_off),
                    title: const Text('No Folder'),
                    trailing: widget.currentFolderId == null
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () => _selectFolder(null),
                  ),
                  const Divider(),
                  // Folder list
                  Flexible(
                    child: _folders.isEmpty
                        ? const Center(
                            child: Text('No folders yet'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _folders.length,
                            itemBuilder: (context, index) {
                              final folder = _folders[index];
                              final isSelected = folder.folderId == widget.currentFolderId;
                              
                              return ListTile(
                                leading: Text(
                                  folder.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(folder.name),
                                subtitle: Text('${folder.noteCount} notes'),
                                trailing: isSelected
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : null,
                                onTap: () => _selectFolder(folder),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(FolderSelection.canceled()),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _createNewFolder,
          icon: const Icon(Icons.add),
          label: const Text('New Folder'),
        ),
      ],
    );
  }
}

/// CreateFolderDialog
/// Dialog to create a new folder
class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final FolderService _folderService = FolderService();
  final SyncService _syncService = SyncService();
  final TextEditingController _nameController = TextEditingController();
  String _selectedColor = '#2196F3';
  String _selectedIcon = '📁';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    final name = _nameController.text.trim();
    
    // Validate
    final error = _folderService.validateFolderName(name);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final folder = Folder()
        ..name = name
        ..color = _selectedColor
        ..icon = _selectedIcon
        ..ownerId = ''; // Will be set by sync service

      final folderId = await _folderService.createFolder(folder);
      
      // Get the created folder with its ID
      final createdFolder = await _folderService.getFolder(folderId);
      
      // Sync to Firestore
      if (createdFolder != null) {
        await _syncService.pushFolder(createdFolder);
      }
      
      if (mounted && createdFolder != null) {
        Navigator.of(context).pop(createdFolder);
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating folder: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Folder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Folder Name',
                hintText: 'Enter folder name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            
            // Icon picker
            const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _folderService.getAvailableIcons().map((icon) {
                final isSelected = icon == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Color picker
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _folderService.getAvailableColors().map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createFolder,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
