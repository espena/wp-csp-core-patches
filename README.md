# wp-csp-core-patches

Unfortuantely, WordPress' core templates contain some inline styling and
scripting elements that need to be to be whitelisted in order to implement a
proper [Content Security Policy](https://en.wikipedia.org/wiki/Content_Security_Policy)
(CSP) in your site's server headers.

By appling the patches, a nonce attribute will be added to inline `<script>`
and `<style>` tags within the relevant source files. The attribute value is an
unique secret placeholder value that the web server will replace with a random
nonce that changes with each request.

For this to work, Nginx must be configured with two additional modules:
* `ngx_set_misc` for random nonce generation
* `http_sub_module` for search and replace functionality

Please refer to Scott Helme's excellent description on how to implement
[CSP Nonce support in Nginx](https://scotthelme.co.uk/csp-nonce-support-in-nginx/)
for details about compiling Nginx with these two modules.

Suggested server settings for your Nginx site configuration can be found in the
generated file `wp-csp-patch/nginx_site.conf`.

Basically, the web server searches for the secret placeholder string and replaces
it with a one-shot nonce value that is referred to by the CSP header, thus
confirming to the client that the inline `<script>` or `<style>` tags in question
are legitimate and not from someone attempting an injection attack.
