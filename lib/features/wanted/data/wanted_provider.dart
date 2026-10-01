import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/wanted_request.dart';
import '../../vehicles/data/mock_data.dart';

class WantedNotifier extends StateNotifier<List<WantedRequest>> {
  WantedNotifier() : super(MockData.getInitialWantedRequests());

  void addWantedRequest(WantedRequest req) {
    state = [req, ...state];
  }

  void toggleStatus(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isActive: !r.isActive) else r,
    ];
  }
}

final wantedProvider =
    StateNotifierProvider<WantedNotifier, List<WantedRequest>>((ref) {
  return WantedNotifier();
});
