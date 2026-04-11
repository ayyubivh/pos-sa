part of 'package:pos_final/presentation/screens/products_screen.dart';

class _ProductsState extends State<Products> {
  List products = [];
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  bool changeLocation = false,
      changePriceGroup = false,
      canChangeLocation = true,
      canMakeSell = false,
      inStock = true,
      gridView = false,
      canAddSell = false,
      canViewProducts = false,
      usePriceGroup = true,
      directCheckout = false,
      isLoading = false;

  int selectedLocationId = 0,
      categoryId = 0,
      subCategoryId = 0,
      brandId = 0,
      cartCount = 0,
      sellingPriceGroupId = 0,
      offset = 0;
  bool canEditPrice = false;
  int? byAlphabets, byPrice;

  List<DropdownMenuItem<int>> _categoryMenuItems = [],
      _subCategoryMenuItems = [],
      _brandsMenuItems = [];
  List<DropdownMenuItem<bool>> _priceGroupMenuItems = [];
  Map? argument;
  List<Map<String, dynamic>> locationListMap = [
    {'id': 0, 'name': 'set location', 'selling_price_group_id': 0},
  ];

  String symbol = '';
  String url =
      'https://www.youtube.com/watch?v=l3Jvigvxsvc&ab_channel=TheInspiringDad';
  final searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  bool _canAddProductToCart(Map<String, dynamic>? product) {
    if (product == null) return false;

    final enableStock = int.tryParse(product['enable_stock'].toString()) ?? 0;
    if (enableStock == 0) return true;

    final stockAvailable =
        double.tryParse(product['stock_available'].toString()) ?? 0;
    return stockAvailable > 0;
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    getPermission();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        productList();
      }
    });

    categoryList();
    subCategoryList(categoryId);
    brandList();
    Helper().syncCallLogs();
  }

  @override
  Future<void> didChangeDependencies() async {
    var newArgument = ModalRoute.of(context)!.settings.arguments as Map?;
    int initLocationId = selectedLocationId;

    //Arguments sellId & locationId is send from edit.
    if (newArgument != null) {
      argument = newArgument;
      initLocationId = newArgument['locationId'];
      canChangeLocation = false;
      // We set the location synchronously here so that the initial product
      // load (setInitDetails) correctly fetches products for this location.
      selectedLocationId = initLocationId;
    } else {
      canChangeLocation = true;
    }
    await setInitDetails(initLocationId);
    super.didChangeDependencies();
  }

  //Set location & product
  Future<void> setInitDetails(int initLocationId) async {
    //check subscription
    var activeSubscriptionDetails = await System().get('active-subscription');
    if (activeSubscriptionDetails.length > 0) {
      setState(() {
        canMakeSell = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('no_subscription_found'),
      );
    }
    await Helper().getFormattedBusinessDetails().then((value) {
      symbol = value['symbol'] + ' ';
    });
    await setLocationMap();
    setDefaultLocation(initLocationId);
    await priceGroupList();
    products = [];
    offset = 0;
    // Ensure that if we have a selected location we fetch products right away
    if (selectedLocationId != 0) {
      productList();
    }
  }

  //Fetch permission from database
  Future<void> getPermission() async {
    if (await Helper().getPermission("direct_sell.access")) {
      canAddSell = true;
    }
    if (await Helper().getPermission("product.view")) {
      canViewProducts = true;
    }
    canEditPrice = await Helper().getPermission(
      "edit_product_price_from_pos_screen",
    );
  }

  //set selling Price Group Id
  void findSellingPriceGroupId(locId) {
    if (usePriceGroup) {
      for (var element in locationListMap) {
        if (element['id'] == selectedLocationId &&
            element['selling_price_group_id'] != null) {
          sellingPriceGroupId = int.parse(
            element['selling_price_group_id'].toString(),
          );
        } else if (element['id'] == selectedLocationId &&
            element['selling_price_group_id'] == null) {
          sellingPriceGroupId = 0;
        }
      }
    } else {
      sellingPriceGroupId = 0;
    }
  }

  //set product list
  Future<void> productList() async {
    if (offset == 0) {
      if (mounted) setState(() => isLoading = true);
    }
    offset++;
    // We removed the 10 minute bulk sync because we are fetching live from the API on demand.

    findSellingPriceGroupId(selectedLocationId);
    await Variations()
        .getFromApi(
          brandId: brandId,
          categoryId: categoryId,
          subCategoryId: subCategoryId,
          inStock: inStock,
          locationId: selectedLocationId,
          searchTerm: searchController.text,
          offset: offset,
          byAlphabets: byAlphabets,
          byPrice: byPrice,
        )
        .then((element) {
          if (mounted) {
            setState(() {
              if (offset == 1) {
                products = []; // Just to be safe for initial clear
              }
              isLoading = false;
            });
            for (var product in element) {
              double price = 0;
              if (product['selling_price_group'] != null) {
                jsonDecode(product['selling_price_group']).forEach((e) {
                  if (e['key'] == sellingPriceGroupId) {
                    price = double.parse(e['value'].toString());
                  }
                });
              }
              setState(() {
                products.add(ProductModel().product(product, price));
              });
            }
          }
        });
  }

  Future<void> categoryList() async {
    List categories = await System().getCategories();

    _categoryMenuItems.add(
      DropdownMenuItem(
        value: 0,
        child: Text(AppLocalizations.of(context).translate('select_category')),
      ),
    );

    for (var category in categories) {
      _categoryMenuItems.add(
        DropdownMenuItem(value: category['id'], child: Text(category['name'])),
      );
    }
  }

  Future<void> subCategoryList(parentId) async {
    List subCategories = await System().getSubCategories(parentId);
    _subCategoryMenuItems = [];
    _subCategoryMenuItems.add(
      DropdownMenuItem(
        value: 0,
        child: Text(
          AppLocalizations.of(context).translate('select_sub_category'),
        ),
      ),
    );
    for (var element in subCategories) {
      _subCategoryMenuItems.add(
        DropdownMenuItem(
          value: jsonDecode(element['value'])['id'],
          child: Text(jsonDecode(element['value'])['name']),
        ),
      );
    }
  }

  Future<void> brandList() async {
    List brands = await System().getBrands();

    _brandsMenuItems.add(
      DropdownMenuItem(
        value: 0,
        child: Text(AppLocalizations.of(context).translate('select_brand')),
      ),
    );

    for (var brand in brands) {
      _brandsMenuItems.add(
        DropdownMenuItem(value: brand['id'], child: Text(brand['name'])),
      );
    }
  }

  Future<void> priceGroupList() async {
    setState(() {
      _priceGroupMenuItems = [];
      _priceGroupMenuItems.add(
        DropdownMenuItem(
          value: false,
          child: Text(
            AppLocalizations.of(context).translate('no_price_group_selected'),
          ),
        ),
      );

      bool hasPriceGroup = false;

      for (var element in locationListMap) {
        if (element['id'] == selectedLocationId &&
            element['selling_price_group_id'] != null) {
          hasPriceGroup = true;
          _priceGroupMenuItems.add(
            DropdownMenuItem(
              value: true,
              child: Text(
                AppLocalizations.of(context).translate('default_price_group'),
              ),
            ),
          );
        }
      }

      if (!hasPriceGroup && usePriceGroup) {
        usePriceGroup = false;
      }
    });
  }

  Future<String> getCartItemCount({isCompleted, sellId}) async {
    var counts = await Sell().cartItemCount(
      isCompleted: isCompleted,
      sellId: sellId,
    );
    setState(() {
      cartCount = int.parse(counts);
    });
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackgroundColor,
      endDrawer: _filterDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        surfaceTintColor: kBackgroundColor,
        title: Text(
          AppLocalizations.of(context).translate('products'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
            color: kPrimaryTextColor,
          ),
        ),
        centerTitle: false,
        actions: <Widget>[
          locations(),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: badges.Badge(
              badgeStyle: badges.BadgeStyle(
                badgeColor: kDefaultColor,
                padding: EdgeInsets.all(6),
                elevation: 0,
              ),
              position: badges.BadgePosition.topEnd(end: 4, top: 4),
              badgeContent: FutureBuilder(
                future: (argument != null && argument!['sellId'] != null)
                    ? getCartItemCount(sellId: argument!['sellId'])
                    : getCartItemCount(isCompleted: 0),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  return Text(
                    snapshot.data ?? "0",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              child: IconButton(
                icon: Icon(IconBroken.Buy, size: 26, color: kPrimaryTextColor),
                onPressed: () {
                  if (argument != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/cart',
                      arguments: Helper().argument(
                        locId: argument!['locationId'],
                        sellId: argument!['sellId'],
                      ),
                    );
                  } else {
                    if (selectedLocationId != 0 && cartCount > 0) {
                      Navigator.pushNamed(
                        context,
                        '/cart',
                        arguments: Helper().argument(locId: selectedLocationId),
                      );
                    }

                    if (cartCount == 0) {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        ).translate('no_items_added_to_cart'),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: (canViewProducts)
          ? Column(
              children: [
                if (selectedLocationId != 0) filter(_scaffoldKey),
                Expanded(
                  child: (selectedLocationId == 0)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 48,
                                color: kMutedTextColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('please_set_a_location'),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.titleMedium,
                                  color: kMutedTextColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _productsList(),
                ),
              ],
            )
          : Center(
              child: Text(
                AppLocalizations.of(context).translate('unauthorised'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleMedium,
                  color: kMutedTextColor,
                ),
              ),
            ),
    );
  }

  Widget _filterDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: kBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).translate('filter_and_sort'),
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.titleLarge,
                      fontWeight: 600,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildDrawerSectionTitle(
                      AppLocalizations.of(context).translate('sort'),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _SortChip(
                          label: "A-Z",
                          icon: (byAlphabets == 1)
                              ? MdiIcons.sortAlphabeticalAscending
                              : MdiIcons.sortAlphabeticalDescending,
                          isSelected: byAlphabets != null,
                          onTap: () {
                            setState(() {
                              if (byAlphabets == null)
                                byAlphabets = 0;
                              else if (byAlphabets == 0)
                                byAlphabets = 1;
                              else
                                byAlphabets = null;
                            });
                            refreshProducts();
                          },
                        ),
                        _SortChip(
                          label: AppLocalizations.of(
                            context,
                          ).translate('price'),
                          icon: (byPrice == 1)
                              ? MdiIcons.sortNumericAscending
                              : MdiIcons.sortNumericDescending,
                          isSelected: byPrice != null,
                          onTap: () {
                            setState(() {
                              if (byPrice == null)
                                byPrice = 0;
                              else if (byPrice == 0)
                                byPrice = 1;
                              else
                                byPrice = null;
                            });
                            refreshProducts();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildDrawerSectionTitle(
                      AppLocalizations.of(context).translate('filter'),
                    ),
                    _buildSwitchTile(
                      AppLocalizations.of(context).translate('in_stock'),
                      inStock,
                      (val) {
                        setState(() => inStock = val);
                        refreshProducts();
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSwitchTile(
                      AppLocalizations.of(context).translate('direct_checkout'),
                      directCheckout,
                      (val) {
                        setState(() => directCheckout = val);
                      },
                    ),
                    SizedBox(height: 16),
                    _buildDropdownSection(
                      AppLocalizations.of(context).translate('categories'),
                      categoryId,
                      _categoryMenuItems,
                      (val) {
                        setState(() {
                          categoryId = val!;
                          subCategoryId = 0;
                          subCategoryList(categoryId);
                        });
                        refreshProducts();
                      },
                    ),
                    SizedBox(height: 16),
                    _buildDropdownSection(
                      AppLocalizations.of(context).translate('sub_categories'),
                      subCategoryId,
                      _subCategoryMenuItems,
                      (val) {
                        setState(() => subCategoryId = val!);
                        refreshProducts();
                      },
                    ),
                    SizedBox(height: 16),
                    _buildDropdownSection(
                      AppLocalizations.of(context).translate('brands'),
                      brandId,
                      _brandsMenuItems,
                      (val) {
                        setState(() => brandId = val!);
                        refreshProducts();
                      },
                    ),
                    SizedBox(height: 24),
                    _buildDrawerSectionTitle(
                      AppLocalizations.of(context).translate('group_prices'),
                    ),
                    _buildDropdownSection<bool>(
                      AppLocalizations.of(context).translate('price_group'),
                      usePriceGroup,
                      _priceGroupMenuItems,
                      (val) async {
                        await _showCartResetDialogForPriceGroup();
                        if (changePriceGroup) {
                          setState(() {
                            usePriceGroup = val!;
                            Sell().resetCart();
                            brandId = 0;
                            categoryId = 0;
                            searchController.clear();
                            inStock = true;
                            cartCount = 0;
                          });
                          refreshProducts();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void refreshProducts() {
    products = [];
    offset = 0;
    productList();
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.getTextStyle(
          themeData.textTheme.labelSmall,
          fontWeight: 600,
          color: kMutedTextColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOutlineColor, width: 0.5),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyMedium,
            fontWeight: 500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: kDefaultColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownSection<T>(
    String title,
    T value,
    List<DropdownMenuItem<T>> items,
    Function(T?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodySmall,
            fontWeight: 500,
            color: kMutedTextColor,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kOutlineColor, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              icon: Icon(Icons.keyboard_arrow_down, color: kMutedTextColor, size: 20),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget filter(scaffoldKey) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: searchController,
                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('search'),
                  prefixIcon: Icon(
                    MdiIcons.magnify,
                    color: kMutedTextColor,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: kBackgroundSoftColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kOutlineColor, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kDefaultColor, width: 1.5),
                  ),
                ),
                onEditingComplete: () {
                  refreshProducts();
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          _IconButton(
            icon: MdiIcons.barcode,
            onTap: () async {
              var barcode = await Helper().barcodeScan();
              await getScannedProduct(barcode);
            },
          ),
          SizedBox(width: 8),
          _IconButton(
            icon: MdiIcons.tune,
            onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
          ),
          SizedBox(width: 8),
          _IconButton(
            icon: gridView ? MdiIcons.viewList : MdiIcons.viewGrid,
            onTap: () => setState(() => gridView = !gridView),
          ),
        ],
      ),
    );
  }

  //add product to cart after scanning barcode
  Future<void> getScannedProduct(String barcode) async {
    if (canMakeSell) {
      await Variations()
          .get(
            locationId: selectedLocationId,
            barcode: barcode,
            offset: 0,
            searchTerm: searchController.text,
          )
          .then((value) async {
            if (canAddSell) {
              if (value.length > 0) {
                double price = 0;
                var product;
                if (value[0]['selling_price_group'] != null) {
                  jsonDecode(value[0]['selling_price_group'].toString()).forEach((
                    element,
                  ) {
                    if (element['key'] == sellingPriceGroupId) {
                      price = double.parse(element['value'].toString());
                    }
                  });
                }
                setState(() {
                  product = ProductModel().product(value[0], price);
                });
                if (_canAddProductToCart(product)) {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(
                      context,
                    ).translate('added_to_cart'),
                  );
                  await Sell().addToCart(
                    product,
                    argument != null ? argument!['sellId'] : null,
                  );
                  if (argument != null) {
                    selectedLocationId = argument!['locationId'];
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate("out_of_stock"),
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(
                    context,
                  ).translate("no_product_found"),
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(
                  context,
                ).translate("no_sells_permission"),
              );
            }
          });
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('no_subscription_found'),
      );
    }
  }

  Widget _productsList() {
    if (isLoading && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kDefaultColor),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('sync_in_progress'),
              style: AppTheme.getTextStyle(
                themeData.textTheme.bodyMedium,
                color: kMutedTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconBroken.Document, size: 48, color: kMutedTextColor),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('no_products_found'),
              style: AppTheme.getTextStyle(
                themeData.textTheme.titleMedium,
                color: kMutedTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return gridView
        ? GridView.builder(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
            controller: _scrollController,
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75, // Better aspect ratio for the new design
            ),
            itemBuilder: (context, index) {
              return _ProductGridCard(
                product: products[index],
                symbol: symbol,
                onTap: () => onTapProduct(index),
                canEditPrice: canEditPrice,
                onEditPrice: (newPrice) {
                  setState(() {
                    products[index]['unit_price'] = newPrice;
                  });
                },
              );
            },
          )
        : ListView.separated(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
            controller: _scrollController,
            itemCount: products.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ProductListCard(
                product: products[index],
                symbol: symbol,
                onTap: () => onTapProduct(index),
                canEditPrice: canEditPrice,
                onEditPrice: (newPrice) {
                  setState(() {
                    products[index]['unit_price'] = newPrice;
                  });
                },
              );
            },
          );
  }

  //onTap product
  Future<void> onTapProduct(int index) async {
    if (canAddSell) {
      if (canMakeSell) {
        if (_canAddProductToCart(
          Map<String, dynamic>.from(products[index]),
        )) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('added_to_cart'),
          );
          await Sell().addToCart(
            products[index],
            argument != null ? argument!['sellId'] : null,
          );
          if (argument != null) {
            selectedLocationId = argument!['locationId'];
          }
          if (directCheckout) {
            Navigator.pushNamed(
              context,
              '/cart',
              arguments: Helper().argument(locId: selectedLocationId),
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate("out_of_stock"),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate("no_sells_permission"),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('no_subscription_found'),
      );
    }
  }

  Future<void> setLocationMap() async {
    setState(() {
      locationListMap = [
        {'id': 0, 'name': 'set location', 'selling_price_group_id': null},
      ];
    });

    await System().get('location').then((value) async {
      value.forEach((element) {
        if (element['is_active'].toString() == '1') {
          setState(() {
            locationListMap.add({
              'id': element['id'],
              'name': element['name'],
              'selling_price_group_id': element['selling_price_group_id'],
            });
          });
        }
      });
      await priceGroupList();
    });
  }

  void setDefaultLocation(defaultLocation) {
    if (defaultLocation != 0) {
      setState(() {
        selectedLocationId = defaultLocation;
      });
    } else if (locationListMap.length == 2) {
      setState(() {
        selectedLocationId = locationListMap[1]['id'] as int;
      });
    }
  }

  Widget locations() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kDefaultColor.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDefaultColor.withAlpha(25), width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedLocationId,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: kMutedTextColor,
          ),
          dropdownColor: kSurfaceColor,
          items: locationListMap.map<DropdownMenuItem<int>>((Map value) {
            return DropdownMenuItem<int>(
              value: value['id'],
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.35,
                ),
                child: Text(
                  '${value['name']}',
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    fontWeight: 600,
                    color: kPrimaryTextColor,
                  ),
                ),
              ),
            );
          }).toList(),
          onTap: () {
            if (locationListMap.length <= 2) {
              canChangeLocation = false;
            }
          },
          onChanged: (int? newValue) async {
            if (canChangeLocation) {
              if (selectedLocationId == newValue) {
                changeLocation = false;
              } else if (selectedLocationId != 0) {
                await _showCartResetDialogForLocation();
                await priceGroupList();
              } else {
                changeLocation = true;
                await priceGroupList();
              }
              if (changeLocation) {
                setState(() {
                  Sell().resetCart();
                  selectedLocationId = newValue!;
                  brandId = 0;
                  categoryId = 0;
                  searchController.clear();
                  inStock = true;
                  cartCount = 0;
                });
                refreshProducts();
              }
            } else {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(
                  context,
                ).translate('cannot_change_location'),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _showCartResetDialogForLocation() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            AppLocalizations.of(context).translate('change_location'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleLarge,
              fontWeight: 700,
            ),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            ).translate('all_items_in_cart_will_be_remove'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodyMedium,
              color: kMutedTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                changeLocation = false;
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context).translate('cancel'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.labelLarge,
                  color: kMutedTextColor,
                  fontWeight: 600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                changeLocation = true;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('confirm'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.labelLarge,
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCartResetDialogForPriceGroup() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            AppLocalizations.of(
              context,
            ).translate('change_selling_price_group'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleLarge,
              fontWeight: 700,
            ),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            ).translate('all_items_in_cart_will_be_remove'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodyMedium,
              color: kMutedTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                changePriceGroup = false;
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context).translate('cancel'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.labelLarge,
                  color: kMutedTextColor,
                  fontWeight: 600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                changePriceGroup = true;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('confirm'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.labelLarge,
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
