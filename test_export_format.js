const fs = require('fs');
const path = require('path');

console.log('🧪 Testing Export Format Compatibility');

// Read the test data file
const testDataPath = path.join(__dirname, 'test_data', 'user_data_Sarah Martinez_1756999481008.json');
const testData = JSON.parse(fs.readFileSync(testDataPath, 'utf8'));

console.log('📋 Test Data Analysis:');
console.log(`   - Total Records: ${testData.export_metadata.total_records}`);
console.log(`   - Device Count: ${testData.export_metadata.device_count}`);
console.log(`   - Genetic Insights Count: ${testData.export_metadata.genetic_insights_count}`);

console.log('\n🔍 Genetic Insights Structure:');
console.log(`   - Type: ${Array.isArray(testData.genetic_insights) ? 'Array' : 'Object'}`);
console.log(`   - Length: ${testData.genetic_insights.length}`);

if (testData.genetic_insights.length > 0) {
  const firstInsight = testData.genetic_insights[0];
  console.log(`   - Keys: ${Object.keys(firstInsight).join(', ')}`);

  if (firstInsight.data) {
    console.log('   ✅ Contains "data" field');
    console.log(`   - Data keys: ${Object.keys(firstInsight.data).join(', ')}`);
  } else {
    console.log('   ❌ Missing "data" field');
  }

  if (firstInsight.meta_data) {
    console.log('   ✅ Contains "meta_data" field');
    console.log(`   - Meta data keys: ${Object.keys(firstInsight.meta_data).join(', ')}`);
  } else {
    console.log('   ❌ Missing "meta_data" field');
  }

  // Check for database fields that should NOT be present
  if (firstInsight.id) {
    console.log('   ❌ Contains "id" field (should be removed in export)');
  } else {
    console.log('   ✅ No "id" field (correct for export format)');
  }

  if (firstInsight.user_id) {
    console.log('   ❌ Contains "user_id" field (should be removed in export)');
  } else {
    console.log('   ✅ No "user_id" field (correct for export format)');
  }

  if (firstInsight.created_at) {
    console.log('   ❌ Contains "created_at" field (should be removed in export)');
  } else {
    console.log('   ✅ No "created_at" field (correct for export format)');
  }

  if (firstInsight.updated_at) {
    console.log('   ❌ Contains "updated_at" field (should be removed in export)');
  } else {
    console.log('   ✅ No "updated_at" field (correct for export format)');
  }
}

console.log('\n📊 Expected Export Structure:');
console.log('   genetic_insights: [');
console.log('     {');
console.log('       "data": { ... },');
console.log('       "meta_data": { ... }');
console.log('     }');
console.log('   ]');

console.log('\n✅ Test data format validation complete!');
console.log('💡 The export function should produce this exact structure.');
