// Kodeord-spærre for vsdk.vaeresteder.dk
// Kører automatisk foran ALLE sider på sitet (Cloudflare Pages Functions).
//
// Kræver to miljøvariabler sat i Cloudflare Pages -> Settings -> Environment variables:
//   PASSWORD     = det fælles kodeord I vil bruge
//   AUTH_SECRET  = en lang, tilfældig streng (bruges til at signere login-cookien)
//
// Sæt dem gerne som "Secret" (krypteret), ikke almindelig tekst-variabel.

const COOKIE_NAME = "vsdk_auth";
const MAX_AGE_SECONDS = 60 * 60 * 24 * 30; // 30 dage

async function sign(secret, message) {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(message));
  return btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function getCookie(request, name) {
  const header = request.headers.get("Cookie") || "";
  const match = header.match(new RegExp("(?:^|; )" + name + "=([^;]*)"));
  return match ? decodeURIComponent(match[1]) : null;
}

function loginPage(errorMsg) {
  return `<!DOCTYPE html>
<html lang="da">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Log ind — Væresteder i Danmark</title>
<style>
  body{
    margin:0; min-height:100vh; display:flex; align-items:center; justify-content:center;
    font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
    background:#F3F6F5; color:#16323A;
  }
  .box{
    background:#fff; border:1px solid #D7E0DE; border-radius:12px;
    padding:32px 30px; width:100%; max-width:340px; box-shadow:0 6px 24px rgba(22,50,58,0.08);
  }
  h1{font-size:18px; margin:0 0 6px 0;}
  p.sub{font-size:13px; color:#4A6167; margin:0 0 20px 0;}
  input[type=password]{
    width:100%; padding:10px 12px; border:1px solid #D7E0DE; border-radius:7px;
    font-size:14px; box-sizing:border-box; margin-bottom:12px; outline:none;
  }
  input[type=password]:focus{border-color:#C99A3A;}
  button{
    width:100%; padding:10px; border:none; border-radius:8px;
    background:#16323A; color:#fff; font-weight:600; font-size:14px; cursor:pointer;
  }
  button:hover{background:#0F262C;}
  .err{color:#B33F3F; font-size:13px; margin-bottom:12px;}
</style>
</head>
<body>
  <div class="box">
    <h1>Væresteder i Danmark</h1>
    <p class="sub">Indtast kodeordet for at få adgang.</p>
    ${errorMsg ? `<div class="err">${errorMsg}</div>` : ""}
    <form method="POST" action="/_login">
      <input type="password" name="password" placeholder="Kodeord" autofocus required>
      <button type="submit">Log ind</button>
    </form>
  </div>
</body>
</html>`;
}

export async function onRequest(context) {
  const { request, env, next } = context;
  const url = new URL(request.url);

  if (!env.PASSWORD || !env.AUTH_SECRET) {
    return new Response(
      "Siden er ikke sat korrekt op endnu: PASSWORD og AUTH_SECRET mangler som miljøvariabler i Cloudflare Pages.",
      { status: 500 }
    );
  }

  // Login-endpoint
  if (url.pathname === "/_login" && request.method === "POST") {
    const form = await request.formData();
    const pw = (form.get("password") || "").toString();

    if (pw === env.PASSWORD) {
      const expires = Date.now() + MAX_AGE_SECONDS * 1000;
      const payload = `ok:${expires}`;
      const sig = await sign(env.AUTH_SECRET, payload);
      const token = encodeURIComponent(`${payload}:${sig}`);
      const headers = new Headers();
      headers.set(
        "Set-Cookie",
        `${COOKIE_NAME}=${token}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=${MAX_AGE_SECONDS}`
      );
      headers.set("Location", "/");
      return new Response(null, { status: 302, headers });
    }
    return new Response(loginPage("Forkert kodeord. Prøv igen."), {
      status: 401,
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  }

  // Log ud
  if (url.pathname === "/_logout") {
    const headers = new Headers();
    headers.set("Set-Cookie", `${COOKIE_NAME}=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0`);
    headers.set("Location", "/");
    return new Response(null, { status: 302, headers });
  }

  // Tjek eksisterende login-cookie
  const cookieVal = getCookie(request, COOKIE_NAME);
  let authenticated = false;

  if (cookieVal) {
    const parts = cookieVal.split(":");
    if (parts.length === 3) {
      const [tag, expiresStr, sig] = parts;
      const payload = `${tag}:${expiresStr}`;
      const expectedSig = await sign(env.AUTH_SECRET, payload);
      if (sig === expectedSig && tag === "ok" && Number(expiresStr) > Date.now()) {
        authenticated = true;
      }
    }
  }

  if (!authenticated) {
    return new Response(loginPage(), {
      status: 200,
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  }

  return next();
}
