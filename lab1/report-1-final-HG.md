# Lab 1: Secure Computing — Higher Grades

**Author:** Calvin Koch  
**Date:** 19.11.2026

This file contains only the higher-grade exercises. Source quotations and
links are kept in [`references.md`](references.md).

## Task 1: SQL Injection

### Hash extraction and cracking

The SQL injection can be extended to extract the users table, including user
names and password hashes. The hashes and any passwords recovered from them
should be inserted below from the actual Juice Shop output:

| User | Hash | Cleartext password |
|---|---|---|
| Insert user from output | Insert hash from output | Insert recovered password |
| Insert user from output | Insert hash from output | Insert recovered password |

The algorithm should be identified from the hash format and the Juice Shop
implementation, not guessed from the length alone. Password storage would be
more secure with a unique random salt for every password and a slow,
memory-hard password hashing algorithm such as Argon2, scrypt, or bcrypt.

### sqlmap (Exercises 7–9)

`sqlmap` automates testing for SQL injection. It sends different inputs and
compares responses, errors, or timing differences to determine whether input
changes the database query. After identifying the injection point, it can
enumerate the database and retrieve table contents.

The relevant options mean:

* `--ignore-code 401`: continue testing even when the server returns HTTP 401.
* `--technique=U`: use UNION-based injection.
* `--dbms=sqlite`: tell sqlmap that the backend is SQLite.
* `--dump`: retrieve the contents of discovered tables.

The report should include the actual command, endpoint, output, and the
reason each option was needed.

## Task 2: XSS/CSRF

### Protection ramifications (Exercise 6)

If XSS is protected but CSRF is not, an attacker can still host a page with a
hidden form that submits a state-changing request to the vulnerable site [2]. For
example, a logged-in victim could be tricked into changing their email
address.

If CSRF is protected but XSS is not, injected JavaScript can run in the
trusted page and read an anti-CSRF token from the page before sending the
request. XSS can therefore defeat a token-based CSRF defence.

A combined defence should use context-aware output encoding and safe input
handling for XSS, a strict Content Security Policy, anti-CSRF tokens for
state-changing requests, and suitable `SameSite` cookie settings [1][2]. These
controls cover different parts of the attack, so one does not replace the
other.

## Task 3: Password Policy

### Information-theory minimum length

The policy allows 93 symbols. The theoretical entropy per random symbol is

`log2(93) ≈ 6.54 bits`.

To reach 27 bits, the minimum random length is

`27 / log2(93) = 4.13`,

so 5 random symbols are needed. The policy still requires 10 symbols because
human-created passwords are not random. People choose words and predictable
capitalisation, so the theoretical calculation overestimates their real
entropy [4].

### Entropy for lengths n and 2n

For an alphabet of 62 symbols:

`E(n) = n * log2(62)`.

For length `2n`:

`E(2n) = 2n * log2(62) = 2E(n)`.

Doubling the length doubles the entropy, assuming the characters are selected
randomly.

### Brute-force estimate

For a random password of length 10 from 93 symbols:

`93^10 ≈ 4.83 * 10^19` possible passwords.

At 1000 guesses per second:

`4.83 * 10^19 / 1000 = 4.83 * 10^16 seconds`.

This is approximately 1.53 billion years in the worst case. On average, a
successful exhaustive search would take about half that time.

## Task 4: Design Principles (Exercises 9–11)

The TOCTTOU behaviour conflicts mainly with **complete mediation** [5]. The
permission decision is made at one time, but the object can be changed before
the later use. The system does not repeat the same security check at the
moment the operation uses the file.

The practical fix is to avoid separating the check from the use. The program
can open the file with the required access in one operation and then use that
file descriptor. Atomic operating-system operations and appropriate file
locking can also reduce the race window.

The trade-off is that extra locking and checks can reduce performance and
complicate programs. However, for sensitive files, preventing an attacker
from replacing or deleting the object is more important than a small
performance gain. The first priority should be an atomic operation or a
trusted descriptor, followed by least-privilege permissions and careful error
handling.

## References

See [`references.md`](references.md) for the source quotations and URLs.
