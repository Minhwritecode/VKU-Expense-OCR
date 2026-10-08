part of '../main.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final battery = ref.watch(batteryLevelProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
      children: [
        Text(
          'Không phức tạp hóa',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          'Cài đặt của bạn.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 22),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const _SettingIcon(
                  icon: Icons.dark_mode_rounded,
                  color: AppColors.lavender,
                ),
                title: const Text(
                  'Giao diện tối',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Dễ chịu hơn khi ghi chi tiêu ban đêm'),
                trailing: Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (value) =>
                      ref.read(themeModeProvider.notifier).state = value
                      ? ThemeMode.dark
                      : ThemeMode.light,
                ),
              ),
              const Divider(height: 1, indent: 72),
              const ListTile(
                leading: _SettingIcon(
                  icon: Icons.cloud_off_rounded,
                  color: AppColors.mint,
                ),
                title: Text(
                  'Hoạt động offline',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('OCR và dữ liệu nằm trên thiết bị của bạn'),
                trailing: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.mint,
                ),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: const _SettingIcon(
                  icon: Icons.battery_5_bar_rounded,
                  color: AppColors.orange,
                ),
                title: const Text(
                  'Pin thiết bị',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  battery.when(
                    data: (value) => value == null
                        ? 'Native bridge chưa sẵn sàng'
                        : 'Đọc qua MethodChannel · offline',
                    loading: () => 'Đang đọc trạng thái thiết bị...',
                    error: (_, error) => 'Không đọc được trạng thái pin',
                  ),
                ),
                trailing: battery.when(
                  data: (value) => value == null
                      ? const Icon(Icons.help_outline_rounded)
                      : Text(
                          '${value.clamp(0, 100)}%',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, error) => const Icon(Icons.error_outline_rounded),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: _SettingIcon(
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.orange,
                ),
                title: Text(
                  'Về Ledgerly',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Mini-project Flutter · VKU · Week 08 · Part 2'),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Pipeline xử lý'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Ledgerly',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text(
                      'Ảnh → ML Kit OCR → Regex heuristics → Review → SQLite',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}
