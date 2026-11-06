# Account features

Login, registration, password-recovery email and web reset form, account profile changes, password change, account deletion and zero-balance reporting are wired to Laravel API.

No payment provider is connected. The wallet is disabled and actual account balances remain zero. A separate demo-only summary counts simulated pledges with an additional 5% fee.

On Cloud, configure SMTP in production. Local development uses the log mailer. Reset links point to the Cloud web reset page.

Run flutter analyze and flutter test before merging.