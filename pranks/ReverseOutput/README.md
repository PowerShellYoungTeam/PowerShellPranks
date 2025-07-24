# Write-ReverseOutput: Write-Output...just backwards

Place this function in someone's PowerShell profile, and anytime Write-Output is called, the output will be reversed.

Example:

```powershell
Write-Output 'The quick brown fox jumped over a lazy log or whatever the saying is'
si gniyas eht revetahw ro gol yzal a revo depmuj xof nworb kciuq ehT
```

## Remediation

Remove Write-ReverseOutput from $profile, and reload session