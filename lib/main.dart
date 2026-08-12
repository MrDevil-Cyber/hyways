import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'services/auth_session_store.dart';

part 'app.dart';
part 'data/home_data.dart';
part 'screens/landing_page.dart';
part 'screens/about_us_page.dart';
part 'screens/product_detail_page.dart';
part 'screens/products_hub_page.dart';
part 'screens/services/machine_scan_flow.dart';
part 'screens/services/service_request_flow.dart';
part 'screens/services/services_page.dart';
part 'screens/services/space_planner_flow.dart';
part 'services/hyway_api.dart';
part 'widgets/bottom_nav.dart';
part 'widgets/common_widgets.dart';
part 'widgets/contact_card.dart';
part 'widgets/hero_section.dart';
part 'widgets/impact_strip.dart';
part 'widgets/industries_section.dart';
part 'widgets/products_section.dart';
part 'widgets/stats_strip.dart';
part 'widgets/why_choose.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Hyway());
}
