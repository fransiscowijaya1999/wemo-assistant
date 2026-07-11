// CRM feature exports
library crm;

export 'data/data.dart';
export 'screens/customer_list_screen.dart';
export 'screens/customer_detail_screen.dart';
export 'screens/customer_edit_screen.dart';
export 'screens/vehicle_detail_screen.dart';
export 'screens/vehicle_edit_screen.dart';
export 'screens/record_list_screen.dart';
export 'screens/record_detail_screen.dart';
export 'screens/record_edit_screen.dart';
export 'screens/record_item_edit_screen.dart';
export 'screens/customer_search_screen.dart';

// Constants
const kMaintenanceRecordTypes = ['service', 'purchase'];
const kMaintenanceItemCategories = [
  'bearing', 'chain', 'sprocket', 'oil', 'tire', 'brake_pad', 'battery', 'spark_plug',
  'filter', 'seal', 'gasket', 'engine_part', 'body_part', 'electrical', 'other'
];
const kWarrantyPeriodUnits = ['days', 'months'];