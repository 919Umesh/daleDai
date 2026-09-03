import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const ONESIGNAL_API_KEY = Deno.env.get("ONESIGNAL_API_KEY") ?? "";
const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID") ?? "";
const TEMPLATE_IDS: Record<string, string> = {
  BOOKING_CONFIRMED: Deno.env.get("ONESIGNAL_TEMPLATE_BOOKING_CONFIRMED") ?? "e5bf5fe2-dbe0-4156-8b6b-dbb23beb7c39"
};

Deno.serve(async (req) => {
  // CORS handling
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, apikey'
      }
    });
  }

  try {
    const payload = await req.json();
    console.log("Received payload:", JSON.stringify(payload, null, 2));
    const { email, email_type, booking_data } = payload;

    if (!email || !email_type || !booking_data) {
      return new Response(JSON.stringify({
        error: "Missing required fields: email, email_type, booking_data"
      }), {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    if (!TEMPLATE_IDS[email_type]) {
      return new Response(JSON.stringify({
        error: "Invalid email_type"
      }), {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    const body = {
      app_id: ONESIGNAL_APP_ID,
      template_id: TEMPLATE_IDS[email_type],
      email_from_name: "DaleDai",
      email_from_address: "dale@umesh-shahi.com.np",
      email_sender_domain: "mail.umesh-shahi.com.np",
      include_unsubscribed: true,
      disable_email_click_tracking: false,
      name: "Booking Confirmation Email",
      email_to: [
        email
      ],
      custom_data: booking_data
    };

    const res = await fetch("https://api.onesignal.com/notifications?c=email", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Key ${ONESIGNAL_API_KEY}`
      },
      body: JSON.stringify(body)
    });

    const data = await res.json();
    console.log("OneSignal response:", data);

    return new Response(JSON.stringify({
      message: `Email sent for type: ${email_type}`,
      success: true,
      data
    }), {
      headers: {
        "Content-Type": "application/json",
        'Access-Control-Allow-Origin': '*'
      }
    });
  } catch (err: any) {
    console.error("Error sending email:", err);
    return new Response(JSON.stringify({
      error: "Failed to send email",
      details: err.message
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        'Access-Control-Allow-Origin': '*'
      }
    });
  }
});
