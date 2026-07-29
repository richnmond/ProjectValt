// frontend/lib/screens/projects/create_project_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../widgets/project/project_form.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Web Development';
  String _status = 'In Progress';
  String _visibility = 'Private';
  List<String> _technologies = [];
  List<String> _tags = [];
  final _techController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _categories = [
    'Web Development',
    'Mobile App',
    'Desktop App',
    'Game Development',
    'Machine Learning',
    'Data Science',
    'IoT',
    'Blockchain',
    'DevOps',
    'UI/UX Design',
    'Documentation',
    'Research',
    'Other',
  ];

  final List<String> _statuses = ['In Progress', 'Completed', 'Archived'];
  final List<String> _visibilities = ['Private', 'Public'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _techController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              Text(
                'Project Name',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter project name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your project',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Category
              Text(
                'Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Status
              Text(
                'Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Visibility
              Text(
                'Visibility',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _visibility,
                items: _visibilities.map((visibility) {
                  return DropdownMenuItem(
                    value: visibility,
                    child: Row(
                      children: [
                        Icon(
                          visibility == 'Public' ? Icons.public : Icons.lock,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(visibility),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _visibility = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Technologies
              Text(
                'Technologies',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _technologies.map((tech) {
                  return Chip(
                    label: Text(tech),
                    onDeleted: () {
                      setState(() {
                        _technologies.remove(tech);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _techController,
                      decoration: const InputDecoration(
                        hintText: 'Add technology',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_techController.text.isNotEmpty) {
                        setState(() {
                          _technologies.add(_techController.text);
                          _techController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tags
              Text(
                'Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add tag',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_tagController.text.isNotEmpty) {
                        setState(() {
                          _tags.add(_tagController.text);
                          _tagController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create Project'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final data = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'category': _category,
      'status': _status,
      'visibility': _visibility,
      'technologies': _technologies,
      'tags': _tags,
    };
    
    final provider = context.read<ProjectProvider>();
    final project = await provider.createProject(data);
    
    if (project != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/projects/${project.id}');
    }
  }
}