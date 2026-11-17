
# Lab 1: Secure Computing

**Author:** Calvin Koch

**Date:** [Insert Date]

---

## Task 1: SQL Injections

### 1.1 Basic SQL Injection (Exercise 1)

* **Target Field:** Login (Email Field)
* **Injection Payload:** `admin@juice-sh.op' OR 1=1 --`
* **Resulting Output:** The application successfully authenticated the session as the administrator, completely bypassing the password verification step.
* **Technical Explanation:**
* **What is SQLi:** SQL Injection (SQLi) is a vulnerability where an application improperly sanitizes user input before passing it to the backend database parser. Instead of treating the input strictly as a literal string (data), the database engine interprets the input as executable SQL commands, altering the logical structure of the query.
* **Backend Query Mechanics:** The injection operates by manipulating the `WHERE` clause of the authentication query. The initial single quote (`'`) prematurely terminates the string literal intended for the email parameter. The injected boolean tautology (`OR 1=1`) forces the conditional check to evaluate to `TRUE` regardless of the email address provided. Finally, the SQL comment characters (`--`) instruct the database engine to ignore the remainder of the query, successfully truncating the `AND password = '...'` verification logic.

### 1.2 Authentication Bypass (Exercise 2)

* **Target User:** `admin@juice-sh.op` (or any valid user via brute force)
* **Injection Payload:** `' OR 1=1 AND email LIKE ('%admin%'); --`
* **Result:** Successfully logged in as the targeted user without supplying a valid cryptographic credential.
* **Technical Explanation:**
  Building upon the basic injection, this payload targets a specific user by injecting a `LIKE` operator. The backend query structure is forced into the following logic: `SELECT * FROM users WHERE email = '' OR 1=1 AND email LIKE ('%admin%'); --' AND password = '...';`. Because the comment syntax truncates the password check, the database evaluates the condition, finds the first record matching the wildcard string `%admin%`, and returns the user object. The application middleware interprets the presence of the returned user object as a successful authentication event.

### 1.3 Prevention Strategies (Exercise 3)

* **Administrator Actions:** To categorically prevent SQL injections, system administrators and developers must abandon string concatenation for database queries. The primary defense mechanism is the implementation of **Parameterized Queries** (Prepared Statements). By utilizing prepared statements, the database driver ensures that the structure of the SQL query is compiled prior to the insertion of user input. The input is strictly cast as a scalar value rather than executable syntax, rendering payloads like `' OR 1=1` inert. Secondary defenses include strict input validation (allow-listing) and the use of modern Object-Relational Mapping (ORM) frameworks.

### 1.4 "Little Bobby Tables" Comic Analysis (Exercise 4)

* **Incident Breakdown:** The comic illustrates a classic First-Order SQL Injection. The mother inputs her son's name as `Robert'); DROP TABLE Students;--`. When the school's vulnerable backend concatenates this into an `INSERT` statement, the `');` terminates the intended SQL command. The subsequent `DROP TABLE Students;` is executed as a secondary, independent command, instructing the database to permanently delete the entire `Students` table. The `--` ensures any trailing syntax from the original query is commented out to prevent execution errors.
* **Remediation for the School:** The school's database architecture failed to implement parameterized queries and clearly operated with excessive privileges (the web application's database user possessed the DDL permissions required to `DROP` a table). To remediate this, the school must restore the table from a backup, implement prepared statements for all database operations, and enforce the Principle of Least Privilege (PoLP) by restricting the application's database account to `SELECT`, `INSERT`, and `UPDATE` commands only.

### 1.5 Hash Extraction & Cracking [Higher Grades] (Exercise 6)

* **Extracted Data:**
* *[User 1]*: `[Insert Hash from Juice Shop]` -> `[Insert Cleartext Password]`
* *[User 2]*: `[Insert Hash from Juice Shop]` -> `[Insert Cleartext Password]`
* **Hashing Algorithm Identified:** [Insert Algorithm, e.g., MD5]
* **Security Improvements:**

