part of 'package:pos_final/presentation/screens/products_screen.dart';

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kDefaultColor.withAlpha(12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(11),
          child: Icon(icon, color: kDefaultColor, size: 20),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? kDefaultColor : kSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? kDefaultColor : kOutlineColor,
            width: isSelected ? 1.0 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kDefaultColor.withAlpha(40),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : kPrimaryTextColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.getTextStyle(
                Theme.of(context).textTheme.bodySmall,
                fontWeight: 600,
                color: isSelected ? Colors.white : kPrimaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final dynamic product;
  final String symbol;
  final VoidCallback onTap;
  final bool canEditPrice;
  final Function(double) onEditPrice;

  const _ProductGridCard({
    required this.product,
    required this.symbol,
    required this.onTap,
    required this.canEditPrice,
    required this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kOutlineColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product['product_image_url'] ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: kBackgroundSoftColor,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: kMutedTextColor.withAlpha(120),
                            size: 28,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: kBackgroundSoftColor,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: kMutedTextColor.withAlpha(120),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    if (product['enable_stock'] != 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            "Stock: ${Helper().formatQuantity(product['stock_available'])}",
                            style: AppTheme.getTextStyle(
                              Theme.of(context).textTheme.labelSmall,
                              fontWeight: 700,
                              color: kPrimaryTextColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['display_name'] ?? 'No Name',
                      style: AppTheme.getTextStyle(
                        Theme.of(context).textTheme.bodySmall,
                        fontWeight: 600,
                        color: kPrimaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${Helper().formatCurrency(double.parse(product['unit_price'].toString()))} $symbol",
                            style: AppTheme.getTextStyle(
                              Theme.of(context).textTheme.bodyMedium,
                              fontWeight: 700,
                              color: kDefaultColor,
                            ),
                          ),
                        ),
                        if (canEditPrice)
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            color: kMutedTextColor,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  double newPrice = double.parse(
                                    product['unit_price'].toString(),
                                  );
                                  return AlertDialog(
                                    title: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).translate('edit_price'),
                                    ),
                                    content: TextFormField(
                                      initialValue: newPrice.toStringAsFixed(2),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^(\d+)?\.?\d{0,2}'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        newPrice =
                                            Helper().validateInput(value);
                                      },
                                      decoration: InputDecoration(
                                        prefix: Text(symbol),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).translate('cancel'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          onEditPrice(newPrice);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).translate('save'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  final dynamic product;
  final String symbol;
  final VoidCallback onTap;
  final bool canEditPrice;
  final Function(double) onEditPrice;

  const _ProductListCard({
    required this.product,
    required this.symbol,
    required this.onTap,
    required this.canEditPrice,
    required this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOutlineColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product['product_image_url'] ?? '',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: kBackgroundSoftColor),
                errorWidget: (context, url, error) => Container(
                  color: kBackgroundSoftColor,
                  child: Center(child: Icon(Icons.image_outlined, color: kMutedTextColor.withAlpha(120), size: 24)),
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['display_name'] ?? 'No Name',
                    style: AppTheme.getTextStyle(
                      Theme.of(context).textTheme.bodyMedium,
                      fontWeight: 600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  if (product['enable_stock'] != 0)
                    Text(
                      "Stock: ${Helper().formatQuantity(product['stock_available'])}",
                      style: AppTheme.getTextStyle(
                        Theme.of(context).textTheme.bodySmall,
                        color: kMutedTextColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${Helper().formatCurrency(double.parse(product['unit_price'].toString()))} $symbol",
                      style: AppTheme.getTextStyle(
                        Theme.of(context).textTheme.titleMedium,
                        fontWeight: 700,
                        color: kDefaultColor,
                      ),
                    ),
                    if (canEditPrice)
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        color: kMutedTextColor,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              double newPrice = double.parse(
                                product['unit_price'].toString(),
                              );
                              return AlertDialog(
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('edit_price'),
                                ),
                                content: TextFormField(
                                  initialValue: newPrice.toStringAsFixed(2),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    newPrice = Helper().validateInput(value);
                                  },
                                  decoration: InputDecoration(
                                    prefix: Text(symbol),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).translate('cancel'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      onEditPrice(newPrice);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).translate('save'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kDefaultColor.withAlpha(14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_rounded, color: kDefaultColor, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
