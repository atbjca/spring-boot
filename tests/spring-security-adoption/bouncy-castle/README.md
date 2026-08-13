# SendGrid and Spring Security Bouncy Castle smoke

This fixture combines SendGrid with the NES Spring Security SAML and Crypto modules without copying the Spring Boot root build's coordinate mapping or source substitution.

The Maven and Gradle combined builds share one Java 8 smoke. It checks the SendGrid constructors used by Boot auto-configuration, mail JSON construction, Bouncy Castle AES-GCM, Spring Security Crypto, OpenSAML initialization, and the actual provider code source selected at runtime. The `maven-sendgrid-only` build runs the same source with Security checks disabled so the exclusion/replacement option is also exercised on a genuinely independent SendGrid classpath.

The selected disposition is the minimum native-family upgrade, SendGrid `4.10.1`. It is now the default for both fixtures. The older inputs remain available for reproducible comparison:

- selected default: SendGrid `4.10.1`, whose `bcprov-jdk18on` request is managed by the Security BOM to `1.84`;
- old baseline: SendGrid `4.9.3`, which contributes `bcprov-jdk15on:1.70`;
- exclusion/replacement: SendGrid `4.9.3` with `bcprov-jdk15on` excluded while the Security BOM supplies `jdk18on:1.84`.

The Gradle `assertBouncyCastleGraph` task requires exactly `bcpkix-jdk18on`, `bcprov-jdk18on`, and `bcutil-jdk18on` at 1.84. `scripts/verify-bouncy-castle-disposition.sh` applies the equivalent Maven assertion and runs both Java 8 behavior smokes. Override the default with Maven `-Dsendgrid.version=4.9.3` or Gradle `-PsendGridVersion=4.9.3` only when reproducing the pre-disposition graph.
