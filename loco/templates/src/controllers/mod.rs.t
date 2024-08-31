skip_exists: true
message: "Injection to {{ rootFolder }}/src/controllers/mod.rs was done successfully."
injections:
- into: {{ rootFolder }}/src/controllers/mod.rs
  create_if_missing: true
  append: true
  content: "pub mod auth;\npub mod notes;\npub mod user;\n"
===
s