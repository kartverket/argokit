---
name: Feature Request
about: Suggest an idea for this project
title: ''
labels: 'enhancement'
assignees: ''
---

## Is your feature request related to a problem? 🤔
A clear and concise description of what the problem is. 

**Example:** I'm always frustrated when I have to manually create a database archive job,

## Describe the solution you'd like ✨
A clear and concise description of what you want to happen.

**Example:** I'd like an ArgoKit function like `argokit.dbarchivejob()` that sets up an archive job for me with standard configurations.
**Proposed usage:**
```jsonnet
local argokit = import 'argokit.libsonnet';

argokit.dbarchivehob('my-dbarchivejob')
```

## Describe alternatives you've considered 🔀
A clear and concise description of any alternative solutions or features you've considered.

**Example:** 
- Writing raw YAML/JSON
- Creating custom Jsonnet libraries

## Use Case 📋
Describe your specific use case:
- How often would you use this feature?
- Would many other benefit from this feature?

## Potential Impact 📈
How would this feature improve ArgoKit or the user experience?
- Would it reduce boilerplate code?
- Would it prevent common misconfigurations?
- Would it improve integration with ArgoCD features?

## Additional Context 🌐
Add any other context, mockups, or examples about the feature request here:
- Example Jsonnet code showing desired behavior