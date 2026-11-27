# Lab 1 Seminar Notes

## Task 1 — SQL injection

### Core idea

SQL (Structured Query Language) is used to ask a relational database to select,
insert, update, or delete records. An application commonly builds a query from
fixed SQL syntax and values supplied by the user. SQL injection (SQLi) happens
when the application combines those parts as text in a way that lets a value
change the query's structure.

For example, the intended login logic is conceptually:

```sql
SELECT user_id
FROM users
WHERE email = ? AND password_hash = ?;
```

The question marks represent bound parameters. The database receives the
query structure separately from the email and password values, so punctuation
inside a value remains data rather than becoming SQL syntax.

An unsafe design instead concatenates user text into a SQL string. If that
text is interpreted as syntax, it can alter a condition, the rows returned, or
the operation performed. In a login query, changing the `WHERE` condition can
cause an application to treat a database result as a successful login without
the intended credential check.

### Understanding the SQL vocabulary

- `SELECT` chooses columns; `FROM` identifies a table; `WHERE` filters rows.
- `AND` and `OR` combine Boolean conditions. Parentheses make intended
  precedence explicit.
- `=` compares values. `LIKE` compares text using pattern matching; `%`
  represents any sequence of characters in that pattern.
- A quoted string is a **literal**. SQL comment syntax tells the SQL parser
  which text to ignore, but its exact rules depend on the database.
- A **query parameter** is a value bound separately from the SQL statement.
  It is not the same thing as manually escaping characters or filtering input.

### Prevention and the comic

1. Use prepared statements / parameterized queries for every user-controlled
   value. This is the primary defense because it keeps SQL structure and data
   separate.
2. Validate input against the application's expected format as an additional
   check. Validation is not a substitute for parameterization.
3. Give the application's database account only the permissions it needs.
   For example, an account that inserts a student record should not also be
   able to remove tables.
4. Handle errors without exposing database internals, and log security
   relevant failures appropriately.

In the “Little Bobby Tables” comic, the school treats a name as SQL syntax
instead of as a value. The intended insert is disrupted, and a destructive
database operation is presented as part of the command. The underlying causes
are unsafe query construction and excessive database privileges. Prepared
statements prevent the name from changing the command; least privilege limits
the damage if another defect remains. Backups help recovery but do not prevent
the flaw.

### **Higher grades — hashes and sqlmap**

A password hash is a one-way derived value, not encryption: it is not normally
reversed with a decryption key. An attacker who obtains hashes can compare
candidate passwords by hashing them, which is why weak or fast password
hashing is dangerous. A modern password-storage design uses a unique random
**salt** per password and a deliberately expensive password-hashing function
such as Argon2id, scrypt, or bcrypt. A salt prevents identical passwords from
having identical stored results and defeats shared precomputed tables; a slow
KDF makes each guess more costly. A salt is not a secret.

MD5 is a fast general-purpose hash, not a suitable password-storage function.
A 32-character hexadecimal value may be consistent with an MD5 digest, but
its appearance alone does not prove which algorithm produced it. Treat
automated identification and recovered-password results as evidence to assess,
not as certainty about every record.

`sqlmap` automates testing for SQL injection by varying a request parameter
and comparing application responses. In an authorized lab, it can help
identify database behavior and demonstrate the impact of a flaw. It does not
magically know the original query: it infers useful behavior from the requests
and responses it can observe.

The options named in the lab prompt mean:

- `--ignore-code 401`: do not stop solely because responses have HTTP status
  401. It does not authenticate the user or bypass access control by itself.
- `--technique=U`: limit tests to the UNION-query technique.
- `--dbms=sqlite`: tell the tool which database family to assume/use when
  selecting tests.
- `--dump`: request retrieval of selected database records. Use only against
  an explicitly authorized test system.

In the higher-grade report, `--ignore-code 401` was not used in the documented
run; do not describe it as part of that run. The report describes a local
Juice Shop search request, database discovery, and a password-column retrieval
that needed a type-conversion workaround. The report should clearly separate
the tool's observed output from general explanations of what each option can
do.

## Task 2 — XSS and CSRF

### Cross-site scripting (XSS)

XSS occurs when an application causes untrusted content to be interpreted as
active page content in a visitor's browser. The browser associates the page
with the application's origin, so injected script can act with the
permissions available to that origin. Depending on the application, impact
can include reading page data or triggering actions as the current user.

The report's Juice Shop demonstration showed that content entered through a
page field could be interpreted by the browser and access data available to
that page. Explain the trust boundary and consequence without sharing real
account data or a reusable payload.

Classify the issue by where the content comes from:

- **Stored XSS:** untrusted content is saved and later served to visitors.
- **Reflected XSS:** content from a request is included in the immediate
  response.
