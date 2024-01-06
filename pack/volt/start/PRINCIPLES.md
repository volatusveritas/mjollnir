# Principles

- Always expose functions and allow the user to decide what keys to bind it to.
- If a function is not plugin-local it's meant to be used as a binding (except
  for exposed functions in the **lib** plugin).
- Document all exposed functions and variables. Documenting plugin-local
  functions and variables is optional but recommended.
