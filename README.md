# Passkey and Passwordless Security Research

A defensive research repository for assessing passwordless authentication readiness, deployment controls, and recovery risks.

## Research areas

- Authentication method coverage
- Platform and device support
- Registration and recovery processes
- Phishing resistance
- Shared-device and break-glass scenarios
- Help-desk and user-support readiness
- Logging, monitoring, and governance

## Main tool

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Passkey_and_Passwordless_Security_Research.ps1 -InputCsv .\research\passwordless-systems.csv
```

## Required CSV columns

`SystemName`, `Owner`, `PasswordlessMethod`, `PhishingResistant`, `ManagedDeviceRequired`, `RecoveryDocumented`, `BreakGlassAvailable`, `AuditLogging`, `UserTraining`, `Notes`

## Safety

Assessment and documentation only. No authentication methods or identity settings are changed.