- **DOM-based XSS:** client-side code puts untrusted data into a dangerous
  DOM/API context.

The field used in a test does not by itself determine the category; identify
whether the content is stored, reflected, or handled in the browser.

**Defenses:** encode output for the exact HTML, attribute, URL, or JavaScript
context; use safe DOM APIs that treat values as text; avoid inserting
untrusted strings as markup; and apply a restrictive Content Security Policy
(CSP) as defense in depth. Input filtering alone is fragile because the
meaning of a character depends on its output context. `HttpOnly` cookies can
make session cookies unavailable to ordinary JavaScript, but do not prevent
XSS or protect other page data.

### Cross-site request forgery (CSRF)

CSRF tricks a browser into sending an unwanted request to a site where the
person is already authenticated. The site may trust the attached session
cookie and mistake the request for an intentional user action.

The difference is the trust relationship:

| Topic                                       | XSS                                               | CSRF                                                 |
| ------------------------------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| What is abused?                             | The user's trust in content served by a site      | The site's trust in the user's authenticated browser |
| Where does attacker-controlled content run? | In the target site's page/origin                  | It need not run inside the target site               |
| Typical consequence                         | Script can act with the page's origin permissions | A forged state-changing request may be accepted      |

Protect state-changing actions with server-validated anti-CSRF tokens and
appropriate `SameSite` cookie settings. Check the `Origin` or `Referer` where
appropriate, and require re-authentication for especially sensitive actions.
These controls do not replace XSS defenses: script running inside the trusted
origin may be able to make requests as that page. Conversely, XSS defenses do
not automatically prevent CSRF. Protect against both classes independently.

## Task 3 — Authentication and passwords

### What entropy means

In information theory, **entropy measures uncertainty** about the outcome of
a random process. For passwords, it describes how many plausible choices an
attacker would need to distinguish if they know how the password was
generated. Entropy is measured in **bits**: one bit corresponds to a choice
between two equally likely possibilities. More bits mean more uncertainty and,
under the same guessing conditions, a larger search space.

If there are `N` equally likely possible outcomes, the uncertainty is
`log2(N)` bits. If outcomes have different probabilities, the more general
Shannon entropy is `-sum(p * log2(p))`, where `p` is the probability of each
outcome. Password formulas below use the simpler uniform-choice model. A
password's length or character set alone does not determine its real entropy:
the process that selected it matters. For example, a uniformly random
character and a character chosen by a person's habit are not equally
unpredictable.

### XKCD-style password generator

The generator in [`xkcd_pass.py`](xkcd_pass.py) reads a system word list,
filters it to alphabetic entries, chooses words with Python's `secrets`
module, then reports estimated entropy and a character-count comparison.
The core calculations are:

```python
entropy_bits = number_of_words * math.log2(wordlist_size)
equivalent_characters = entropy_bits / math.log2(62)
```

In words, `log2(wordlist_size)` is the uncertainty in one uniform choice from
the list. Multiplying it by the number of independently selected words gives
the total uncertainty in the whole phrase. Dividing by `log2(62)` converts
that total into the number of uniformly random 62-character-alphabet
characters with the same theoretical uncertainty.

The formula assumes each word is chosen uniformly and independently from `N`
possible entries. A single choice has `log2(N)` bits of entropy; `k` choices
therefore have `k * log2(N)` bits. For random characters drawn uniformly from
an alphabet of size 62, each character contributes `log2(62)` bits.

This is theoretical entropy. It is not a guarantee about a human-created
phrase, and the result depends on the actual word list and its selection
method. The program lowercases words; if distinct list entries become the
same word after filtering, the number of distinct outputs can be smaller than
the number of entries. Re-running on another system can also produce a
different list size and different words.

### Shoulder-surfing calculation

Assumptions used in the report:

- There are 10 character positions.
- Exactly 3 positions used Shift, but the observer does not know which 3.
- An unshifted position has 36 possible characters (lowercase letters or
  digits); a shifted position has 26 uppercase-letter possibilities.
- Choices are treated as uniform and independent within those groups.

The number of possible passwords consistent with those observations is:

```text
C(10, 3) * 26^3 * 36^7
```

In words, `C(10, 3)` counts where the three shifted characters could be among
the ten positions. For each such arrangement, `26^3` counts the possible
uppercase letters in those positions, and `36^7` counts the possible
lowercase letters or digits in the other positions. Multiplying these counts
gives the total number of passwords that match what the observer knows.
Entropy is the base-2 logarithm of that total:

```text
log2(C(10, 3)) + 3*log2(26) + 7*log2(36) = approx. 57.2 bits
```

The logarithm expresses that count as the number of binary-choice bits needed
to represent the same amount of uncertainty.

