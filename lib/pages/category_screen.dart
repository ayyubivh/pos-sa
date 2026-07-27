import 'package:flutter/material.dart';
import 'package:pos_final/core/theme/app_theme.dart';
import 'package:pos_final/constants.dart';
import 'package:pos_final/locale/MyLocalizations.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme.getThemeFromThemeMode(1);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context).translate('Categories'),
          style: AppTheme.getTextStyle(themeData.textTheme.titleLarge,
              fontWeight: 600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _categoryTile(
                  context: context,
                  label: AppLocalizations.of(context).translate('brands'),
                  icon: Icons.branding_watermark_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/BrandsScreen');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: kSurfaceColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kOutlineColor, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kDefaultColor.withAlpha(14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: kDefaultColor, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: kPrimaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
