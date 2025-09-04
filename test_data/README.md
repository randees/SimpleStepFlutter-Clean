# Test Data

This folder contains test data files for import/export functionality and user persona testing.

## 📁 Organization

### Current Test Files:
- `female_college_athlete.json` - Complete test dataset for a 22-year-old track & field athlete

## 🧪 Test Data Format

All test files follow the **Import/Export Format Version 2.0** specification documented in `docs/USER_DATA_IMPORT_EXPORT_GUIDE.md`.

### Complete Data Coverage:
- ✅ User profile and demographics
- ✅ Device registrations (iOS, wearables, fitness trackers)
- ✅ Activity data (steps, workouts, training sessions)
- ✅ Vital signs (heart rate, blood pressure, VO2 max)
- ✅ Sleep data (quality, stages, recovery metrics)
- ✅ Nutrition data (meals, hydration, sports nutrition)
- ✅ Body measurements (weight, body fat, muscle mass)
- ✅ Wellness data (meditation, stress, energy levels)
- ✅ AI health insights and performance analysis
- ✅ Personalized recommendations
- ✅ Daily summaries and sync logs

## 🏃‍♀️ Female College Athlete Persona

**Profile**: Sarah, 22-year-old track & field athlete
**Data Date**: September 2, 2025
**Key Features**:
- High-performance athlete metrics (VO2 max: 62.5)
- Competition preparation data
- Sports-specific training (track intervals, strength training)
- Athletic nutrition and recovery protocols
- Pre-competition wellness and visualization
- DEXA scan body composition data
- Multiple device ecosystem (iPhone, Apple Watch, Polar HR monitor)

## 🚀 Usage Instructions

### Import Test Data:
1. Open User Management Modal in the app
2. Click the blue "Import" button
3. Select any `.json` file from this folder
4. Verify import across all health data tables
5. Test AI functionality with comprehensive dataset

### Export for Comparison:
1. Import test data first
2. Use "Export" button to download current user data
3. Compare with original test files to verify data integrity

## 📝 Future Test Personas

**Planned additions**:
- `male_office_worker.json` - Sedentary lifestyle with health goals
- `elderly_retiree.json` - Health monitoring and medication tracking
- `teenage_student.json` - Growth tracking and sleep patterns
- `pregnant_mother.json` - Prenatal health monitoring
- `chronic_condition.json` - Complex medical condition management

## 🔄 Test Data Maintenance

- **Update Frequency**: Test data should use current dates for realistic testing
- **Data Validation**: All files must pass import validation before committing
- **Persona Diversity**: Include various demographics, health goals, and activity levels
- **Device Coverage**: Test different device ecosystems and data sources

## 📋 Quality Checklist

Before adding new test files:
- [ ] Valid JSON format and structure
- [ ] All 11 health data tables represented
- [ ] Realistic data values for persona
- [ ] Current date references
- [ ] Unique user IDs (no conflicts)
- [ ] Comprehensive metadata
- [ ] Import/export tested successfully

---

💡 **Tip**: These test files are perfect for demonstrating the full capabilities of the SimpleStep health tracking system with realistic, comprehensive data across all health dimensions.