1. **Salting:** Appending a cryptographically secure, unique random string (salt) to each password prior to hashing neutralizes pre-computed Rainbow Table attacks and ensures identical passwords yield different hashes.
2. **Key Stretching:** Replacing fast, legacy cryptographic hash functions (like MD5 or SHA-1) with computationally expensive memory-hard algorithms (such as Argon2, bcrypt, or scrypt) severely mitigates the efficiency of brute-force and GPU-accelerated dictionary attacks.

### 1.6 Automated Exploitation with sqlmap [Higher Grades] (Exercises 7–9)

* **Tool Overview:** `sqlmap` is an automated penetration testing tool that dynamically maps and exploits SQL injection flaws. It systematically injects payloads to infer the backend database architecture based on HTTP responses (time delays, boolean differences, or explicit error messages).
* **Attack Mechanics:** [Fill in how you ran sqlmap against the Juice Shop endpoint]
* **Parameter Breakdown:**
* `--ignore-code 401`: Instructs `sqlmap` to bypass HTTP 401 Unauthorized status codes, forcing the tool to continue testing endpoints that seemingly require authentication.
* `--technique=U`: Restricts the exploitation methodology strictly to `UNION`-query based SQL injections, which extracts data by appending it to the legitimate application output.
* `--dbms=sqlite`: Optimizes the attack by specifying the target backend database management system (SQLite), preventing `sqlmap` from wasting time sending payloads tailored for MySQL, PostgreSQL, etc.
* `--dump`: Instructs the tool to exfiltrate and download the entire contents of the discovered database tables.

---

## Task 2: XSS/CSRF

### 2.1 Cross-Site Scripting (Exercises 1–3)

* **Attack Type:** Stored / Reflected XSS
* **Step-by-Step Replication:**

1. Navigate to the [Insert Vulnerable Juice Shop Field, e.g., Search or Customer Feedback].
2. Inject the following crafted `iframe` payload utilizing the `srcdoc` attribute:

```html
<iframe srcdoc="
    <h1>XSS Injection Attack</h1>
    <script>
        let email = localStorage.getItem('email');
        console.log('Exfiltrated User email:', email);
        document.write('<p>Stolen Email: ' + email + '</p>');
    </script>
"></iframe>

```

* **Mechanism of Action:** The application fails to properly sanitize or encode HTML entities in user input before rendering it in the DOM. When the victim loads the page, the browser interprets the `srcdoc` attribute as legitimate HTML and executes the embedded JavaScript. This script bypasses standard visual detection, queries the browser's `localStorage` API, and extracts the user's session data. In a weaponized scenario, this script would utilize the `fetch()` API to silently exfiltrate the `localStorage` data to an attacker-controlled server.

### 2.2 XSS vs. CSRF Conceptual Differences (Exercises 4–5)

* **Trust vs. Deception:** The conceptual difference between XSS and CSRF lies in the vector of trust being exploited [@owasp_csrf].
* **XSS (Cross-Site Scripting)** exploits the *user's trust in the website*. The user visits a legitimate site, trusting its code. However, the site has been deceived into serving malicious JavaScript. The user's browser executes this script because it assumes the trusted origin provided it [@owasp_xss].
* **CSRF (Cross-Site Request Forgery)** exploits the *website's trust in the user's browser*. The website receives a state-changing command (e.g., an email update) and observes a valid, authenticated session cookie attached. The website trusts the request and executes it, unaware that a completely separate, malicious origin silently forced the user's browser to send the HTTP request.

### 2.3 Protection Ramifications & Mitigation [Higher Grades] (Exercise 6)

