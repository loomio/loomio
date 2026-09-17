## User API responses support a compact profile

User API clients can pass `compact=1` to omit bulky related records or use `exclude_types` for direct control over related record types. Collection endpoints now return an exact pre-pagination `meta.total` where one is defined, while endpoints without a meaningful total omit the field instead of returning `null`.
