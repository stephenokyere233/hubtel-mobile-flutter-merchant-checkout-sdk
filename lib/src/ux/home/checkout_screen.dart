import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core_ui/core_ui.dart';
import '../../network_manager/network_manager.dart';
import '../../platform/models/models.dart';
import '../view_model/checkout_view_model.dart';
import 'checkout_home_screen.dart';

enum CheckoutPaymentStatus { success, cancelled }

class CheckoutScreen extends StatefulWidget {
  final String? accessToken = '';
  // late final Function(CheckoutPaymentStatus)? checkoutCompleted;
  late final PurchaseInfo purchaseInfo;
  late final HubtelCheckoutConfiguration configuration;
  late final ThemeConfig? themeConfig;
  late final List<BankCardData>? savedBankCards;

  // late final Function(PaymentStatus) onCheckoutComplete;

  // Color? _primaryColor;

  CheckoutScreen({
    super.key,
    required this.purchaseInfo,
    required this.configuration,
    this.savedBankCards,
    this.themeConfig,
  }) {
    try {
      CheckoutRequirements.customerMsisdn = purchaseInfo.customerMsisdn;
      CheckoutRequirements.apiKey = configuration.merchantApiKey;
      CheckoutRequirements.merchantId = configuration.merchantID;
      CheckoutRequirements.callbackUrl = configuration.callbackUrl;
    } catch (e) {
      print("Error initializing CheckoutRequirements: $e");
      // Continue with initialization, errors will be handled in build
    }
  }

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutViewModel _viewModel;
  // Store the fetch channels future to avoid recreating it on every build
  late Future<UiResult<ChannelFetchResponse>> _fetchChannelsFuture;
  bool _hasError = false;
  String _errorMessage = "Something went wrong while configuring business";

  @override
  void initState() {
    try {
      super.initState();
      _viewModel = CheckoutViewModel();

      // Initialize the future once in initState with error handling
      _fetchChannelsFuture = _fetchChannelsWithErrorHandling();

      // Set theme color once
      if (widget.themeConfig != null) {
        ThemeConfig.themeColor = widget.themeConfig!.primaryColor;
      }
    } catch (e, stackTrace) {
      print("Error in CheckoutScreen initState: $e");
      print(stackTrace);
      _hasError = true;
      _errorMessage = "Failed to initialize checkout: $e";
      // Create a completed future with error to avoid null _fetchChannelsFuture
      _fetchChannelsFuture = Future.value(UiResult(
        state: UiState.error,
        message: _errorMessage,
      ));
    }
  }

  // Fetch channels with error handling
  Future<UiResult<ChannelFetchResponse>>
      _fetchChannelsWithErrorHandling() async {
    try {
      return await _viewModel.fetchChannels();
    } catch (e, stackTrace) {
      print("Error fetching channels: $e");
      print(stackTrace);
      return UiResult(
        state: UiState.error,
        message: "Failed to fetch channels: $e",
      );
    }
  }

  // Retry fetching channels
  void _retryFetchChannels() {
    setState(() {
      _hasError = false;
      _fetchChannelsFuture = _fetchChannelsWithErrorHandling();
    });
  }

  @override
  void dispose() {
    try {
      _viewModel.dispose();
      super.dispose();
    } catch (e) {
      print("Error in CheckoutScreen dispose: $e");
      super.dispose();
    }
  }

  void onNewCardInputComplete() async {}

  @override
  Widget build(BuildContext context) {
    try {
      return MultiProvider(
        providers: [ChangeNotifierProvider.value(value: _viewModel)],
        child: Container(
          color: Colors.white,
          child: FutureBuilder<UiResult<ChannelFetchResponse>>(
            // Use the stored future to prevent recreation on rebuild
            future: _fetchChannelsFuture,
            builder: (context,
                AsyncSnapshot<UiResult<ChannelFetchResponse>> snapshot) {
              // Handle connection errors
              if (snapshot.hasError) {
                return _buildErrorWidget(
                  "Connection error: ${snapshot.error}",
                  onRetry: _retryFetchChannels,
                );
              }

              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: ThemeConfig.themeColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading checkout...",
                        style: TextStyle(color: ThemeConfig.themeColor),
                      ),
                    ],
                  ),
                );
              }

              // Handle data state
              if (snapshot.hasData) {
                // Check for error state in the result
                if (snapshot.data?.state == UiState.error) {
                  return _buildErrorWidget(
                    snapshot.data?.message ?? "Failed to load checkout",
                    onRetry: _retryFetchChannels,
                  );
                }

                // Check for success state
                if (snapshot.data?.state == UiState.success) {
                  try {
                    final businessInfo =
                        snapshot.data?.data?.getBusinessInfo() ??
                            BusinessInfo(
                              businessName: 'businessName',
                              businessImageUrl: 'businessImageUrl',
                            );

                    return CheckoutHomeScreen(
                      checkoutPurchase: widget.purchaseInfo,
                      businessInfo: businessInfo,
                      themeConfig: widget.themeConfig ??
                          ThemeConfig(
                            primaryColor: HubtelColors.teal,
                          ),
                      savedBankCards: widget.savedBankCards,
                    );
                  } catch (e, stackTrace) {
                    print("Error creating CheckoutHomeScreen: $e");
                    print(stackTrace);
                    return _buildErrorWidget(
                      "Error loading checkout screen: $e",
                      onRetry: _retryFetchChannels,
                    );
                  }
                } else {
                  // Handle other states
                  return _buildErrorWidget(
                    snapshot.data?.message ??
                        "Something went wrong while configuring business",
                    onRetry: _retryFetchChannels,
                  );
                }
              }

              // Fallback for no data
              return Center(
                child: CircularProgressIndicator(
                  color: ThemeConfig.themeColor,
                  backgroundColor: Colors.teal[500],
                ),
              );
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      print("Fatal error in CheckoutScreen build: $e");
      print(stackTrace);
      return _buildFatalErrorWidget(e.toString());
    }
  }

  // Widget to display when there's an error
  Widget _buildErrorWidget(String message, {required VoidCallback onRetry}) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 50),
              SizedBox(height: 16),
              Text(
                "Unable to load checkout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.themeColor,
                ),
                child: Text("Retry"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display when there's a fatal error
  Widget _buildFatalErrorWidget(String errorMessage) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout Error"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 70),
              SizedBox(height: 20),
              Text(
                "Something went wrong",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "We encountered an unexpected error. Please try again later.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Safer implementation of getErrorDialog
  Widget getErrorDialog(
      {required String message, required BuildContext context}) {
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text("Checkout Error"),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.orange, size: 50),
                SizedBox(height: 16),
                Text(
                  "Unable to load checkout",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _retryFetchChannels,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.themeColor,
                  ),
                  child: Text("Retry"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error in getErrorDialog: $e");
      // Return a minimal error widget that won't crash
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("An error occurred"),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
