// This is a basic VCL configuration file for Drupal.  See the vcl(7)
// man page for details on VCL syntax and semantics.

// Backend definitions.  List your web servers here.
backend web01 {
  .host = "127.0.0.1";
  .port = "80";
  .probe = { .url = "/server-status"; .interval = 5s; .timeout = 1s; .window = 5;.threshold = 3; }
  .first_byte_timeout = 60s;
}

// Define the director that determines how to distribute incoming requests.
director default_director round-robin {
  { .backend = web01; }
}

sub vcl_fetch {
  // include backend name in HTTP header
  set beresp.http.X-Backend = beresp.backend.name;

  // Grace period.
  set beresp.grace = 2m;

  // Override backend's cache-control header, and enforce a minimum ttl for anonymous requests.
  if (req.http.Cookie + "" == "" && beresp.ttl < 2m) {
    set beresp.ttl = 2m;
  }
}

sub vcl_recv {

  set req.backend = default_director;

  // Block server-status
  if (req.url ~ ".*/server-status$") {
    return (error);
  }

  // Remove cookies if this isn't an authenticated session.
  if (req.http.Cookie !~ "SESS[0-9a-f]{32}") {
    unset req.http.Cookie;
  }

  // Remove cookies if this is a static file resource
  if (req.url ~ "^/(sites|modules|misc|profiles|themes)/") {
    unset req.http.Cookie;
  }

  if (req.http.Authorization || req.http.Cookie) {
    /* Not cacheable by default */
    return (pass);
  }

  // Skip the Varnish cache for install, update, and cron
  if (req.url ~ "install\.php|update\.php|cron\.php") {
    return (pass);
  }

  // Normalize the Accept-Encoding header
  // as per: http://varnish-cache.org/wiki/FAQ/Compression
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
      # No point in compressing these
      remove req.http.Accept-Encoding;
    }
    elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    }
    else {
      # Unknown or deflate algorithm
      remove req.http.Accept-Encoding;
    }
  }

  // Grace period.
  set req.grace = 2m;

  return (lookup);
}