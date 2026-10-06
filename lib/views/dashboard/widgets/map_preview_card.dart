import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/location_service.dart';

class MapPreviewCard extends StatefulWidget {
  final LocationResult? location;
  final bool isLoading;
  final VoidCallback onRefresh;

  const MapPreviewCard({
    super.key,
    required this.location,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<MapPreviewCard> createState() => _MapPreviewCardState();
}

class _MapPreviewCardState extends State<MapPreviewCard> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant MapPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != null &&
        (oldWidget.location?.latitude != widget.location!.latitude ||
            oldWidget.location?.longitude != widget.location!.longitude)) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.location!.latitude, widget.location!.longitude),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final LatLng currentLatLng = widget.location != null
        ? LatLng(widget.location!.latitude, widget.location!.longitude)
        : const LatLng(-6.2088, 106.8456); // Default Jakarta

    final markers = <Marker>{
      if (widget.location != null)
        Marker(
          markerId: const MarkerId('user_location'),
          position: currentLatLng,
          infoWindow: InfoWindow(
            title: 'Lokasi Anda',
            snippet: widget.location!.address,
          ),
        ),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Keberadaan Anda Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                  tooltip: 'Segarkan Lokasi',
                  onPressed: widget.isLoading ? null : widget.onRefresh,
                ),
              ],
            ),
          ),

          // Peta
          SizedBox(
            height: 180,
            width: double.infinity,
            child: ClipRRect(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLatLng,
                  zoom: 16.0,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: markers,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ),

          // Baris Alamat (Dapat ditekan untuk menyegarkan/mendeteksi ulang titik koordinat)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              onTap: widget.isLoading ? null : widget.onRefresh,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.location?.address ??
                            'Sedang mendeteksi titik koordinat...',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
