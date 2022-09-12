part of 'view.dart';

class _ImageSection extends StatelessWidget {
  const _ImageSection();

  @override
  Widget build(BuildContext context) {
    final controller = AddMemoryController.instance;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white10,
      ),
      child: Scope(builder: (_) {
        return controller.image.value == null
            ? const _PickImage()
            : Image.file(File(controller.image.value!.path));
      }),
    );
  }
}

class _PickImage extends StatelessWidget {
  const _PickImage();

  @override
  Widget build(BuildContext context) {
    final controller = AddMemoryController.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () => controller.pickImage(ImageSource.camera),
          icon: const Icon(
            Icons.camera,
            size: 50,
          ),
        ),
        IconButton(
          onPressed: () => controller.pickImage(ImageSource.gallery),
          icon: const Icon(
            Icons.image,
            size: 50,
          ),
        )
      ],
    );
  }
}
