// lib/widgets/project/project_form.dart
import 'package:flutter/material.dart';
import '../../models/project_model.dart';

class ProjectForm extends StatefulWidget {
  final Project? project;
  final Function(Map<String, dynamic>) onSubmit;

  const ProjectForm({
    super.key,
    this.project,
    required this.onSubmit,
  });

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Web Development';
  String _status = 'In Progress';
  String _visibility = 'Private';
  final List<String> _technologies = [];
  final List<String> _tags = [];
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
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _category = widget.project!.category;
      _status = widget.project!.status;
      _visibility = widget.project!.visibility;
      _technologies.addAll(widget.project!.technologies);
      _tags.addAll(widget.project!.tags);
    }
  }

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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Name
          Text(
            'Project Name *',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Description
          Text(
            'Description *',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Category
          Text(
            'Category *',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Status
          Text(
            'Status',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Visibility
          Text(
            'Visibility',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Technologies
          Text(
            'Technologies',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                    hintText: 'Add technology (e.g., Flutter)',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _addTechnology(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTechnology,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tags
          Text(
            'Tags',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                    hintText: 'Add tag (e.g., api)',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTag,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.project != null ? 'Update Project' : 'Create Project'),
            ),
          ),
        ],
      ),
    );
  }

  void _addTechnology() {
    if (_techController.text.isNotEmpty) {
      setState(() {
        _technologies.add(_techController.text);
        _techController.clear();
      });
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _submitForm() {
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

    widget.onSubmit(data);
  }
}