* **Scenario A (XSS protected, CSRF vulnerable):** An attacker cannot inject JavaScript, but they can host a malicious webpage that silently submits a `POST` request to the application's `/change-password` endpoint. If a victim visits the attacker's page while logged into the vulnerable application, the victim's password will be changed without their consent.
* **Scenario B (CSRF protected, XSS vulnerable):** The application requires an unpredictable Anti-CSRF token for all state-changing requests. However, because XSS is possible, an attacker injects JavaScript that simply reads the valid Anti-CSRF token from the DOM, attaches it to an asynchronous `fetch()` request, and submits the forged action directly from the victim's own browser, entirely bypassing the CSRF defense.
* **Combined Protection Scheme:** A robust defense requires multiple layers. To mitigate CSRF, the application must implement **Synchronizer Token Patterns** (Anti-CSRF tokens) alongside the `SameSite=Strict` attribute on session cookies. To mitigate XSS, developers must utilize context-aware output encoding (to neutralize HTML entities) and implement a strict **Content Security Policy (CSP)** that restricts the execution of inline scripts and untrusted external domains.

---

## Task 3: Authentication

### 3.1 XKCD Password Generator (Exercises 1–10)

* **Source Code:**

```python
import math
import secrets
import sys

def generate_password(num_words):
    wordlist_path = '/usr/share/dict/words'
    with open(wordlist_path, 'r') as file:
        words = [w.strip().lower() for w in file if w.strip().isalpha()]

    wordlist_size = len(words)
    password_words = [secrets.choice(words) for _ in range(num_words)]

    entropy = num_words * math.log2(wordlist_size)
    equiv_chars = entropy / math.log2(62)

    print(f"\n{' '.join(password_words)}")
    print(f"{num_words} RANDOM words from word list of {wordlist_size} words")
    print(f"Entropy: {entropy:.2f} bits")
    print(f"You need {equiv_chars:.2f} RANDOM characters in [a-zA-Z0-9] to get the same entropy.\n")

if __name__ == "__main__":
    num = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    generate_password(num)

```

* **Example Output:**

```text
redemise underking combmaker embark
4 RANDOM words from word list of 234936 words
Entropy: 71.37 bits
You need 11.99 RANDOM characters in [a-zA-Z0-9] to get the same entropy.

```

* **Explanation:** The script calculates the theoretical entropy based on Shannon's mathematical theory of communication [@shannon1948]. Entropy ($E$) is derived by calculating the base-2 logarithm of the total possible combinations: $E = L \times \log_2(N)$, where $L$ is the number of words chosen and $N$ is the total size of the filtered dictionary.

### 3.2 Shoulder Surfing Entropy (Exercises 11–13)

* **Assumptions:** To calculate the remaining entropy, we must define the input alphabet. Assuming the user is restricted to a standard alphanumeric policy `[a-zA-Z0-9]`, the keyboard offers 36 unshifted choices (26 lowercase + 10 digits). Pressing "Shift" restricts the pool to 26 uppercase letters (as shifted digits yield symbols, which are excluded in this assumption).
* **Calculations:**

1. The attacker observes 10 keystrokes, 3 of which are shifted.
2. The number of positional combinations for the 3 uppercase letters is calculated via the binomial coefficient: $\binom{10}{3} = 120$.
3. The total number of valid password combinations is: $120 \times (26)^3 \times (36)^7$.
4. Calculating the base-2 logarithm yields the remaining entropy:

$$
E = \log_2(120 \times 26^3 \times 36^7) \approx 6.9 + 14.1 + 36.1 = 57.1 \text{ bits}
$$

### 3.3 S/MIME Secure Email (Exercises 14–18)

* **Certificate Details:**
* **Issuer:** [Insert Issuer from your Thunderbird settings]
* **Validity Period:** [Insert Dates]
* **Encryption vs. Signing Order:** S/MIME utilizes asymmetric cryptography. To send an encrypted email, the sender must possess the recipient's public key. Sending a cryptographically signed email first allows the recipient's email client to extract the sender's public key from the digital signature's payload. Once exchanged via signatures, both parties possess the necessary public keys to initiate encrypted communication.
* **Mail Client vs. Webmail:** Browser-based webmail fundamentally compromises the end-to-end security architecture of S/MIME. Webmail requires the user's private key to be uploaded and stored on the provider's remote server, meaning the provider (or an attacker compromising the server) can decrypt the communications. A local mail client (like Thunderbird) ensures the private cryptographic key never leaves the local machine's secure storage.

