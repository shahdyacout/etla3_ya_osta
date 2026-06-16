import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  final String bookingId;

  const PaymentWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.bookingId,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('WebView started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('WebView finished: $url');
            setState(() => _isLoading = false);
            _checkPaymentResult(url);
          },
          onNavigationRequest: (request) {
            final url = request.url;
            debugPrint('WebView navigation: $url');

            // Check for Paymob success/failure patterns
            if (_isSuccessUrl(url)) {
              debugPrint('Payment SUCCESS detected');
              _returnResult('success');
              return NavigationDecision.prevent;
            }
            if (_isFailureUrl(url)) {
              debugPrint('Payment FAILURE detected');
              _returnResult('failure');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _isSuccessUrl(String url) {
    // Paymob success patterns
    return url.contains('success=true') ||
        url.contains('success=true') ||
        url.contains('response_code=') && url.contains('success') ||
        url.contains('/accept') && url.contains('success');
  }

  bool _isFailureUrl(String url) {
    // Paymob failure patterns
    return url.contains('success=false') ||
        url.contains('error') ||
        url.contains('declined') ||
        url.contains('failed');
  }

  void _checkPaymentResult(String url) {
    if (_hasResult) return;

    // Check on page load as well (some redirects happen on page load)
    if (_isSuccessUrl(url)) {
      _returnResult('success');
    } else if (_isFailureUrl(url)) {
      _returnResult('failure');
    }
  }

  void _returnResult(String result) {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => _returnResult('cancelled'),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading payment page...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
