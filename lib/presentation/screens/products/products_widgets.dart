part of 'package:pos_final/presentation/screens/products_screen.dart';

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBackgroundSoftColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Icon(icon, color: kDefaultColor, size: 22),
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
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kDefaultColor : kSurfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kDefaultColor : kOutlineColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kDefaultColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
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
                        child: Icon(
                          Icons.image_outlined,
                          color: kMutedTextColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: kBackgroundSoftColor,
                        child: Icon(
                          Icons.error_outline,
                          color: kMutedTextColor,
                        ),
                      ),
                    ),
                    if (product['enable_stock'] != 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
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
                padding: EdgeInsets.all(12),
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
                    SizedBox(height: 4),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: product['product_image_url'] ?? '',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: kBackgroundSoftColor),
                errorWidget: (context, url, error) => Container(
                  color: kBackgroundSoftColor,
                  child: Icon(Icons.image_outlined, color: kMutedTextColor),
                ),
              ),
            ),
            SizedBox(width: 16),
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
                  SizedBox(height: 4),
                  if (product['enable_stock'] != 0)
                    Text(
                      "Stock: ${Helper().formatQuantity(product['stock_available'])}",
                      style: AppTheme.getTextStyle(
                        Theme.of(context).textTheme.bodySmall,
                        color: kMutedTextColor,
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
                SizedBox(height: 8),
                Icon(Icons.add_circle_outline, color: kDefaultColor, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