### 3.4 Password Policy Analysis [Higher Grades] (Exercises 19–24)

* **Information Theory Minimum Length:** The Uppsala University policy permits a 93-character alphabet. According to Shannon entropy [@shannon1948], the entropy per character is $\log_2(93) \approx 6.539$ bits. To reach the minimum threshold of 27 bits of entropy, the theoretical minimum length ($L$) is calculated as $27 / 6.539 = 4.12$. Therefore, purely random passwords from this alphabet would mathematically only require a length of 5 symbols.
* **NIST 10-Symbol Discrepancy:** The university policy enforces a 10-symbol minimum because human-chosen passwords do not represent a uniform probability distribution. As detailed on page 107 of NIST SP 800-63-2 [@nist800632], users heavily favor predictable patterns, dictionary words, and localized capitalization (e.g., capitalizing only the first letter). Because the actual entropy per character of a human-chosen password is significantly lower than the theoretical maximum, the length requirement is artificially inflated to 10 symbols to ensure the *effective* entropy exceeds 27 bits.
* **Entropy Comparison (n vs 2n):** For a 62-character alphabet, the entropy of a password of length $n$ is $E_1 = n \times \log_2(62)$. For a password of length $2n$, the entropy is $E_2 = 2n \times \log_2(62)$. Therefore, doubling the length of the password strictly doubles its entropy ($E_2 = 2 \times E_1$).
* **Brute Force Time Estimation:** Assuming a 10-symbol password drawn randomly from a 93-character alphabet, the total combinations are $93^{10} \approx 4.83 \times 10^{19}$. At a rate of 1,000 guesses per second, a brute force attack would require $4.83 \times 10^{16}$ seconds, equating to approximately 1.53 billion years to exhaust the keyspace.

---

### Bibliography File (`refs.bib`)

Save the following text as `refs.bib` in the exact same folder as your markdown file. When you compile with Pandoc using the command we discussed earlier, it will automatically pull these references and format them perfectly into IEEE style at the bottom of your PDF.

```bibtex
@misc{owasp_xss,
  title = {{Cross Site Scripting (XSS)}},
  author = {{OWASP Foundation}},
  howpublished = {\url{https://owasp.org/www-community/attacks/xss/}},
  note = {Accessed: 2026-11-17}
}

@misc{owasp_csrf,
  title = {{Cross-Site Request Forgery (CSRF)}},
  author = {{OWASP Foundation}},
  howpublished = {\url{https://owasp.org/www-community/attacks/csrf}},
  note = {Accessed: 2026-11-17}
}

@article{shannon1948,
  title={A mathematical theory of communication},
  author={Shannon, Claude Elwood},
  journal={The Bell system technical journal},
  volume={27},
  number={3},
  pages={379--423},
  year={1948},
  publisher={Nokia Bell Labs},
  howpublished={\url{https://people.math.harvard.edu/~ctm/home/text/others/shannon/entropy/entropy.pdf}}
}

@techreport{nist800632,
  title={{NIST Special Publication 800-63-2: Electronic Authentication Guideline}},
  author={Burr, William E. and Dodson, Donna F. and Newton, Elaine M. and Perlner, Ray A. and Polk, W. Timothy and Gupta, Sarbari and Nabbus, Emad A.},
  year={2013},
  pages={107},
  institution={National Institute of Standards and Technology},
  howpublished={\url{https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-63-2.pdf}}
}

@article{saltzer1975protection,
  title={The protection of information in computer systems},
  author={Saltzer, Jerome H and Schroeder, Michael D},
  journal={Proceedings of the IEEE},
  volume={63},
  number={9},
  pages={1278--1308},
  year={1975},
  publisher={IEEE},
  howpublished={\url{https://web.mit.edu/Saltzer/www/publications/protection/Basic.html}}
}

```
