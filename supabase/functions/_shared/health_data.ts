import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface HealthSummaryResult {
  user_profile: any
  activity_data: any[]
  vital_signs: any[]
  sleep_data: any[]
  nutrition_data: any[]
  wellness_data: any[]
  health_insights: any[]
  date_range: {
    start_date: string
    end_date: string
    days: number
  }
}

export interface VitalSignsResult {
  vital_signs: any[]
  summary: {
    total_measurements: number
    measurement_types: string[]
    date_range: {
      start_date: string
      end_date: string
    }
  }
}

export interface SleepAnalysisResult {
  sleep_records: any[]
  summary: {
    total_nights: number
    avg_sleep_hours: number
    avg_sleep_quality: number
    avg_sleep_efficiency: number
    date_range: {
      start_date: string
      end_date: string
    }
  }
}

export interface NutritionAnalysisResult {
  nutrition_records: any[]
  summary: {
    total_days: number
    total_calories: number
    avg_daily_calories: number
    total_protein_g: number
    total_carbs_g: number
    total_fat_g: number
    total_water_ml: number
    avg_daily_water_ml: number
    date_range: {
      start_date: string
      end_date: string
    }
  }
}

export interface WellnessMetricsResult {
  wellness_records: any[]
  summary: {
    total_entries: number
    wellness_averages: Record<string, number>
    date_range: {
      start_date: string
      end_date: string
    }
  }
}

export async function getHealthSummary(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  days: number = 7
): Promise<HealthSummaryResult> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  const endDate = new Date()
  const startDate = new Date(endDate.getTime() - (days * 24 * 60 * 60 * 1000))
  
  try {
    // Get user profile
    const { data: userProfile } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single()

    // Get recent activity data
    const { data: activityData } = await supabase
      .from('activity_data')
      .select('*')
      .eq('user_id', userId)
      .gte('start_time', startDate.toISOString())
      .lte('start_time', endDate.toISOString())
      .order('start_time', { ascending: false })

    // Get recent vital signs
    const { data: vitalSigns } = await supabase
      .from('vital_signs')
      .select('*')
      .eq('user_id', userId)
      .gte('measured_at', startDate.toISOString())
      .lte('measured_at', endDate.toISOString())
      .order('measured_at', { ascending: false })

    // Get recent sleep data
    const { data: sleepData } = await supabase
      .from('sleep_data')
      .select('*')
      .eq('user_id', userId)
      .gte('sleep_date', startDate.toISOString().split('T')[0])
      .lte('sleep_date', endDate.toISOString().split('T')[0])
      .order('sleep_date', { ascending: false })

    // Get recent nutrition data
    const { data: nutritionData } = await supabase
      .from('nutrition_data')
      .select('*')
      .eq('user_id', userId)
      .gte('logged_at', startDate.toISOString())
      .lte('logged_at', endDate.toISOString())
      .order('logged_at', { ascending: false })

    // Get recent wellness data
    const { data: wellnessData } = await supabase
      .from('wellness_data')
      .select('*')
      .eq('user_id', userId)
      .gte('recorded_at', startDate.toISOString())
      .lte('recorded_at', endDate.toISOString())
      .order('recorded_at', { ascending: false })

    // Get recent health insights
    const { data: healthInsights } = await supabase
      .from('health_insights')
      .select('*')
      .eq('user_id', userId)
      .gte('generated_at', startDate.toISOString())
      .order('generated_at', { ascending: false })
      .limit(5)

    return {
      user_profile: userProfile || null,
      activity_data: activityData || [],
      vital_signs: vitalSigns || [],
      sleep_data: sleepData || [],
      nutrition_data: nutritionData || [],
      wellness_data: wellnessData || [],
      health_insights: healthInsights || [],
      date_range: {
        start_date: startDate.toISOString().split('T')[0],
        end_date: endDate.toISOString().split('T')[0],
        days: days
      }
    }
  } catch (error) {
    console.error('Error getting health summary:', error)
    throw error
  }
}

export async function getVitalSigns(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  startDate: string,
  endDate: string,
  measurementType?: string
): Promise<VitalSignsResult> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  try {
    let query = supabase
      .from('vital_signs')
      .select('*')
      .eq('user_id', userId)
      .gte('measured_at', new Date(startDate).toISOString())
      .lte('measured_at', new Date(endDate).toISOString())

    if (measurementType) {
      query = query.eq('measurement_type', measurementType)
    }

    const { data: vitalSigns } = await query.order('measured_at', { ascending: false })

    const measurementTypes = [...new Set((vitalSigns || []).map(v => v.measurement_type))]

    return {
      vital_signs: vitalSigns || [],
      summary: {
        total_measurements: (vitalSigns || []).length,
        measurement_types: measurementTypes,
        date_range: {
          start_date: startDate,
          end_date: endDate
        }
      }
    }
  } catch (error) {
    console.error('Error getting vital signs:', error)
    throw error
  }
}

