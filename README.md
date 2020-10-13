# wp-csp-core-patches

WordPress' core templates contain some inline styling and scripting elements
that must be dealt with in order to implement a proper
[Content Security Policy](https://en.wikipedia.org/wiki/Content_Security_Policy)
(CSP) in your site's server headers.

By applying these patches, a nonce attribute is added to inline `<script>`
and `<style>` tags in the relevant source files. The attribute value is a
secret placeholder value that the web server will replace with a random nonce
that changes with each request. The nonce proves that inline scripts and styles
originates from the web application itself, so that it will not be blocked when
the client enforces the Content Security Policy.

## How to install the patches

1. Clone the Git repository and cd into the base directory:
   ```
   #> git clone https://github.com/espena/wp-csp-core-patches.git
   #> cd wp-csp-core-patches
   ```
2. Run *make* to create the output directory and build the patch files:
   ```
   #> make
   ```
3. Move `wp-csp-patch` to WordPress' root directory:
   ```
   #> mv wp-csp-patch /path/to/wordpress/root/.
   ```
4. From WordPress' root directory, run the *apply* script:
   ```
   #> cd /path/to/wordpress/root/
   #> wp-csp-patch/apply.sh
   ```
5. Update Nginx. Insert the correct nonce placeholder into the site
   configuration file. See suggested configuration parameters in
   `wp-csp-patch/nginx.site.conf`.
6. Restart Nginx.
---
**NOTE**

I know. *Don't Hack Wordpress' Core* -- although that's exactly what these
patches does. There's a couple of reasons why. First and foremost, the patches
do not change anything substantial in the code. It merely appends an extra,
static attribute to inline `<script>` and `<style>` tags. An update or reinstall
of WordPress will revert the patches, which is fine. Then you will have
to run the apply script again, or bail out and allow `unsafe-inline` in your
CSP header. The patch file format leaves for anyone to easily inspect the
modifications. That is good from a security perspective. Besides, this is
a temporary fix, as I expect inline scripts and styles to be removed from
WordPress in its entirety within a few iterations.

---

For this to work, Nginx must be configured with two additional modules:
* `ngx_set_misc` for random nonce generation
* `http_sub_module` for search and replace functionality

Please refer to Scott Helme's excellent description on how to implement
[CSP Nonce support in Nginx](https://scotthelme.co.uk/csp-nonce-support-in-nginx/)
for details about compiling Nginx with these two modules.

Suggested server settings for your Nginx site configuration can be found in the
generated file `wp-csp-patch/nginx_site.conf`.

Basically, the web server searches for the secret placeholder string and replaces
it with a one-shot nonce value that is referred to by the CSP header. This
confirms to the client that the inline `<script>` or `<style>` tags in question
are legitimate and not from someone attempting an injection attack.
