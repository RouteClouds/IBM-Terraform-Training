# Python Environment Setup for Diagram Generation

## Overview

This document provides comprehensive instructions for setting up the Python environment required for generating diagrams in the IBM Cloud Terraform Training Program. The Diagram as Code (DaC) approach ensures version-controlled, reproducible visual learning aids.

## Prerequisites

- Python 3.8 or higher installed on the system
- pip package manager
- Virtual environment support (venv module)
- Sufficient disk space for diagram generation (~50MB)

## Setup Instructions

### 1. Create Python Virtual Environment

Navigate to the main training directory and create a virtual environment:

```bash
cd /path/to/Terraform-IBM-Cloud-Training
python3 -m venv diagram-env
```

### 2. Activate Virtual Environment

Activate the virtual environment using the appropriate command for your system:

**Linux/macOS:**
```bash
source diagram-env/bin/activate
```

**Windows:**
```cmd
diagram-env\Scripts\activate
```

### 3. Install Required Dependencies

Install the core dependencies required for diagram generation:

```bash
pip install matplotlib>=3.7.0 numpy>=1.24.0
```

### 4. Verify Installation

Verify that the packages are installed correctly:

```bash
pip list | grep -E "(matplotlib|numpy)"
```

Expected output:
```
matplotlib    3.7.x
numpy         1.24.x
```

## Testing Diagram Generation

### Test Script 1: IaC Concepts Diagrams

Navigate to the first DaC directory and test diagram generation:

```bash
cd 01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/DaC
source ../../../diagram-env/bin/activate
python iac_concepts_diagrams.py
```

**Expected Output:**
```
Generating Infrastructure as Code concept diagrams...
✓ Traditional vs IaC comparison diagram created
✓ IaC principles diagram created
✓ IaC workflow diagram created
✓ IaC tools landscape diagram created
✓ IaC benefits diagram created

All diagrams have been generated and saved to 'generated_diagrams/' directory

Generated files:
  - traditional_vs_iac_comparison.png
  - iac_principles.png
  - iac_tools_landscape.png
  - iac_benefits.png
  - iac_workflow.png
```

### Test Script 2: Benefits and Use Cases Diagrams

Navigate to the second DaC directory and test diagram generation:

```bash
cd ../../02-Benefits-and-Use-Cases/DaC
source ../../../diagram-env/bin/activate
python benefits_use_cases_diagrams.py
```

**Expected Output:**
```
Generating IaC Benefits and Use Cases diagrams...
✓ ROI comparison chart created
✓ IBM Cloud benefits diagram created
✓ Use case timeline created
✓ Cost optimization diagram created
✓ Industry use cases diagram created

All diagrams have been generated and saved to 'generated_diagrams/' directory

Generated files:
  - cost_optimization.png
  - ibm_cloud_benefits.png
  - industry_use_cases.png
  - roi_comparison.png
  - use_case_timeline.png
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Font Warnings
**Issue:** Unicode character warnings for emojis/symbols
```
UserWarning: Glyph 128176 (\N{MONEY BAG}) missing from font(s) DejaVu Sans.
```

**Solution:** These warnings are cosmetic and don't affect diagram generation. The diagrams will still be created successfully. To suppress warnings, you can:
- Install additional font packages (optional)
- Ignore the warnings as they don't impact functionality

#### 2. Virtual Environment Activation Issues
**Issue:** `bash: diagram-env/bin/activate: No such file or directory`

**Solution:** 
- Ensure you're in the correct directory (`Terraform-IBM-Cloud-Training`)
- Verify the virtual environment was created successfully
- Check the path to the activation script

#### 3. Permission Errors
**Issue:** Permission denied when creating directories or files

**Solution:**
- Ensure you have write permissions in the training directory
- Run with appropriate user permissions
- Check disk space availability

#### 4. Module Import Errors
**Issue:** `ModuleNotFoundError: No module named 'matplotlib'`

**Solution:**
- Ensure the virtual environment is activated
- Reinstall the required packages
- Verify pip is using the virtual environment

#### 5. Python Version Compatibility
**Issue:** Syntax errors or compatibility issues

**Solution:**
- Ensure Python 3.8+ is being used
- Update Python if necessary
- Verify virtual environment is using correct Python version

### Verification Commands

Use these commands to verify successful setup:

```bash
# Check virtual environment is active
which python
# Should show path to diagram-env/bin/python

# Verify package installation
python -c "import matplotlib; import numpy; print('All packages imported successfully')"

# Check diagram generation capability
python -c "import matplotlib.pyplot as plt; plt.figure(); plt.savefig('test.png'); print('Diagram generation test successful')"

# Clean up test file
rm test.png
```

## Directory Structure After Setup

```
Terraform-IBM-Cloud-Training/
├── diagram-env/                          # Python virtual environment
│   ├── bin/
│   │   ├── activate                      # Activation script
│   │   └── python                        # Python interpreter
│   ├── lib/
│   │   └── python3.x/
│   │       └── site-packages/            # Installed packages
│   └── pyvenv.cfg
├── 01-IaC-Concepts-IBM-Cloud-Integration/
│   ├── 01-Overview-of-IaC/
│   │   └── DaC/
│   │       ├── generated_diagrams/       # Generated PNG files
│   │       ├── iac_concepts_diagrams.py
│   │       ├── requirements.txt
│   │       └── README.md
│   └── 02-Benefits-and-Use-Cases/
│       └── DaC/
│           ├── generated_diagrams/       # Generated PNG files
│           ├── benefits_use_cases_diagrams.py
│           ├── requirements.txt
│           └── README.md
└── PYTHON-ENVIRONMENT-SETUP.md          # This file
```

## Best Practices

### 1. Environment Management
- Always activate the virtual environment before running diagram scripts
- Keep the virtual environment in the main training directory
- Document any additional dependencies in requirements.txt files

### 2. Diagram Generation
- Run diagram generation scripts from their respective DaC directories
- Verify all diagrams are generated before proceeding with training
- Check diagram quality and resolution (300 DPI minimum)

### 3. Maintenance
- Regularly update packages for security and compatibility
- Test diagram generation after any environment changes
- Keep backup copies of successfully generated diagrams

### 4. Collaboration
- Include virtual environment setup in instructor preparation
- Provide this documentation to all training facilitators
- Test setup process on different operating systems

## Integration with Training Program

### Instructor Preparation
1. Set up Python environment during pre-course preparation
2. Generate all diagrams before training sessions
3. Verify diagram quality and readability
4. Prepare backup diagrams in case of technical issues

### Student Activities
- Students can optionally set up their own environment for diagram customization
- Advanced exercises may include modifying diagram generation scripts
- Encourage exploration of diagram code for deeper understanding

### Continuous Integration
- Consider automating diagram generation in CI/CD pipelines
- Validate diagram generation as part of content quality assurance
- Update diagrams automatically when content changes

## Support and Resources

### Documentation References
- [Matplotlib Documentation](https://matplotlib.org/stable/)
- [NumPy Documentation](https://numpy.org/doc/stable/)
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)

### Contact Information
For technical issues with diagram generation:
1. Check this troubleshooting guide first
2. Verify environment setup steps
3. Consult training program documentation
4. Contact technical support team

## Version History

- **v1.0**: Initial setup documentation
- **v1.1**: Added troubleshooting section and verification commands
- **v1.2**: Enhanced best practices and integration guidance

---

**Note**: This setup process has been tested and validated on Linux systems. Minor adjustments may be needed for Windows or macOS environments.
