import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../constants.dart';

import '../apis/api.dart';
import '../apis/contact.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/system.dart';
import '../pages/forms.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false,
      useOrderBy = false,
      orderByAsc = true,
      useSearchBy = false;
  int currentTabIndex = 0;

  List<Map> leadsList = [], customerList = [], suppliersList = [];

  ScrollController leadsListController = ScrollController(),
      customerListController = ScrollController(),
      suppliersListController = ScrollController();

  var searchController = TextEditingController();
  String?
  fetchLeads = "${Api().baseUrl}${Api().apiUrl}/crm/leads?per_page=10",
  fetchCustomers =
      "${Api().baseUrl}${Api().apiUrl}/contactapi?type=customer&per_page=10",
  fetchSuppliers =
      "${Api().baseUrl}${Api().apiUrl}/contactapi?type=supplier&per_page=10";
  String orderByColumn = 'name', orderByDirection = 'asc';

  TextEditingController prefix = TextEditingController(),
      firstName = TextEditingController(),
      middleName = TextEditingController(),
      lastName = TextEditingController(),
      mobile = TextEditingController(),
      addressLine1 = TextEditingController(),
      addressLine2 = TextEditingController(),
      city = TextEditingController(),
      state = TextEditingController(),
      country = TextEditingController(),
      zip = TextEditingController();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    setAllList();
    leadsListController.addListener(() {
      if (leadsListController.position.pixels ==
          leadsListController.position.maxScrollExtent) {
        setLeadsList();
      }
    });
    customerListController.addListener(() {
      if (customerListController.position.pixels ==
          customerListController.position.maxScrollExtent) {
        setCustomersList();
      }
    });
    suppliersListController.addListener(() {
      if (suppliersListController.position.pixels ==
          suppliersListController.position.maxScrollExtent) {
        setSuppliersList();
      }
    });
    Helper().syncCallLogs();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: _filterDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return newCustomer();
                },
                fullscreenDialog: true,
              ),
            );
          },
          elevation: 2,
          child: Icon(MdiIcons.accountPlus),
        ),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.filterVariant),
              onPressed: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
            ),
          ],
          title: Text(
            AppLocalizations.of(context).translate('contacts'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleLarge,
              fontWeight: 600,
            ),
          ),
          bottom: TabBar(
            onTap: (int val) {
              currentTabIndex = val;
              searchController.clear();
              sortContactList(tabIndex: val);
            },
            tabs: [
              Tab(
                icon: Icon(MdiIcons.bookPlusMultipleOutline),
                child: Text(AppLocalizations.of(context).translate('leads')),
              ),
              Tab(
                icon: Icon(MdiIcons.accountGroupOutline),
                child: Text(AppLocalizations.of(context).translate('customer')),
              ),
              Tab(
                icon: Icon(MdiIcons.accountMultipleOutline),
                child: Text(
                  AppLocalizations.of(context).translate('suppliers'),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            leadTab(leadsList),
            customerTab(customerList),
            supplierTab(suppliersList),
          ],
        ),
      ),
    );
  }

  //Retrieve leads list from api
  Future<void> setLeadsList() async {
    setState(() {
      isLoading = false;
    });
    final dio = Dio();
    var token = await System().getToken();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer $token";
    final response = await dio.get(fetchLeads!);
    List leads = response.data['data'];
    Map links = response.data['links'];
    setState(() {
      for (var element in leads) {
        leadsList.add(element);
      }
    });
    isLoading = (links['next'] != null) ? true : false;
    fetchLeads = links['next'];
  }

  //Retrieve customers list from api
  Future<void> setCustomersList() async {
    setState(() {
      isLoading = false;
    });
    final dio = Dio();
    var token = await System().getToken();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer $token";
    final response = await dio.get(fetchCustomers!);
    List customers = response.data['data'];
    Map links = response.data['links'];
    setState(() {
      for (var element in customers) {
        customerList.add(element);
      }
    });
    isLoading = (links['next'] != null) ? true : false;
    fetchCustomers = links['next'];
  }

  //Retrieve suppliers list from api
  Future<void> setSuppliersList() async {
    setState(() {
      isLoading = false;
    });
    final dio = Dio();
    var token = await System().getToken();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer $token";
    final response = await dio.get(fetchSuppliers!);
    List suppliers = response.data['data'];
    Map links = response.data['links'];
    setState(() {
      for (var element in suppliers) {
        suppliersList.add(element);
      }
    });
    isLoading = (links['next'] != null) ? true : false;
    fetchSuppliers = links['next'];
  }

  //set initial list
  Future<void> setAllList() async {
    fetchLeads = getUrl();
    setLeadsList();
    setCustomersList();
    setSuppliersList();
  }

  //lead widget
  Widget leadTab(leads) {
    if (leads.isEmpty) return Helper().noDataWidget(context);
    return ListView.builder(
      controller: leadsListController,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: leads.length + 1,
      itemBuilder: (context, index) {
        if (index == leads.length) {
          return isLoading ? _buildProgressIndicator() : SizedBox(height: 80);
        }
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: contactBlock(leads[index]),
            ),
          ),
        );
      },
    );
  }

  //customer widget
  Widget customerTab(customers) {
    if (customers.isEmpty) return Helper().noDataWidget(context);
    return ListView.builder(
      controller: customerListController,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: customers.length + 1,
      itemBuilder: (context, index) {
        if (index == customers.length) {
          return isLoading ? _buildProgressIndicator() : SizedBox(height: 80);
        }
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: contactBlock(customers[index]),
            ),
          ),
        );
      },
    );
  }

  //supplier widget
  Widget supplierTab(suppliers) {
    if (suppliers.isEmpty) return Helper().noDataWidget(context);
    return ListView.builder(
      controller: suppliersListController,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: suppliers.length + 1,
      itemBuilder: (context, index) {
        if (index == suppliers.length) {
          return isLoading ? _buildProgressIndicator() : SizedBox(height: 80);
        }
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: contactBlock(suppliers[index]),
            ),
          ),
        );
      },
    );
  }

  //filter widget
  Widget _filterDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('filter'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.headlineSmall,
                  fontWeight: 600,
                  color: themeData.colorScheme.primary,
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('search'),
                  prefixIcon: Icon(MdiIcons.magnify),
                ),
                onEditingComplete: () {
                  setState(() {
                    sortContactList(tabIndex: currentTabIndex);
                  });
                  FocusScope.of(context).unfocus();
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('order_by'),
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.titleMedium,
                      fontWeight: 600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        orderByAsc = !orderByAsc;
                        orderByDirection = (orderByAsc) ? 'asc' : 'desc';
                        sortContactList(tabIndex: currentTabIndex);
                      });
                    },
                    icon: Icon(
                      orderByAsc
                          ? MdiIcons.sortAscending
                          : MdiIcons.sortDescending,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildOrderOption(
                'name',
                AppLocalizations.of(context).translate('name'),
              ),
              _buildOrderOption(
                'supplier_business_name',
                AppLocalizations.of(context).translate('business_name'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderOption(String value, String label) {
    bool isSelected = orderByColumn == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(
        label,
        style: AppTheme.getTextStyle(
          themeData.textTheme.bodyLarge,
          fontWeight: isSelected ? 600 : 400,
          color: isSelected
              ? themeData.colorScheme.primary
              : themeData.textTheme.bodyLarge?.color,
        ),
      ),
      leading: Radio<String>(
        value: value,
        groupValue: orderByColumn,
        activeColor: themeData.colorScheme.primary,
        onChanged: (val) {
          setState(() {
            orderByColumn = val!;
            sortContactList(tabIndex: currentTabIndex);
          });
        },
      ),
      onTap: () {
        setState(() {
          orderByColumn = value;
          sortContactList(tabIndex: currentTabIndex);
        });
      },
    );
  }

  //contact widget
  Widget contactBlock(contactDetails) {
    final bool hasBusinessName =
        contactDetails['supplier_business_name']?.toString() != 'null' &&
        contactDetails['supplier_business_name']?.toString().trim() != '';
    final bool hasName =
        contactDetails['name']?.toString() != 'null' &&
        contactDetails['name']?.toString().trim() != '';
    final bool hasLastFollowUp =
        contactDetails['last_follow_up']?.toString() != 'null' &&
        contactDetails['last_follow_up']?.toString().trim() != '';
    final bool hasUpcomingFollowUp =
        contactDetails['upcoming_follow_up']?.toString() != 'null' &&
        contactDetails['upcoming_follow_up']?.toString().trim() != '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasBusinessName)
          Text(
            '${contactDetails['supplier_business_name']}',
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleMedium,
              fontWeight: 600,
              color: themeData.colorScheme.primary,
            ),
          ),
        if (hasName) ...[
          if (hasBusinessName) SizedBox(height: 4),
          Row(
            children: [
              Icon(MdiIcons.accountOutline, size: 16, color: kMutedTextColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${contactDetails['name']}',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyLarge,
                    fontWeight: 500,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (hasLastFollowUp || hasUpcomingFollowUp) ...[
          SizedBox(height: 12),
          if (hasLastFollowUp)
            Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context).translate('last')}: ",
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.bodySmall,
                      color: kMutedTextColor,
                    ),
                  ),
                  Text(
                    '${contactDetails['last_follow_up']}',
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.bodySmall,
                      fontWeight: 500,
                    ),
                  ),
                ],
              ),
            ),
          if (hasUpcomingFollowUp)
            Row(
              children: [
                Text(
                  "${AppLocalizations.of(context).translate('upcoming')}: ",
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    color: kMutedTextColor,
                  ),
                ),
                Text(
                  '${contactDetails['upcoming_follow_up']}',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    fontWeight: 600,
                    color: themeData.colorScheme.primary,
                  ),
                ),
              ],
            ),
        ],
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Helper().callDropdown(context, contactDetails, [
                contactDetails['mobile'],
                contactDetails['alternate_number'],
                contactDetails['landline'],
              ], type: 'call'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowUpForm(contactDetails),
                    ),
                  );
                },
                icon: Icon(Icons.add, size: 18),
                label: Text(
                  AppLocalizations.of(context).translate('add_follow_up'),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 44),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  textStyle: AppTheme.getTextStyle(
                    themeData.textTheme.labelLarge,
                    fontWeight: 600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //filter list
  void sortContactList({int? tabIndex}) {
    switch (tabIndex) {
      case 0:
        {
          leadsList = [];
          fetchLeads = getUrl();
          setLeadsList();
        }
        break;
      case 1:
        {
          customerList = [];
          fetchCustomers = getUrl();
          setCustomersList();
        }
        break;
      case 2:
        {
          suppliersList = [];
          fetchSuppliers = getUrl();
          setSuppliersList();
        }
        break;
    }
  }

  String getUrl({String? perPage = '10'}) {
    String contactType = (currentTabIndex == 0)
        ? '/crm/leads?'
        : '/contactapi?';
    String url = Api().baseUrl + Api().apiUrl + contactType;

    Map<String, dynamic> params = {};

    if (currentTabIndex == 1) {
      params['type'] = 'customer';
    }
    if (currentTabIndex == 2) {
      params['type'] = 'supplier';
    }
    if (searchController.text != '') {
      params['name'] = searchController.text;
      params['biz_name'] = searchController.text;
      params['mobile_num'] = searchController.text;
      params['contact_id'] = searchController.text;
    }

    if (perPage != null) {
      params['per_page'] = perPage;
    }

    if (useOrderBy) {
      params['order_by'] = orderByColumn;
      params['direction'] = orderByDirection;
    }

    String queryString = Uri(queryParameters: params).query;
    url += queryString;
    return url;
  }

  //show add customer alert box
  Widget newCustomer() {
    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('create_contact'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('basic_information'),
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.titleMedium,
                            fontWeight: 600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: prefix,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('prefix'),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: firstName,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    ).translate('please_enter_your_name');
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('first_name'),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: middleName,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('middle_name'),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: lastName,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('last_name'),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: mobile,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              ).translate('please_enter_mobile_no');
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            ).translate('mobile_no'),
                            prefixIcon: Icon(MdiIcons.phoneOutline, size: 20),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('address'),
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.titleMedium,
                            fontWeight: 600,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: addressLine1,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            ).translate('address_line_1'),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: addressLine2,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            ).translate('address_line_2'),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: city,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('city'),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: state,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('state'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: country,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('country'),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: zip,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('zip_code'),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (await Helper().checkConnectivity()) {
                      if (_formKey.currentState!.validate()) {
                        Map newCustomerMap = {
                          'type': 'customer',
                          'prefix': prefix.text,
                          'first_name': firstName.text,
                          'middle_name': middleName.text,
                          'last_name': lastName.text,
                          'mobile': mobile.text,
                          'address_line_1': addressLine1.text,
                          'address_line_2': addressLine2.text,
                          'city': city.text,
                          'state': state.text,
                          'country': country.text,
                          'zip_code': zip.text,
                        };
                        await CustomerApi().add(newCustomerMap).then((value) {
                          if (value['data'] != null) {
                            Contact()
                                .insertContact(
                                  Contact().contactModel(value['data']),
                                )
                                .then((value) {
                                  Navigator.pop(context);
                                  _formKey.currentState!.reset();
                                });
                          }
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        ).translate('check_connectivity'),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('add_to_contact'),
                  ),
                ),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //progress indicator
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: FutureBuilder<bool>(
          future: Helper().checkConnectivity(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == false) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate('check_connectivity'),
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.titleMedium,
                      fontWeight: 700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Icon(
                    Icons.error_outline,
                    color: themeData.colorScheme.onSurface,
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
