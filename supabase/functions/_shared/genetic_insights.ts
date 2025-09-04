import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface GeneticInsight {
  id: string
  user_id: string
  title: string
  description: string
  category: string
  recommendations?: string
  confidence_score: number
  created_at: string
  data?: any
}

export async function getGeneticInsights(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  insightType?: string,
  limit: number = 10
): Promise<GeneticInsight[]> {
  const supabase = createClient(supabaseUrl, supabaseKey)

  try {
    let query = supabase
      .from('genetic_insights')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit)

    // Filter by insight type if specified
    if (insightType && insightType !== 'all') {
      query = query.eq('category', insightType)
    }

    const { data, error } = await query

    if (error) {
      console.error('Error fetching genetic insights:', error)
      return []
    }

    return data || []
  } catch (error) {
    console.error('Exception fetching genetic insights:', error)
    return []
  }
}
