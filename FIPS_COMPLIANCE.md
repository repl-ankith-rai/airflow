# Apache Airflow FIPS Compliance

This document describes the FIPS (Federal Information Processing Standards) compliance features of this custom Apache Airflow build.

## Overview

This build of Apache Airflow 2.11.0 has been modified to run on Amazon Linux 2023 with FIPS-compliant cryptographic modules. FIPS 140-2/140-3 compliance is required for many US government agencies and regulated industries.

## Key Features

1. **FIPS-Compliant Base Image**: Uses a custom Amazon Linux 2023 image with FIPS-compliant Python 3.9
   - Base image: `434423891815.dkr.ecr.us-east-1.amazonaws.com/machine-images/fips-base:m-16871-amazon-linux-2023-python-3-9-amd64`

2. **FIPS Compatibility**: The image is built to be compatible with FIPS mode:
   - Uses system libraries and configurations that support FIPS mode
   - Relies on the base image's FIPS compliance capabilities
   - Compatible with FIPS crypto policies

3. **Amazon Linux 2023 Compatibility**: 
   - Uses `dnf` for package management
   - Properly handles the different paths and command tools in Amazon Linux vs Debian

4. **FIPS-Specific Adaptations**:
   - Modified networking utilities to use Amazon Linux's `ncat` 
   - LD_PRELOAD settings for Amazon Linux libraries
   - Secure cryptographic defaults

## Verifying FIPS Mode

To verify if FIPS mode is correctly enabled in your container, you can run these commands manually:

```bash
# Check if FIPS is enabled at the system level
cat /proc/sys/crypto/fips_enabled
```

A value of "1" indicates that FIPS mode is enabled at the system level.

```bash
# Check if OpenSSL is running in FIPS mode
openssl md5 /etc/passwd
```

If you see an error message stating that the command is disabled for FIPS, OpenSSL is correctly running in FIPS mode.

```bash
# Check the current crypto policy (Amazon Linux/RHEL)
update-crypto-policies --show
```

The output should be "FIPS" or similar FIPS-related policy.

## Manual FIPS Verification

To manually verify FIPS compliance in a running container:

1. Check if the system is in FIPS mode:
   ```bash
   cat /proc/sys/crypto/fips_enabled
   ```
   A value of "1" means FIPS mode is enabled.

2. Verify OpenSSL FIPS mode:
   ```bash
   openssl md5 /etc/passwd
   ```
   In FIPS mode, this should return an error saying the command is disabled.

3. Check the crypto policies:
   ```bash
   update-crypto-policies --show
   ```
   This should display "FIPS" or "FIPS:OSPP".

## Security Considerations

1. **Disabled Algorithms**: In FIPS mode, certain algorithms are disabled:
   - MD5
   - SHA1 (for digital signatures)
   - RC4
   - DES
   - And other non-FIPS approved algorithms

2. **Potential Issues**: Some Airflow providers or dependencies might use non-FIPS algorithms and fail in FIPS mode. Common issues include:
   - Legacy cryptographic functions
   - Hash functions like MD5 used for non-cryptographic purposes
   - Third-party libraries using non-approved algorithms

3. **Workarounds**: For components that fail in FIPS mode:
   - Consider using alternative FIPS-approved algorithms
   - Modify the code to use FIPS-approved algorithms
   - Request FIPS compliance from the library maintainers

## Running with FIPS Mode

To ensure FIPS mode is enabled in your container:

1. Run the container with the appropriate FIPS base image (already configured in Dockerfile)

2. Verify FIPS status during startup (automatic)

3. If FIPS mode is not enabled, you can enable it inside the container:
   ```bash
   update-crypto-policies --set FIPS
   ```

## Known Limitations

1. Some Python libraries may have issues in FIPS mode if they use non-approved cryptographic algorithms

2. Performance impact: FIPS-compliant cryptographic operations may be slower than non-FIPS operations

3. Some Airflow providers may not be FIPS compatible - test thoroughly before deployment

---

For additional information about FIPS compliance, refer to:
- [NIST FIPS 140-2/140-3](https://csrc.nist.gov/projects/cryptographic-module-validation-program/standards)
- [Amazon Linux 2023 Security Features](https://docs.aws.amazon.com/linux/al2023/ug/security-features.html)