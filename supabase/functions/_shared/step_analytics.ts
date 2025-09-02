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
  
  // Query step data from existing activity_data table
  const { data: stepData, error } = await supabase
    .from('activity_data')
    .select('start_time, steps')
    .eq('user_id', userId)
    .eq('activity_type', 'steps')
    .gte('start_time', startDate)
    .lte('start_time', endDate + 'T23:59:59')
    .order('start_time', { ascending: true })

  if (error) {
    throw new Error(`Failed to fetch step data: ${error.message}`)
  }

  // Calculate analytics
  const steps = stepData || []
  const totalSteps = steps.reduce((sum, day) => sum + (day.steps || 0), 0)
  const averageSteps = steps.length > 0 ? Math.round(totalSteps / steps.length) : 0
  
  // Find most and least active days
  const sortedBySteps = [...steps].sort((a, b) => (b.steps || 0) - (a.steps || 0))
  const mostActiveDay = sortedBySteps[0] ? { 
    date: sortedBySteps[0].start_time.split('T')[0], 
    steps: sortedBySteps[0].steps || 0 
  } : { date: '', steps: 0 }
  
  const leastActiveDay = sortedBySteps[sortedBySteps.length - 1] ? {
    date: sortedBySteps[sortedBySteps.length - 1].start_time.split('T')[0],
    steps: sortedBySteps[sortedBySteps.length - 1].steps || 0
  } : { date: '', steps: 0 }

  // Calculate weekly pattern (day of week averages)
  const weeklyPattern: { [key: string]: number } = {}
  const dayTotals: { [key: string]: { total: number; count: number } } = {}
  
  steps.forEach(day => {
    const dayOfWeek = new Date(day.start_time).toLocaleDateString('en-US', { weekday: 'long' })
    if (!dayTotals[dayOfWeek]) {
      dayTotals[dayOfWeek] = { total: 0, count: 0 }
    }
    dayTotals[dayOfWeek].total += day.steps || 0
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
    dailyData: steps.map(d => ({ date: d.start_time.split('T')[0], steps: d.steps || 0 }))
  }
}

export async function getActivityPatterns(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  days: number = 30
): Promise<StepSummary> {
  const endDate = new Date().toISOString().split('T')[0]
  const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  
  // Use proper userId for activity_data table
  return await getStepSummary(supabaseUrl, supabaseKey, userId, startDate, endDate)
}
