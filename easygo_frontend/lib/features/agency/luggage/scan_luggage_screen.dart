import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';
import 'manage_luggage_status_screen.dart';

/// Turns the code on a luggage label into the status screen for that bag.
///
/// Typing the number is a first-class way in, not a fallback bolted on. Labels
/// get scuffed, and plenty of devices have no usable camera — a web build, a
/// desktop, a phone whose permission was refused. A screen that can only read a
/// code stops working at the counter the moment anything is imperfect, so both
/// routes run through the same lookup and land on the same screen.
///
/// The lookup is scoped by the backend to the signed-in staff member's agency,
/// so this screen cannot be used to find another agency's luggage. It reports
/// the refusal rather than hiding the field.
class ScanLuggageScreen extends StatefulWidget {
  const ScanLuggageScreen({super.key});

  @override
  State<ScanLuggageScreen> createState() => _ScanLuggageScreenState();
}

class _ScanLuggageScreenState extends State<ScanLuggageScreen> {
  final AgencyConsoleService _console = AgencyConsoleService.instance;

  final MobileScannerController _camera = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
    // A label held in front of the camera is read many times a second. Without
    // this the same bag would be looked up repeatedly, and the status screen
    // pushed on top of itself.
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final TextEditingController _manualController = TextEditingController();

  bool _isResolving = false;

  String? _message;

  @override
  void dispose() {
    _manualController.dispose();
    _camera.dispose();

    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isResolving || capture.barcodes.isEmpty) {
      return;
    }

    final String? raw = capture.barcodes.first.rawValue;

    if (raw == null) {
      return;
    }

    // Not awaited: onDetect is a callback, and the guard above is what keeps a
    // burst of frames from starting several lookups.
    _resolve(raw);
  }

  Future<void> _resolve(String raw) async {
    final String code = normalizeScannedCode(raw);

    if (code.isEmpty || _isResolving) {
      return;
    }

    // Read before the first await, so the strings are not fetched from a
    // BuildContext that may be gone by the time the request answers.
    final AppLocalizations l10n = AppLocalizations.of(context);

    setState(() {
      _isResolving = true;
      _message = null;
    });

    try {
      final ConsoleLuggage? luggage = await _console.findLuggage(code);

      if (!mounted) {
        return;
      }

      setState(() {
        _isResolving = false;
      });

      if (luggage == null) {
        setState(() {
          _message = l10n.noLuggageForScannedCode;
        });

        return;
      }

      _manualController.clear();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ManageLuggageStatusScreen(luggage: consoleLuggageToCard(luggage)),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message = error.statusCode == 404
            ? l10n.noLuggageForScannedCode
            : error.message;
        _isResolving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanLuggage)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  _buildCamera(context),
                  const SizedBox(height: 16),
                  _buildInstructions(context, l10n),
                  if (_isResolving) ...[
                    const SizedBox(height: 18),
                    const CircularProgressIndicator(),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 18),
                    _buildMessage(context, _message!),
                  ],
                  const SizedBox(height: 18),
                  _buildManualEntry(context, l10n),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamera(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _camera,
              onDetect: _onDetect,
              // Shown in place of the preview. The manual field below is always
              // on screen, so there is nothing to enable when this appears.
              errorBuilder: (context, error) => _buildCameraUnavailable(context),
            ),
            const _ScanFrame(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraUnavailable(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0D1B2A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white70,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).cameraUnavailable,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_scanner_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.scanLuggageDescription,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String message) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _manualController,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (String value) {
              _resolve(value);
            },
            decoration: InputDecoration(
              labelText: l10n.trackingReference,
              hintText: 'LUG-XXXXXXXX-XXXXXX',
              prefixIcon: const Icon(Icons.luggage_outlined),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isResolving
                  ? null
                  : () {
                      _resolve(_manualController.text);
                    },
              icon: const Icon(Icons.search_outlined),
              label: Text(l10n.findLuggage),
            ),
          ),
        ],
      ),
    );
  }
}

/// The frame the code is meant to sit inside.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).scanLuggageFrameHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The tracking number inside whatever a luggage code happens to contain.
///
/// Codes are written as the bare tracking number today. Reading the last path
/// segment as well costs nothing and means a code that encodes a link — a
/// support URL, an app link — still resolves instead of being refused, and the
/// number is upper-cased because that is how the platform stores it.
String normalizeScannedCode(String raw) {
  final String trimmed = raw.trim();

  if (trimmed.isEmpty) {
    return '';
  }

  final Uri? uri = Uri.tryParse(trimmed);

  final String candidate = uri != null && uri.pathSegments.isNotEmpty
      ? uri.pathSegments.last
      : trimmed;

  return candidate.trim().toUpperCase();
}
