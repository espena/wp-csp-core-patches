# wp-csp-core-patches for WordPress v. 5.5.1

WordPress' core templates contain some inline styling and scripting elements
that must be dealt with in order to implement a proper
[Content Security Policy](https://en.wikipedia.org/wiki/Content_Security_Policy)
(CSP).

By applying these patches, a nonce attribute is added to inline `<script>`
and `<style>` tags in the relevant source files. The attribute value is a
secret placeholder value that the web server will replace with a random nonce
that changes with each request. The nonce proves that inline scripts and styles
originates from the web application itself, so that it will not be blocked when
the client enforces the Content Security Policy. See
[espenandersen.no/fixing-content-security-in-wordpress/](https://espenandersen.no/fixing-content-security-in-wordpress/)
for more about this.

## How to install the patches

**Before you start, make a backup copy of your WordPress directory!**

1. Clone the Git repository and cd into the base directory:
   ```
   #> git clone https://github.com/espena/wp-csp-core-patches.git
   #> cd wp-csp-core-patches
   ```
2. Run `make` to build the patches and write the output files to `wp-csp-patch`.
   This will also generate the secret nonce placeholder that will be
   known to you only:
   ```
   #> make
   ```
3. Move `wp-csp-patch` to WordPress' root directory:
   ```
   #> mv wp-csp-patch /path/to/wordpress/root/.
   ```
4. From WordPress' root directory, run the `apply.sh` script:
   ```
   #> cd /path/to/wordpress/root/
   #> wp-csp-patch/apply.sh
   ```
5. Update Nginx. Insert the generated nonce placeholder into the site
   configuration file. See your secret nonce placeholder value along with
   suggested configuration parameters in `wp-csp-patch/nginx_site_config.txt`.

6. Restart Nginx.
---
**NOTE**

I know! *Don't Hack Wordpress' Core* -- although that's exactly what these
patches do. There are a couple of reasons why. First and foremost, the patches
do not change anything substantial in the code. It merely appends an extra,
static attribute to inline `<script>` and `<style>` tags. Updating or
reinstalling WordPress will revert the patches, which is fine. Then you will
have to run the `apply.sh` script again, or bail out and allow `unsafe-inline`
in your CSP header. The patch files can be easily inspected to check what
modifications are made. That is good from a security perspective. Besides,
this is a temporary fix, as I expect inline scripts and styles to be removed
from WordPress in its entirety within a few iterations.

---

## Nginx setup

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

## License and disclaimer

wp-csp-core-patches is written by Espen Andersen, and released under the
[GNU General Public License v. 2.0](https://github.com/espena/wp-csp-core-patches/blob/main/LICENSE).

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

Although the author has attempted to find and correct any bugs in the free
software programs, the author is not responsible for any damage or losses of
any kind caused by the use or misuse of the programs. The author is under no
obligation to provide support, service, corrections, or upgrades
to the free software programs.
