import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/driver_cubit.dart';
import '../cubit/driver_state.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  final TextEditingController _bookingController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanHandled = false;

  @override
  void initState() {
    super.initState();
    _scannerController.start().then((_) {
      print("DEBUG: MobileScannerController started successfully");
    }).catchError((e) {
      print("DEBUG: MobileScannerController failed to start: $e");
    });
  }

  @override
  void dispose() {
    _bookingController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverCubit, DriverState>(
      listenWhen: (previous, current) =>
          previous.isVerifying != current.isVerifying ||
          previous.verificationSuccess != current.verificationSuccess,
      listener: (context, state) {
        if (!state.isVerifying && state.verificationSuccess != null) {
          if (state.verificationSuccess == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.verificationMessage ?? 'Passenger checked in!'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context); // Close dialog on success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.verificationMessage ?? 'Failed to verify passenger.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            // Allow scanning again if verification failed
            setState(() {
              _isScanHandled = false;
            });
          }
          // Clear status in cubit
          context.read<DriverCubit>().clearVerificationState();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "QR Passenger Scan",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Real Scanner Widget
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _scannerController,
                        builder: (context, value, child) {
                          if (!value.isInitialized) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          print("DEBUG: Scanner Lifecycle - Status: ${value.isInitialized ? 'Initialized' : 'Not Initialized'}");
                          return MobileScanner(
                            controller: _scannerController,
                            errorBuilder: (context, error, child) {
                              print("DEBUG: Scanner Error: ${error.errorCode}");
                              print("DEBUG: Scanner Error Message: ${error.errorDetails?.message}");
                              
                              String message = "Camera error";
                              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                                message = "Camera permission denied";
                                print("DEBUG: Scanner Lifecycle - Permission Denied");
                              } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
                                message = "Camera unavailable";
                                print("DEBUG: Scanner Lifecycle - Camera Unavailable");
                              }
                              
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white, size: 40),
                                    const SizedBox(height: 8),
                                    Text(message, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                            onDetect: (capture) {
                              if (_isScanHandled) return;
                              
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty) {
                                final String? code = barcodes.first.rawValue;
                                if (code != null && code.isNotEmpty) {
                                  print("DEBUG: QR Code Detected: $code");
                                  setState(() {
                                    _isScanHandled = true;
                                  });
                                  // Extract bookingId (assumes raw value is the ID)
                                  context.read<DriverCubit>().verifyPassenger(code);
                                }
                              }
                            },
                          );
                        },
                      ),
                      // Scanner Overlay
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      // Animated scanning line
                      const _ScannerLine(),
                      // Loading indicator when verifying
                      BlocBuilder<DriverCubit, DriverState>(
                        builder: (context, state) {
                          if (state.isVerifying) {
                            return Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Position QR code inside the frame",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              // Manual input field fallback
              AppTextField(
                controller: _bookingController,
                hintText: "Enter Booking ID manually",
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              BlocBuilder<DriverCubit, DriverState>(
                builder: (context, state) {
                  return AppButton(
                    label: "Verify Manually",
                    isLoading: state.isVerifying,
                    onPressed: () {
                      final bookingId = _bookingController.text.trim();
                      if (bookingId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a booking ID"),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _isScanHandled = true;
                      });
                      context.read<DriverCubit>().verifyPassenger(bookingId);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerLine extends StatefulWidget {
  const _ScannerLine();

  @override
  State<_ScannerLine> createState() => _ScannerLineState();
}

class _ScannerLineState extends State<_ScannerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 40 + (160 * _controller.value),
          left: 30,
          right: 30,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
