const fs = require('fs');
const path = require('path');

console.log('🧪 Simulating Export Function Behavior');

// Read the test data file
const testDataPath = path.join(__dirname, 'test_data', 'user_data_Sarah Martinez_1756999481008.json');
const testData = JSON.parse(fs.readFileSync(testDataPath, 'utf8'));

console.log('🔄 Simulating exportUserData() function...');

// Simulate the export process
function simulateExport(userData) {
  console.log('   - Processing user profile...');
  const cleanUserProfile = { ...userData.user_profile };
  // Remove id from user profile
  delete cleanUserProfile.id;

  console.log('   - Processing user devices...');
  const cleanUserDevices = userData.user_devices.map(device => {
    const cleaned = { ...device };
    // Remove database fields
    delete cleaned.id;
    delete cleaned.user_id;
    delete cleaned.updated_at;
    return cleaned;
  });

  console.log('   - Processing genetic insights...');
  const cleanGeneticInsights = userData.genetic_insights.map(insight => {
    const cleaned = { ...insight };
    // Remove database fields that should not be in export
    delete cleaned.id;
    delete cleaned.user_id;
    delete cleaned.created_at;
    delete cleaned.updated_at;
    return cleaned;
  });

  // Calculate totals
  const totalRecords = cleanUserDevices.length + cleanGeneticInsights.length + 1; // +1 for user profile

  const exportData = {
    'export_metadata': {
      'export_format_version': '1.0.0',
      'export_date': new Date().toISOString(),
      'exported_by': 'System',
      'total_records': totalRecords,
      'device_count': cleanUserDevices.length,
      'genetic_insights_count': cleanGeneticInsights.length,
    },
    'user_profile': cleanUserProfile,
    'user_devices': cleanUserDevices,
    'genetic_insights': cleanGeneticInsights,
  };

  return exportData;
}

// Run the simulation
const simulatedExport = simulateExport(testData);

console.log('\n📤 Simulated Export Results:');
console.log(`   - Total Records: ${simulatedExport.export_metadata.total_records}`);
console.log(`   - Device Count: ${simulatedExport.export_metadata.device_count}`);
console.log(`   - Genetic Insights Count: ${simulatedExport.export_metadata.genetic_insights_count}`);

console.log('\n🔍 Genetic Insights in Export:');
console.log(`   - Type: ${Array.isArray(simulatedExport.genetic_insights) ? 'Array' : 'Object'}`);
console.log(`   - Length: ${simulatedExport.genetic_insights.length}`);

if (simulatedExport.genetic_insights.length > 0) {
  const firstInsight = simulatedExport.genetic_insights[0];
  console.log(`   - Keys: ${Object.keys(firstInsight).join(', ')}`);

  if (firstInsight.data) {
    console.log('   ✅ Contains "data" field');
  }

  if (firstInsight.meta_data) {
    console.log('   ✅ Contains "meta_data" field');
  }

  // Check for database fields that should be removed
  if (firstInsight.id) {
    console.log('   ❌ ERROR: Still contains "id" field');
  } else {
    console.log('   ✅ "id" field properly removed');
  }

  if (firstInsight.user_id) {
    console.log('   ❌ ERROR: Still contains "user_id" field');
  } else {
    console.log('   ✅ "user_id" field properly removed');
  }
}

// Compare with original import format
console.log('\n🔄 Format Compatibility Check:');
const originalGeneticInsights = testData.genetic_insights;
const exportedGeneticInsights = simulatedExport.genetic_insights;

if (JSON.stringify(originalGeneticInsights) === JSON.stringify(exportedGeneticInsights)) {
  console.log('   ✅ Export format matches import format exactly!');
} else {
  console.log('   ⚠️ Export format differs from import format');
  console.log('   Original keys:', Object.keys(originalGeneticInsights[0]));
  console.log('   Exported keys:', Object.keys(exportedGeneticInsights[0]));
}

// Save simulated export for inspection
const outputPath = path.join(__dirname, 'simulated_export_output.json');
fs.writeFileSync(outputPath, JSON.stringify(simulatedExport, null, 2));
console.log(`\n💾 Simulated export saved to: ${outputPath}`);

console.log('\n✅ Export simulation complete!');
console.log('🎯 The actual export function should produce identical results.');
