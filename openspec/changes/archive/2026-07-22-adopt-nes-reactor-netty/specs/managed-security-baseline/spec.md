## MODIFIED Requirements

### Requirement: Managed vulnerable components MUST use Java 8 compatible security versions
The dependency management BOM SHALL manage PostgreSQL JDBC 42.7.13, H2 2.2.220, Hazelcast 5.2.5, RabbitMQ Java Client 5.18.0, Spring LDAP 2.4.4, Sun/Jakarta Mail 1.6.8, Undertow 2.2.40.Final, Tomcat 9.0.120, and Netty 4.1.136.Final unless validation proves a target incompatible and the design is updated before completion. Derby SHALL remain at 10.14.2.0 because no Java 8 security-fix artifact is published to Maven Central.

#### Scenario: Generated Maven BOM
- **WHEN** the Spring Boot dependency-management POM is generated
- **THEN** every listed component resolves to the target version with no stale managed version

#### Scenario: Gradle dependency resolution
- **WHEN** a relevant Spring Boot module resolves its compile or test runtime classpath
- **THEN** it contains a single version of each upgraded component and that version matches the managed target

#### Scenario: Reactor Netty consumer resolves Netty
- **WHEN** WebFlux, WebClient, Actuator, or RSocket resolves Netty through the NES Reactor Netty fork
- **THEN** all Netty BOM-managed modules resolve to 4.1.136.Final with no 4.1.135.Final or older duplicate
