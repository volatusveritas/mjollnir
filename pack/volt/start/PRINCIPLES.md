# Principles

- Always expose functions and allow the user to decide what keys to bind it to.
- If a function is not plugin-local it's meant to be used as a binding (except
  for exposed functions in the **lib** plugin).
- Document as necessary; not for religion, but for necessity.
- Use reason; even if you need to do it multiple times for one thing.
- Initialize on setup, not by default.
