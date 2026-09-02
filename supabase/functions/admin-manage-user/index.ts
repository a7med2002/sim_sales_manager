// Admin-only user management: create, disable/enable, or change the role
// of a seller account. Runs with the service role key so it can call the
// Supabase Auth admin API — that key must never reach the Flutter client,
// which is why this exists as an Edge Function instead of a direct table
// write. See design/APP_CONTEXT.md "Multi-Tenant & Admin Architecture".
//
// Every request must carry the calling user's own JWT (the client's normal
// session token) in the Authorization header; the function verifies that
// user's `profiles.role = 'admin'` before doing anything else.

import { createClient } from "jsr:@supabase/supabase-js@2";

type Action = "create" | "set_active" | "set_role";

interface RequestBody {
  action: Action;
  // create
  email?: string;
  password?: string;
  display_name?: string;
  // set_active / set_role — target an existing user
  user_id?: string;
  is_active?: boolean;
  role?: "seller" | "admin";
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing Authorization header" }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Client scoped to the caller's own JWT — used only to verify identity
  // and admin role, never to perform the privileged action itself.
  const callerClient = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user: caller }, error: callerError } = await callerClient.auth.getUser();
  if (callerError || !caller) {
    return new Response(JSON.stringify({ error: "Invalid session" }), { status: 401 });
  }

  const { data: callerProfile, error: profileError } = await callerClient
    .from("profiles")
    .select("role, is_active")
    .eq("id", caller.id)
    .single();

  if (profileError || callerProfile?.role !== "admin" || !callerProfile.is_active) {
    return new Response(JSON.stringify({ error: "Admin role required" }), { status: 403 });
  }

  // Only past this point do we touch the service role — the caller is a
  // confirmed, active admin.
  const adminClient = createClient(supabaseUrl, serviceRoleKey);
  const body = (await req.json()) as RequestBody;

  try {
    switch (body.action) {
      case "create": {
        if (!body.email || !body.password) {
          return new Response(JSON.stringify({ error: "email and password are required" }), { status: 400 });
        }
        const { data, error } = await adminClient.auth.admin.createUser({
          email: body.email,
          password: body.password,
          email_confirm: true,
          user_metadata: { display_name: body.display_name ?? null },
        });
        if (error) throw error;
        return new Response(JSON.stringify({ user_id: data.user?.id }), { status: 200 });
      }

      case "set_active": {
        if (!body.user_id || body.is_active === undefined) {
          return new Response(JSON.stringify({ error: "user_id and is_active are required" }), { status: 400 });
        }
        // Disabling sign-in (ban) and flipping the app-level flag together —
        // profiles.is_active alone would still let an existing session work.
        const { error: banError } = await adminClient.auth.admin.updateUserById(body.user_id, {
          ban_duration: body.is_active ? "none" : "876000h",
        });
        if (banError) throw banError;
        const { error: profileUpdateError } = await adminClient
          .from("profiles")
          .update({ is_active: body.is_active })
          .eq("id", body.user_id);
        if (profileUpdateError) throw profileUpdateError;
        return new Response(JSON.stringify({ ok: true }), { status: 200 });
      }

      case "set_role": {
        if (!body.user_id || !body.role) {
          return new Response(JSON.stringify({ error: "user_id and role are required" }), { status: 400 });
        }
        const { error } = await adminClient.from("profiles").update({ role: body.role }).eq("id", body.user_id);
        if (error) throw error;
        return new Response(JSON.stringify({ ok: true }), { status: 200 });
      }

      default:
        return new Response(JSON.stringify({ error: "Unknown action" }), { status: 400 });
    }
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 });
  }
});
