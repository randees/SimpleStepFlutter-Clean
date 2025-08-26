// @deno-types="https://esm.sh/@supabase/supabase-js@2.33.1/dist/module/index.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.33.1'

export interface AuthResult {
  user: any
  error: string | null
}

export async function authenticateRequest(
  request: Request,
  supabaseUrl: string,
  supabaseKey: string
): Promise<AuthResult> {
  const authHeader = request.headers.get('Authorization')
  
  if (!authHeader) {
    return { user: null, error: 'Missing Authorization header' }
  }

  const token = authHeader.replace('Bearer ', '')
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  const { data: { user }, error } = await supabase.auth.getUser(token)
  
  if (error || !user) {
    return { user: null, error: 'Invalid token' }
  }

  return { user, error: null }
}

export function validateMCPSecret(request: Request, secret: string): boolean {
  const mcpSecret = request.headers.get('X-MCP-Secret')
  return mcpSecret === secret
}