export async function getSleepAnalysis(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  days: number = 7
): Promise<SleepAnalysisResult> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  const endDate = new Date()
  const startDate = new Date(endDate.getTime() - (days * 24 * 60 * 60 * 1000))
  
  try {
    const { data: sleepData } = await supabase
      .from('sleep_data')
      .select('*')
      .eq('user_id', userId)
      .gte('sleep_date', startDate.toISOString().split('T')[0])
      .lte('sleep_date', endDate.toISOString().split('T')[0])
      .order('sleep_date', { ascending: false })

    if (!sleepData || sleepData.length === 0) {
      return {
        sleep_records: [],
        summary: {
          total_nights: 0,
          avg_sleep_hours: 0,
          avg_sleep_quality: 0,
          avg_sleep_efficiency: 0,
          date_range: {
            start_date: startDate.toISOString().split('T')[0],
            end_date: endDate.toISOString().split('T')[0]
          }
        }
      }
    }

    const totalRecords = sleepData.length
    const avgSleepMinutes = sleepData.reduce((sum, record) => sum + (record.total_sleep_minutes || 0), 0) / totalRecords
    const avgSleepQuality = sleepData.reduce((sum, record) => sum + (record.sleep_quality_score || 0), 0) / totalRecords
    const avgSleepEfficiency = sleepData.reduce((sum, record) => sum + (record.sleep_efficiency || 0), 0) / totalRecords

    return {
      sleep_records: sleepData,
      summary: {
        total_nights: totalRecords,
        avg_sleep_hours: Math.round(avgSleepMinutes / 60),
        avg_sleep_quality: Math.round(avgSleepQuality),
        avg_sleep_efficiency: Math.round(avgSleepEfficiency),
        date_range: {
          start_date: startDate.toISOString().split('T')[0],
          end_date: endDate.toISOString().split('T')[0]
        }
      }
    }
  } catch (error) {
    console.error('Error getting sleep analysis:', error)
    throw error
  }
}

export async function getNutritionAnalysis(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  days: number = 7
): Promise<NutritionAnalysisResult> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  const endDate = new Date()
  const startDate = new Date(endDate.getTime() - (days * 24 * 60 * 60 * 1000))
  
  try {
    const { data: nutritionData } = await supabase
      .from('nutrition_data')
      .select('*')
      .eq('user_id', userId)
      .gte('logged_at', startDate.toISOString())
      .lte('logged_at', endDate.toISOString())
      .order('logged_at', { ascending: false })

    if (!nutritionData || nutritionData.length === 0) {
      return {
        nutrition_records: [],
        summary: {
          total_days: days,
          total_calories: 0,
          avg_daily_calories: 0,
          total_protein_g: 0,
          total_carbs_g: 0,
          total_fat_g: 0,
          total_water_ml: 0,
          avg_daily_water_ml: 0,
          date_range: {
            start_date: startDate.toISOString().split('T')[0],
            end_date: endDate.toISOString().split('T')[0]
          }
        }
      }
    }

    const totalCalories = nutritionData.reduce((sum, record) => sum + (record.calories || 0), 0)
    const totalProtein = nutritionData.reduce((sum, record) => sum + (record.protein_g || 0), 0)
    const totalCarbs = nutritionData.reduce((sum, record) => sum + (record.carbs_g || 0), 0)
    const totalFat = nutritionData.reduce((sum, record) => sum + (record.fat_g || 0), 0)
    const totalWater = nutritionData.reduce((sum, record) => sum + (record.water_ml || 0), 0)

    return {
      nutrition_records: nutritionData,
      summary: {
        total_days: days,
        total_calories: Math.round(totalCalories),
        avg_daily_calories: Math.round(totalCalories / days),
        total_protein_g: Math.round(totalProtein),
        total_carbs_g: Math.round(totalCarbs),
        total_fat_g: Math.round(totalFat),
        total_water_ml: Math.round(totalWater),
        avg_daily_water_ml: Math.round(totalWater / days),
        date_range: {
          start_date: startDate.toISOString().split('T')[0],
          end_date: endDate.toISOString().split('T')[0]
        }
      }
    }
  } catch (error) {
    console.error('Error getting nutrition analysis:', error)
    throw error
  }
}

export async function getWellnessMetrics(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  days: number = 7
): Promise<WellnessMetricsResult> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  const endDate = new Date()
  const startDate = new Date(endDate.getTime() - (days * 24 * 60 * 60 * 1000))
  
  try {
    const { data: wellnessData } = await supabase
      .from('wellness_data')
      .select('*')
      .eq('user_id', userId)
      .gte('recorded_at', startDate.toISOString())
      .lte('recorded_at', endDate.toISOString())
      .order('recorded_at', { ascending: false })

    if (!wellnessData || wellnessData.length === 0) {
      return {
        wellness_records: [],
        summary: {
          total_entries: 0,
          wellness_averages: {},
          date_range: {
            start_date: startDate.toISOString().split('T')[0],
            end_date: endDate.toISOString().split('T')[0]
          }
        }
      }
    }

    // Group by wellness type and calculate averages
    const wellnessTypes: Record<string, number[]> = {}
    for (const record of wellnessData) {
      const type = record.wellness_type
      const value = record.value_numeric || 0
      if (!wellnessTypes[type]) {
        wellnessTypes[type] = []
      }
      wellnessTypes[type].push(value)
    }

    const averages: Record<string, number> = {}
    Object.entries(wellnessTypes).forEach(([type, values]) => {
      averages[type] = values.reduce((a, b) => a + b, 0) / values.length
    })

    return {
      wellness_records: wellnessData,
      summary: {
        total_entries: wellnessData.length,
        wellness_averages: averages,
        date_range: {
          start_date: startDate.toISOString().split('T')[0],
          end_date: endDate.toISOString().split('T')[0]
        }
      }
    }
  } catch (error) {
    console.error('Error getting wellness metrics:', error)
    throw error
  }
}

export async function getHealthInsights(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  category?: string,
  limit: number = 5
): Promise<any[]> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  try {
    let query = supabase
      .from('health_insights')
      .select('*')
      .eq('user_id', userId)

    if (category) {
      query = query.eq('category', category)
    }

    const { data: healthInsights } = await query
      .order('generated_at', { ascending: false })
      .limit(limit)

    return healthInsights || []
  } catch (error) {
    console.error('Error getting health insights:', error)
    throw error
  }
}
