import 'package:flutter/material.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final UserRole? selectedRole;
  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(context, 'auth.iam'), style: KaziTextStyles.label),
        const SizedBox(height: 12),
        Row(
          children: UserRole.values.map((role) {
            final isSelected = selectedRole == role;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role == UserRole.worker ? 8 : 0,
                  left: role == UserRole.customer ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onRoleSelected(role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? KaziColors.primaryTint
                          : KaziColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? KaziColors.primary
                            : KaziColors.grey15,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          role.label,
                          style: KaziTextStyles.button.copyWith(
                            color: isSelected
                                ? KaziColors.primary
                                : KaziColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.description,
                          textAlign: TextAlign.center,
                          style: KaziTextStyles.subtitle.copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? KaziColors.primary
                                : KaziColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
