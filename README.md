# Gkhtmltopdf

Gkhtmltopdf is mean Gecko HTML to PDF converter.

Developed as an alternative to wkhtmltopdf.
This gem converts HTML to PDF using Firefox's Geckodriver.

---

## How to

### 1. Install

1. [Firefox](https://www.firefox.com)
    - for Ubuntu
        ```Ubuntu
        $ apt install -y firefox
        ```
    - for Debian
        ```bash
        $ apt install -y firefox-esr
        ```
2. [geckodriver](https://github.com/mozilla/geckodriver)
    - for Linux(Ubuntu / Debian)
        ```bash
        $ wget "https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-linux64.tar.gz" -O /tmp/geckodriver.tar.gz
        $ tar -xzf /tmp/geckodriver.tar.gz -C /usr/local/bin
        ```
3. gem install
	- bundler
        ```bash
        $ bundle add gkhtmltopdf
        ```
    - other
        ```bash
        $ gem install gkhtmltopdf
        ```

---

### 2. Using

#### ruby

> **⚠️ Security Warning for Web Frameworks (e.g., Ruby on Rails):**
> If you are accepting URLs from untrusted users, you must implement strict SSRF protection. Do not pass user-input URLs directly without network-level isolation. Please read the [SSRF](#what-is-ssrf) section below for details.

```ruby
require 'gkhtmltopdf'
# over network
Gkhtmltopdf.convert('https://example.com', 'example_com.pdf')
# local file
Gkhtmltopdf.convert('file:///foo/bar/test.html', 'local.pdf')
# with option (print background)
Gkhtmltopdf.convert('https://f6a.net/oss/', 'with_bg.pdf', print_options: {background: true})
```

#### shell

```bash
# over network
$ gkhtmltopdf https://example.com/ example_com.pdf
# local file
$ gkhtmltopdf /foo/bar/test.html local.pdf
# with option (print background)
$ gkhtmltopdf https://f6a.net/oss/ with_bg.pdf --background
# other option
$ gkhtmltopdf --help
```

---

## FAQ

### Why generated blank (white-color) PDF?

Due to the W3C WebDriver specification, Geckodriver does not throw an error if the target URL returns an HTTP error status (such as `404 Not Found` or `500 Internal Server Error`). If the browser successfully renders an error page, that error page will simply be converted into a PDF.
If you need to verify the status of a URL or branch your logic based on HTTP status codes, please perform a pre-flight check using an HTTP client (e.g., `Net::HTTP` or `Faraday`) before passing the URL to this gem.

### What is SSRF?

SSRF is Server-Side Request Forgery.

This gem passes the provided URL directly to Headless Firefox.  
If you integrate this gem into a web service that accepts arbitrary URLs from untrusted users, it may be vulnerable to SSRF and DNS Rebinding attacks.  
Attackers could potentially generate PDFs of internal network resources (e.g., `localhost`, `192.168.0.1`, `169.254.169.254` for cloud metadata).

**Recommendation:** Do not rely solely on application-level URL validation. If you process untrusted URLs, strongly consider using network-level isolation (such as Docker container networking restrictions, iptables, or an egress proxy) to block access to private/internal IP ranges.

---

## Acknowledgments & Third-Party Licenses

This gem acts as a wrapper and communicates with the following external open-source tools.

We are deeply grateful to their developers:

* Firefox: Licensed under the [MPL-2.0](https://www.mozilla.org/en-US/MPL/2.0/).
* Geckodriver: Licensed under the [MPL-2.0](https://github.com/mozilla/geckodriver/blob/master/LICENSE).

_Note: Gkhtmltopdf does not bundle these binaries. When you install and use Firefox and Geckodriver in your environment, please refer to their respective licenses._

---

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
