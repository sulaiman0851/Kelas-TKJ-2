import type { APIRoute } from 'astro';
import { createClient } from '@supabase/supabase-js';

// Create admin client with service role key
const supabaseAdmin = createClient(
  import.meta.env.PUBLIC_SUPABASE_URL,
  import.meta.env.SUPABASE_SERVICE_ROLE_KEY
);

export const POST: APIRoute = async ({ request, locals }) => {
  try {
    // Check if user is authenticated
    const { data: { session } } = await supabaseAdmin.auth.getSession();
    // Use the session from locally provided context if available, or fetch it
    // Actually in Astro SSR, we should check the local session
    const localSession = locals.session;
    
    if (!localSession) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Check if user is admin
    const { data: userRoles } = await supabaseAdmin
      .from('user_roles')
      .select('*, roles(*)')
      .eq('user_id', localSession.user.id);

    const isAdmin = userRoles?.some(ur => ur.roles?.name === 'admin');
    
    if (!isAdmin) {
      return new Response(JSON.stringify({ error: 'Forbidden: Admin only' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Get request body
    const body = await request.json();
    const { userId } = body;

    if (!userId) {
      return new Response(JSON.stringify({ error: 'Missing userId' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Safety: Admin cannot delete themselves
    if (userId === localSession.user.id) {
       return new Response(JSON.stringify({ error: 'You cannot delete yourself' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Delete user using admin client
    // This removes the user from auth.users, and cascades will handle profiles/user_roles
    const { error } = await supabaseAdmin.auth.admin.deleteUser(userId);

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'User deleted successfully'
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
