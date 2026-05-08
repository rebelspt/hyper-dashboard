enum ContainerStatus {
  running('Running', 'running', false, true),
  exited('Exited', 'exited', true, false),
  paused('Paused', 'paused', false, true),
  created('Created', 'created', true, false),
  dead('Dead', 'exited', true, false),
  restarting('Restarting', 'running', false, true),
  unknown('Unknown', 'exited', false, false);

  final String label;
  final String cssMod;
  final bool canStart;
  final bool canStop;

  const ContainerStatus(this.label, this.cssMod, this.canStart, this.canStop);

  static ContainerStatus from(String? v) => switch (v?.toLowerCase()) {
        'running' => running,
        'exited' => exited,
        'paused' => paused,
        'created' => created,
        'dead' => dead,
        'restarting' => restarting,
        _ => unknown,
      };
}

class DockerContainer {
  final String id;
  final String shortId;
  final String name;
  final String image;
  final ContainerStatus status;
  final String statusText;

  const DockerContainer({
    required this.id,
    required this.shortId,
    required this.name,
    required this.image,
    required this.status,
    required this.statusText,
  });

  factory DockerContainer.fromJson(Map<String, dynamic> j) {
    final id = j['Id'] as String? ?? '';
    final names = (j['Names'] as List?)?.cast<String>() ?? [];
    final rawName = names.isNotEmpty
        ? names.first
        : id.substring(0, id.length.clamp(0, 12));
    return DockerContainer(
      id: id,
      shortId: id.substring(0, id.length.clamp(0, 12)),
      name: rawName.startsWith('/') ? rawName.substring(1) : rawName,
      image: j['Image'] as String? ?? '',
      status: ContainerStatus.from(j['State'] as String?),
      statusText: j['Status'] as String? ?? '',
    );
  }
}