If the observer also knew the exact positions of Shift presses, the
`C(10, 3)` factor would not be included, and the uncertainty would be lower.
Real keyboard behavior and non-uniform human choices can also change the
estimate.

### S/MIME signing and encryption

An X.509 certificate binds a public key to an identity according to the
certificate issuer's validation process. It contains public information; the
matching private key must remain protected by its owner.

- **Signing:** the sender's private key creates a signature over the message
  (typically via a message digest). A recipient can check integrity and
  verify the signature using the sender's public key and certificate. A valid
  signature does not mean the message is encrypted.
- **Encryption:** the sender needs the recipient's public key/certificate.
  S/MIME normally uses hybrid encryption: public-key cryptography protects
  message key material, while symmetric cryptography encrypts the message
  contents.
- **Certificate exchange:** a signed email can carry the sender's
  certificate, allowing the recipient to obtain the sender's public key.
  For two people to exchange encrypted messages, each sender needs the other
  person's public key. Check that the certificate is valid and corresponds to
  the intended recipient; merely receiving a key does not establish trust.

A local mail client can keep the private key under local control. Webmail's
security depends on how its keys are handled; it is not accurate to say that
every webmail service necessarily uploads or exposes private keys. The
important question is whether the service or its delivered code can access
plaintext or key material.

For the certificate part of the seminar, report only the issuer and validity
period needed by the assignment. Do not share a private key, certificate
password, or exported `.p12` file.

### **Higher grades — password policy and search space**

For an alphabet of size `A` and a uniformly random password of length `L`:

```text
H = L * log2(A) bits
L_min = ceil(required_bits / log2(A))
```

In words, `log2(A)` is the uncertainty contributed by one random character.
Multiplying by the length counts the uncertainty across all independent
positions. To find the minimum length, divide the required uncertainty by the
bits per character and round up, since a password cannot have a fraction of a
character.

Using the lab policy's stated alphabet of 93 symbols and target of 27 bits:

```text
ceil(27 / log2(93)) = ceil(4.13...) = 5 symbols
```

In words, each uniform choice from 93 symbols contributes `log2(93)` bits.
The calculation divides the target of 27 bits by that per-character amount,
then rounds up to the next whole character. This is a mathematical minimum
under the uniform-random assumption. Human passwords are not uniformly
selected, so a separate minimum length and character-class rules are policy
constraints rather than proof of a user's actual entropy.

For 62 equally likely characters, `H(n) = n * log2(62)` and
`H(2n) = 2 * H(n)`. Doubling length doubles entropy under the same independent,
uniform-choice assumptions. In words, the longer password has twice as many
independently chosen positions, so it has twice the number of per-character
bits.

If all `A^L` candidates are checked at `r` guesses per second, exhaustive
search time is `A^L / r`. Here, `A^L` counts every possible password (each of
the `L` positions has `A` choices), and dividing by the guessing rate `r`
converts the number of guesses into seconds. Expected time to find a uniformly
placed password is approximately half that if guesses do not repeat, because
on average the correct one is found halfway through the search order. This
idealized estimate does not account for guess ordering, rate limits,
password-hashing cost, or whether the attacker can perform online guesses.

## Task 4 — Access control and TOCTTOU

### What the program does

The experiment opens a file, pauses, writes through the already-open Python
file object, and closes it. The shell script changes permissions or removes
the file while the program is paused. The Python program is embedded in
[`tocttou_auto_script.sh`](tocttou_auto_script.sh); the separate interactive
version is [`tocttou.py`](tocttou.py).

Relevant syntax in the Python program:

```python
fd = open(filepath, "w")
input()
fd.write("test data\n")
fd.close()
```

`open(..., "w")` opens for writing and normally truncates an existing file at
open time. `input()` pauses until input is received. `write()` uses the open
file object, which refers to the object opened earlier; it does not look up the
pathname again. The `try`/`except` pattern reports errors rather than silently
ignoring them. In the shell, `chmod u-w` removes the owner's write bit, `rm`
removes a pathname, and `ls -l` displays permission bits and file metadata.

### Interpret the tests carefully

1. **Normal:** opening succeeds and the program writes through the open file.
2. **Remove write permission after open:** on the tested Unix-like system,
   changing the mode bits does not ordinarily revoke write access through an
   already-open descriptor. The later write can still succeed.
3. **No write permission before open:** opening should fail for an ordinary
   unprivileged user, so the program never reaches the write. Ownership,
   privileges, ACLs, and platform rules can affect this result.
4. **Remove the pathname after open:** on Unix-like systems, unlinking the
   name usually removes the directory entry but leaves an open file usable
   until the final reference is closed. A later path-based read cannot find
   the old name. Windows has different handle-sharing and deletion semantics;
   the exact result depends on how the handle was opened and the operating
   system.

