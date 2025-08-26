// @deno-types="https://esm.sh/@supabase/supabase-js@2.33.1/dist/module/index.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.33.1'

export interface StepSummary {
  totalSteps: number
  averageSteps: number
  mostActiveDay: { date: string; steps: number }
  leastActiveDay: { date: string; steps: number }
  weeklyPattern: { [key: string]: number }
  dailyData: Array<{ date: string; steps: number }>
}

export async function getStepSummary(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  startDate: string,
  endDate: string
): Promise<StepSummary> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  // Query step data from existing step_data table
  const { data: stepData, error } = await supabase
    .from('step_data')
    .select('*')
    .gte('date', startDate)
    .lte('date', endDate)
    .order('date', { ascending: true })

  if (error) {
    throw new Error(`Failed to fetch step data: ${error.message}`)
  }

  // Calculate analytics
  const steps = stepData || []
  const totalSteps = steps.reduce((sum, day) => sum + (day.step_count || 0), 0)
  const averageSteps = steps.length > 0 ? Math.round(totalSteps / steps.length) : 0
  
  // Find most and least active days
  const sortedBySteps = [...steps].sort((a, b) => (b.step_count || 0) - (a.step_count || 0))
  const mostActiveDay = sortedBySteps[0] ? { 
    date: sortedBySteps[0].date, 
    steps: sortedBySteps[0].step_count || 0 
  } : { date: '', steps: 0 }
  
  const leastActiveDay = sortedBySteps[sortedBySteps.length - 1] ? {
    date: sortedBySteps[sortedBySteps.length - 1].date,
    steps: sortedBySteps[sortedBySteps.length - 1].step_count || 0
  } : { date: '', steps: 0 }

  // Calculate weekly pattern (day of week averages)
  const weeklyPattern: { [key: string]: number } = {}
  const dayTotals: { [key: string]: { total: number; count: number } } = {}
  
  steps.forEach(day => {
    const dayOfWeek = new Date(day.date).toLocaleDateString('en-US', { weekday: 'long' })
    if (!dayTotals[dayOfWeek]) {
      dayTotals[dayOfWeek] = { total: 0, count: 0 }
    }
    dayTotals[dayOfWeek].total += day.step_count || 0
    dayTotals[dayOfWeek].count += 1
  })

  Object.keys(dayTotals).forEach(day => {
    weeklyPattern[day] = Math.round(dayTotals[day].total / dayTotals[day].count)
  })

  return {
    totalSteps,
    averageSteps,
    mostActiveDay,
    leastActiveDay,
    weeklyPattern,
    dailyData: steps.map(d => ({ date: d.date, steps: d.step_count || 0 }))
  }
}

export async function getActivityPatterns(
  supabaseUrl: string,
  supabaseKey: string,
  days: number = 30
): Promise<StepSummary> {
  const endDate = new Date().toISOString().split('T')[0]
  const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  
  // For existing step_data table, we don't need userId parameter
  return await getStepSummary(supabaseUrl, supabaseKey, '', startDate, endDate)
}
