class FrameTemplate {
  final String path;
  final String type; // 'asset' atau 'file'
  final String layout; // 'strip_1x4', 'strip_1x3', 'grid_2x2', 'grid_3x2'
  final int requiredPhotos;

  FrameTemplate({
    required this.path, 
    required this.type, 
    required this.layout,
    required this.requiredPhotos,
  });
}