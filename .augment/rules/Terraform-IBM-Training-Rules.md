---
type: "always_apply"
---

IBM Cloud Terraform Training Content Creation Rules

# MANDATORY DELIVERABLE STRUCTURE
Each subtopic requires exactly 7 files minimum:
1. Concept.md (300+ lines): Learning objectives, IBM Cloud specifics, 5+ service examples, 3+ quantified use cases, security/cost sections
2. Lab-X.md (250+ lines): 90-120min duration, step-by-step instructions, cost estimates, validation steps, troubleshooting
3. DaC/directory: Python script generating 5 diagrams (300 DPI), requirements.txt, README.md (100+ lines)
4. Terraform-Code-Lab-X.Y/: providers.tf, variables.tf (15+ vars), main.tf, outputs.tf (10+ outputs), terraform.tfvars.example, supporting scripts, README.md (200+ lines)
5. Test-Your-Understanding-Topic-X.md: 20 multiple choice + 5 scenarios + 3 hands-on challenges

# QUALITY STANDARDS (NON-NEGOTIABLE)
- IBM Cloud Specificity: All content uses actual IBM Cloud services, pricing, configurations
- Enterprise Documentation: Consistent formatting, professional structure, comprehensive cross-references
- Code Quality: terraform validate passes, 20% comment ratio, security best practices, cost optimization
- Educational Standards: Measurable learning objectives, progressive difficulty, practical applicability
- Business Value: Quantified ROI, cost savings percentages, time reductions, risk mitigation metrics

# NAMING CONVENTIONS
- Directories: kebab-case (02-Terraform-CLI-Provider-Installation)
- Documentation: PascalCase (Concept.md, Lab-2.md)
- Scripts: snake_case (terraform_cli_diagrams.py)
- Terraform: lowercase_underscore (main.tf, variables.tf)

# VALIDATION REQUIREMENTS
- Technical: All Terraform code tested in IBM Cloud environment
- Content: Peer review for accuracy and completeness
- Educational: Learning objective achievement verification
- Business: ROI calculations and cost-benefit analysis
- Self-validation checklist completion mandatory

# SUCCESS CRITERIA
- 300+ lines Concept.md with IBM Cloud specifics
- Working Terraform code with comprehensive documentation
- Professional diagrams with consistent styling
- Practical labs with real resource provisioning
- Enterprise-grade quality matching Topic 1 standards