**TOCTTOU** means “time of check to time of use”: a decision about a resource
is made, the resource can change, and the program later uses it. The pause in
this demonstration makes the timing visible. Strictly, this program mainly
demonstrates the difference between an open-time permission decision and
later operations on an already-open object; it does not separately call a
permission-check function and then reopen the pathname.

The key distinction is between a pathname (a name looked up in a directory)
and an open file descriptor/handle (a reference to an already-open object).
On Unix-like systems, an unlinked file can remain alive while an open
descriptor refers to it.

### Design principles and safer design

- **Complete mediation:** access decisions should reflect the object and
  operation being used. Do not check one pathname and later assume a separate
  lookup identifies the same object.
- **Fail-safe defaults:** deny access when permission is absent or uncertain.
  The no-permission-at-open test illustrates denial at open time.
- **Least privilege:** run with only the permissions needed and restrict
  access to files and directories.
- **Economy of mechanism:** keep security-sensitive file handling simple and
  use well-understood operating-system APIs.

The observed behavior is not automatically proof that the operating system
violates these principles: permissions checked at open time and access
retained by an open descriptor are intentional file semantics. A vulnerable
application often arises when it checks a name, then later performs a second
path-based operation that may resolve to a different object.

Prefer atomic open/create operations and continue using the returned
descriptor rather than re-checking and reopening a pathname. When the
application must ensure a particular object or prevent concurrent changes,
use appropriate descriptor-based checks and coordination mechanisms. Locks
can help when concurrent access must be serialized, but add complexity and
can reduce performance. Restrictive permissions and least privilege limit
the consequences of mistakes.

## Buzzword glossary

| Term                           | Short explanation                                                                                                        |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| **Access control**       | Rules that determine which subject (user or program) can perform which operation on an object.                           |
| **Atomic operation**     | An operation that appears indivisible to other processes; useful for avoiding a gap between separate steps.              |
| **Bound parameter**      | A value passed separately from a database query's SQL syntax.                                                            |
| **Certificate**          | A signed document binding a public key to an identity or name under an issuer's policy.                                  |
| **CSP**                  | Content Security Policy; browser-enforced restrictions on page resources and script execution.                           |
| **CSRF token**           | An unpredictable value the server expects with a state-changing request to distinguish legitimate application flows.     |
| **Entropy**              | A measure of uncertainty, expressed here in bits; it depends on how choices are generated.                               |
| **Hash / password hash** | A one-way digest; password storage should use a salted, deliberately expensive password-hashing function.                |
| **Hybrid encryption**    | Public-key cryptography protects a short symmetric key; symmetric encryption protects the bulk message.                  |
| **KDF**                  | Key Derivation Function; for passwords, a deliberately costly function used to slow guessing.                            |
| **Least privilege**      | Giving each account or process only the permissions it needs.                                                            |
| **Parameterization**     | Supplying query values separately from SQL structure so values cannot become SQL syntax.                                 |
| **Salt**                 | A unique random value stored with a password hash to make equal passwords hash differently and frustrate precomputation. |
| **S/MIME**               | Email standard supporting certificate-based message signing and encryption.                                              |
| **TOCTTOU**              | A race between checking a resource and later using it after its state may have changed.                                  |
| **X.509**                | Standard format for public-key certificates used in S/MIME and other systems.                                            |
| **XSS**                  | Injection of untrusted content that a browser interprets as active content in a site's origin.                           |

## Discussion prompts

- What is the application's trust boundary in each task, and which component
  incorrectly trusts which input or request?
- Which result was directly observed, and which part is an assumption or
  theoretical model?
- Why is parameterization stronger than trying to remove “bad characters”?
- Why are XSS and CSRF separate problems even though both can lead to actions
  performed through a user's browser?
- Which assumptions make the entropy numbers larger or smaller?
- Which file operations refer to a pathname, and which use an already-open
  descriptor?
- Which defense prevents the flaw, and which defense only limits its impact?

## References and related files

- [OWASP: SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [OWASP: Cross Site Scripting](https://owasp.org/www-community/attacks/xss/)
- [OWASP: Cross-Site Request Forgery](https://owasp.org/www-community/attacks/csrf)
- [OWASP: Content Security Policy](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)
- [NIST SP 800-63-2](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-63-2.pdf)
- [Saltzer and Schroeder, “The Protection of Information in Computer Systems”](https://web.mit.edu/Saltzer/www/publications/protection/Basic.html)
- [POSIX `unlink`](https://pubs.opengroup.org/onlinepubs/9699919799/functions/unlink.html)
- [Main lab report](report-1-final.md) and [higher-grade report](report-1-final-HG.md)
