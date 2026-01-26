---
trigger: always_on
---

When making code changes, avoid any operations that could break the existing database structure or cause data loss for current users.

Be especially careful with migrations, schema changes, table/column removals; if required, they must be backward compatible.

The top priority is ensuring that existing users do not experience issues due to new changes.

If you add any static text, UI labels, error messages, or descriptions:

Add the Turkish version to app_tr.arb

Add the English version to app_en.arb

Localization keys must be clear, consistent, and non-duplicated.

You may use and prefer the Dart MCP when implementing solutions.

Avoid unnecessary refactoring; only modify areas directly related to the requested change.

Always prioritize performance, data safety, and user experience.