import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Project {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> technologies;
  final String category;
  final String status;
  final String visibility;
  final List<String> tags;
  final DateTime dateStarted;
  final DateTime? dateCompleted;
  final List<ProjectFile> files;
  final Map<String, dynamic>? documentation;
  final List<Collaborator> collaborators;
  final int views;
  final int downloads;
  final bool isArchived;
  final DateTime? archivedAt;
  final int version;
  final List<ProjectVersion> versions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.technologies,
    required this.category,
    required this.status,
    required this.visibility,
    required this.tags,
    required this.dateStarted,
    this.dateCompleted,
    required this.files,
    this.documentation,
    required this.collaborators,
    required this.views,
    required this.downloads,
    required this.isArchived,
    this.archivedAt,
    required this.version,
    required this.versions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      technologies: List<String>.from(json['technologies'] ?? []),
      category: json['category'] ?? 'Other',
      status: json['status'] ?? 'In Progress',
      visibility: json['visibility'] ?? 'Private',
      tags: List<String>.from(json['tags'] ?? []),
      dateStarted: json['dateStarted'] != null
          ? DateTime.parse(json['dateStarted'])
          : DateTime.now(),
      dateCompleted: json['dateCompleted'] != null
          ? DateTime.parse(json['dateCompleted'])
          : null,
      files: (json['files'] as List?)
              ?.map((f) => ProjectFile.fromJson(f))
              .toList() ??
          [],
      documentation: json['documentation'],
      collaborators: (json['collaborators'] as List?)
              ?.map((c) => Collaborator.fromJson(c))
              .toList() ??
          [],
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
      isArchived: json['isArchived'] ?? false,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'])
          : null,
      version: json['version'] ?? 1,
      versions: (json['versions'] as List?)
              ?.map((v) => ProjectVersion.fromJson(v))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'name': name,
      'description': description,
      'technologies': technologies,
      'category': category,
      'status': status,
      'visibility': visibility,
      'tags': tags,
      'dateStarted': dateStarted.toIso8601String(),
      'dateCompleted': dateCompleted?.toIso8601String(),
      'files': files.map((f) => f.toJson()).toList(),
      'documentation': documentation,
      'collaborators': collaborators.map((c) => c.toJson()).toList(),
      'views': views,
      'downloads': downloads,
      'isArchived': isArchived,
      'archivedAt': archivedAt?.toIso8601String(),
      'version': version,
      'versions': versions.map((v) => v.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedDateStarted => DateFormat('MMM dd, yyyy').format(dateStarted);
  String get formattedDateCompleted => dateCompleted != null
      ? DateFormat('MMM dd, yyyy').format(dateCompleted!)
      : 'Not completed';

  bool get isCompleted => status == 'Completed';
  bool get isInProgress => status == 'In Progress';
  bool get isPublic => visibility == 'Public';
  bool get isPrivate => visibility == 'Private';

  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? technologies,
    String? category,
    String? status,
    String? visibility,
    List<String>? tags,
    DateTime? dateStarted,
    DateTime? dateCompleted,
    List<ProjectFile>? files,
    Map<String, dynamic>? documentation,
    List<Collaborator>? collaborators,
    int? views,
    int? downloads,
    bool? isArchived,
    DateTime? archivedAt,
    int? version,
    List<ProjectVersion>? versions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      category: category ?? this.category,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      tags: tags ?? this.tags,
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      files: files ?? this.files,
      documentation: documentation ?? this.documentation,
      collaborators: collaborators ?? this.collaborators,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      version: version ?? this.version,
      versions: versions ?? this.versions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProjectFile {
  final String id;
  final String fileName;
  final String originalName;
  final String fileType;
  final int fileSize;
  final String fileUrl;
  final String s3Key;
  final bool isEncrypted;
  final DateTime uploadedAt;

  ProjectFile({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
    required this.s3Key,
    required this.isEncrypted,
    required this.uploadedAt,
  });

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      id: json['_id'] ?? json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      originalName: json['originalName'] ?? '',
      fileType: json['fileType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      fileUrl: json['fileUrl'] ?? '',
      s3Key: json['s3Key'] ?? '',
      isEncrypted: json['isEncrypted'] ?? true,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fileName': fileName,
      'originalName': originalName,
      'fileType': fileType,
      'fileSize': fileSize,
      'fileUrl': fileUrl,
      's3Key': s3Key,
      'isEncrypted': isEncrypted,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData get icon {
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('zip') || fileType.contains('rar')) return Icons.folder_zip;
    if (fileType.contains('image')) return Icons.image;
    if (fileType.contains('video')) return Icons.video_library;
    if (fileType.contains('text') || fileType.contains('plain')) return Icons.text_fields;
    if (fileType.contains('word')) return Icons.description;
    if (fileType.contains('excel')) return Icons.table_chart;
    if (fileType.contains('powerpoint')) return Icons.slideshow;
    return Icons.attach_file;
  }
}

class Collaborator {
  final String userId;
  final String role;
  final DateTime addedAt;

  Collaborator({
    required this.userId,
    required this.role,
    required this.addedAt,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      userId: json['user'] ?? '',
      role: json['role'] ?? 'viewer',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'role': role,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class ProjectVersion {
  final int versionNumber;
  final String changes;
  final List<String> files;
  final DateTime createdAt;

  ProjectVersion({
    required this.versionNumber,
    required this.changes,
    required this.files,
    required this.createdAt,
  });

  factory ProjectVersion.fromJson(Map<String, dynamic> json) {
    return ProjectVersion(
      versionNumber: json['versionNumber'] ?? 1,
      changes: json['changes'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionNumber': versionNumber,
      'changes': changes,
      'files': files,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}