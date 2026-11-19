# Sources for Lab 1 Reports

This file is for checking sources and is not intended to be handed in with the
two reports. The reports use the labels below in their explanations.

## [1] OWASP: Cross-Site Scripting

URL: <https://owasp.org/www-community/attacks/xss/>

> “Cross-Site Scripting (XSS) attacks are a type of injection, in which
> malicious scripts are injected into otherwise benign and trusted websites.”

The same page also explains that the browser can execute the script because it
believes it came from a trusted source, and that stored XSS is saved on the
target server before a victim retrieves it.

## [2] OWASP: Cross-Site Request Forgery

URL: <https://owasp.org/www-community/attacks/csrf>

> “Cross-Site Request Forgery (CSRF) is an attack that forces an end user to
> execute unwanted actions on a web application in which they’re currently
> authenticated.”

The page also states that browser requests automatically include credentials
associated with the site, such as a session cookie.

## [3] Claude Shannon: A Mathematical Theory of Communication

URL: <https://people.math.harvard.edu/~ctm/home/text/others/shannon/entropy/entropy.pdf>

> “The fundamental problem of communication is that of reproducing at one
> point either exactly or approximately a message selected at another point.”

This is the source used for the information-theory discussion. The report’s
password calculations apply the usual `log2(number of possibilities)` formula
to a uniformly random password space.

## [4] NIST SP 800-63-2

URL: <https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-63-2.pdf>

> “Memorized secret: A secret that is memorized by a claimant and used to
> authenticate the claimant’s identity.”

The report uses this publication for the distinction between theoretical
randomness and passwords selected by people. The assignment specifically
points to page 107.

## [5] Saltzer and Schroeder: The Protection of Information in Computer Systems

URL: <https://web.mit.edu/Saltzer/www/publications/protection/Basic.html>

> “Security describes techniques that control who may use or modify the
> computer or the information contained in it.”

The paper is used for the access-control discussion, especially complete
mediation and least privilege.

## [6] Lab assignment

The assignment itself is the local source for the required exercises,
examples, and URLs. The copy used for this report is stored in the session
attachment and is not repeated here because it is not a public URL.
