import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/home_dashboard/models/directory_worker.dart';
import 'package:kazi/home_dashboard/screens/worker_preview_screen.dart';
import 'package:kazi/home_dashboard/services/worker_directory_store.dart';
import 'package:kazi/home_dashboard/widgets/worker_photo.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _searchController = TextEditingController();
  TradeCategory? _selectedTrade;

  @override
  void initState() {
    super.initState();
    WorkerDirectoryStore.instance.addListener(_onDirectoryChanged);
    WorkerDirectoryStore.instance.refresh();
  }

  @override
  void dispose() {
    WorkerDirectoryStore.instance.removeListener(_onDirectoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDirectoryChanged() {
    if (mounted) setState(() {});
  }

  List<DirectoryWorker> get _results {
    final query = _searchController.text.trim().toLowerCase();
    return WorkerDirectoryStore.instance.workers.where((worker) {
      final matchesTrade =
          _selectedTrade == null || worker.trades.contains(_selectedTrade);
      final matchesQuery = query.isEmpty ||
          worker.name.toLowerCase().contains(query) ||
          worker.town.toLowerCase().contains(query) ||
          worker.tradeLabel.toLowerCase().contains(query);
      return matchesTrade && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final store = WorkerDirectoryStore.instance;
    final loading = store.loading && store.workers.isEmpty;
    final loadFailed = store.loadFailed && store.workers.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: Scaffold(
        backgroundColor: KaziColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t(context, 'search.title'), style: KaziTextStyles.heading),
                    const SizedBox(height: 8),
                    Text(
                      t(context, 'search.subtitle'),
                      style: KaziTextStyles.subtitle.copyWith(
                        color: KaziColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: KaziTextStyles.input,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: t(context, 'search.hint'),
                        hintStyle: KaziTextStyles.input.copyWith(
                          color: KaziColors.textHint,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: KaziColors.grey,
                        ),
                        filled: true,
                        fillColor: KaziColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: KaziColors.grey15,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: KaziColors.grey15,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: KaziColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _TradeChip(
                            label: t(context, 'common.all'),
                            selected: _selectedTrade == null,
                            onTap: () => setState(() => _selectedTrade = null),
                          ),
                          ...TradeCategory.values.map(
                            (trade) => _TradeChip(
                              label: trade.label,
                              selected: _selectedTrade == trade,
                              onTap: () => setState(() {
                                _selectedTrade =
                                    _selectedTrade == trade ? null : trade;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Results
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: KaziColors.primary,
                        ),
                      )
                    : loadFailed
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              const Icon(
                                Icons.wifi_off_outlined,
                                size: 48,
                                color: KaziColors.grey30,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t(context, 'search.loadFailed'),
                                style: KaziTextStyles.button.copyWith(
                                  color: KaziColors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed:
                                      WorkerDirectoryStore.instance.refresh,
                                  child: Text(
                                    t(context, 'search.retry'),
                                    style: KaziTextStyles.footerLink,
                                  ),
                                ),
                              ),
                            ],
                          )
                    : RefreshIndicator(
                        color: KaziColors.primary,
                        onRefresh: WorkerDirectoryStore.instance.refresh,
                        child: results.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 80),
                                  const Icon(
                                    Icons.search_off_outlined,
                                    size: 48,
                                    color: KaziColors.grey30,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    t(context, 'search.empty'),
                                    style: KaziTextStyles.button.copyWith(
                                      color: KaziColors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Text(
                                      t(context, 'search.emptyHint'),
                                      style: KaziTextStyles.subtitle.copyWith(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                                itemCount: results.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  return _WorkerResultTile(worker: results[index]);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeChip extends StatelessWidget {
  const _TradeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? KaziColors.primaryTint : KaziColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? KaziColors.primary : KaziColors.grey15,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: KaziTextStyles.button.copyWith(
              fontSize: 13,
              color: selected ? KaziColors.primary : KaziColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkerResultTile extends StatelessWidget {
  const _WorkerResultTile({required this.worker});

  final DirectoryWorker worker;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WorkerPreviewScreen(worker: worker),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KaziColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KaziColors.grey15, width: 1.5),
        ),
        child: Row(
          children: [
            WorkerPhoto(
              photoUrl: worker.photoUrl,
              radius: 24,
              heroTag: worker.heroTag,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(worker.name, style: KaziTextStyles.button),
                      ),
                      if (worker.isCertified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star, color: KaziColors.primary, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (worker.tradeLabel.isNotEmpty) worker.tradeLabel,
                      worker.town,
                    ].where((part) => part.isNotEmpty).join(' · '),
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                  if (worker.experienceLabel.isNotEmpty)
                    Text(
                      worker.experienceLabel,
                      style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: KaziColors.primary),
          ],
        ),
      ),
    );
  }
}
