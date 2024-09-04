part of '../part.dart';

class MobileLeftDrawerWidget extends ConsumerWidget {
  const MobileLeftDrawerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(sitesStateProvider);
    return domains.when(
      data: (data) {
        return Drawer(
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          surfaceTintColor: context.cardColor,
          shadowColor: context.cardColor,
          backgroundColor: context.cardColor,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                          top: context.paddingTop,
                          bottom: context.paddingBottom,
                          left: 10,
                          right: 10),
                      sliver: SliverList.list(children: [
                        Text(appName, style: context.textTheme.titleLarge),
                        const Divider(),
                        Text('切换站点', style: context.textTheme.labelSmall),
                        ...data.map((e) {
                          return _Item(item: e);
                        }),
                        const Divider(),
                        ListTile(
                          onTap: () {
                            context.nav
                              ..pop()
                              ..pop();
                          },
                          title: const Text('回到主界面'),
                        )
                      ]),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () {
                  final nav = context.nav;
                  nav.pop();
                  const MySettingPage().push(context);
                },
                trailing: const CupertinoListTileChevron(),
              )
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text('$error'),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _Item extends ConsumerStatefulWidget {
  final DomainAccount item;

  const _Item({required this.item});

  @override
  ConsumerState<_Item> createState() => _ItemState();
}

class _ItemState extends ConsumerState<_Item> with AutomaticKeepAliveClientMixin {
  late DomainAccount item = widget.item;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return pp.ChangeNotifierProvider(
        create: (BuildContext context) {
          return item..startGetState();
        },
        child: ListTile(
            leading: const DomainLogo(),
            title: Text(item.name),
            onTap: () {
              context.hideKeyBoard();
              context.nav.pop();
              Future.microtask(() => ref.switchApplication(item));
            },
            trailing: item.isEq(ref.activeDomain)
                ? const Icon(LineIcons.check)
                : null));
  }

  @override
  bool get wantKeepAlive => true;
}
