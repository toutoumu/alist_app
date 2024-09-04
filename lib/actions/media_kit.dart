part of 'part.dart';

enum VideoSettingType { rate }

const _videoRateValues = [0.5, 0.8, 1, 1.5, 2, 2.5, 3, 3, 5, 4];

class MediaKitPlayer extends ConsumerStatefulWidget {
  final String url;
  final FsModel model;

  const MediaKitPlayer({super.key, required this.url, required this.model});

  @override
  ConsumerState<MediaKitPlayer> createState() => _MediaKitPlayerState();
}

class _MediaKitPlayerState extends ConsumerState<MediaKitPlayer> {
  late final player = Player()..open(Media(widget.url));
  late final controller = VideoController(player);

  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
            seekBarThumbColor: context.primaryColor,
            seekBarPositionColor: context.primaryColor,
            bottomButtonBarMargin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.only(
              bottom: context.paddingBottom+12,
              left: 12,right: 12
            ),
            bottomButtonBar: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MaterialPositionIndicator(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MaterialCustomButton(onPressed: _showSettingMenu),
                        MaterialCustomButton(onPressed: _showOtherList,icon: const Icon(Icons.menu),),
                        const MaterialPlayOrPauseButton(),
                        const MaterialFullscreenButton(),
                      ],
                    ),
                  ],
                ),
              )
            ]),
        fullscreen: const MaterialVideoControlsThemeData(),
        child: Video(controller: controller));
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  Future<void> _showSettingMenu() async {
    final nav = context.nav;
    final type = await showMaterialModalBottomSheet<VideoSettingType>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: context.paddingBottom),
          controller: ModalScrollController.of(context),
          child: Column(
            children: [
              ListTile(
                title: const Text("播放倍速"),
                leading: const Icon(Icons.play_arrow_outlined),
                onTap: () => nav.pop(VideoSettingType.rate),
              )
            ],
          ),
        );
      },
    );
    switch (type) {
      case null:
        {}
      case VideoSettingType.rate:
        {
          delayFunction(() async {
            final v = await showModalBottomSheet<double>(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._videoRateValues.map(
                            (e) => ListTile(
                          title: Text('$e'),
                          onTap: () => nav.pop(e),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
            if (v != null) {
              player.setRate(v);
            }
          },);
        }
    }
  }

  Future<void> _showOtherList() async {
    final select = await showMaterialModalBottomSheet<FsModel>(context: context, builder: (context) {
      return SizedBox(
        height: context.screenHeight * 0.8,
        child: CustomScrollView(
          slivers: [
            SliverList.list(children: [
              ...widget.model.currentDirAllFiles.map((element) {
                return ListTile(
                  title: Text(element.name),
                  trailing: Text(element.sizeFormat),
                  onTap: () => context.nav.pop(element),
                );
              },)
            ])
          ],
        ),
      );
    },);
    if(select!=null){
      try{
        final info = await select.requestInfo();
        await player.open(Media(info.rawUrl));
      } on BaseApiException catch(e){
        showToast(e.getMessage);
      }
    }
  }
}
