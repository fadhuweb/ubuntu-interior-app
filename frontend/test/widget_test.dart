import 'package:flutter_test/flutter_test.dart';

import 'package:ubuntu_app/utils/constants.dart';

void main() {
  test('AppConstants keep the layout values the UI expects', () {
    expect(AppConstants.padding, 16.0);
    expect(AppConstants.radius, 12.0);
    expect(AppConstants.animationDuration, const Duration(milliseconds: 300));
  });
}
