# IBM Cloud Terraform Training Excel Generator

## Overview

This Python script generates a professional Excel workbook with multiple worksheets based on the IBM Cloud Terraform training content detailed in the `Client-Reply.md` document. The generated Excel file is immediately suitable for client sharing and presentation.

## Features

### 📊 **Multi-Worksheet Excel File**
The script creates a comprehensive Excel workbook with 6 professionally formatted worksheets:

1. **Course Overview** - Executive summary, duration, format, and learning outcomes
2. **Daily Syllabus** - Detailed 4-day breakdown with topics, timing, and labs
3. **Lab Sessions** - Comprehensive lab details with objectives and duration
4. **Sandbox Environment** - Technical specifications and setup process
5. **Delivery Options** - 3 delivery formats with timelines and benefits
6. **Prerequisites** - Required knowledge, experience, and technical requirements

### 🎨 **Professional Formatting**
- **Consistent Styling** - IBM Blue color scheme with professional fonts
- **Structured Tables** - Clear headers, borders, and cell formatting
- **Optimized Layout** - Proper column widths and row heights for readability
- **Client-Ready** - No additional formatting needed for presentation

### 🔧 **Technical Implementation**
- **Virtual Environment Compatible** - Uses existing Python environment at `diagram-env/`
- **Robust Error Handling** - Comprehensive validation and error reporting
- **Self-Contained** - All content embedded, no external file dependencies
- **Cross-Platform** - Works on Linux, Windows, and macOS

## Requirements

### Software Requirements
- **Python 3.7+** with virtual environment support
- **openpyxl library** (already installed in diagram-env)
- **Access to existing virtual environment** at `/diagram-env/`

### Environment Setup
The script is designed to work with the existing Python virtual environment:
```bash
/home/ubuntu/Projects/IBM/IBM-Terraform-Training/Terraform-IBM-Cloud-Training/diagram-env/
```

## Installation & Usage

### Quick Start
1. **Navigate to the project directory:**
   ```bash
   cd /home/ubuntu/Projects/IBM/IBM-Terraform-Training/Terraform-IBM-Cloud-Training
   ```

2. **Activate the virtual environment:**
   ```bash
   source diagram-env/bin/activate
   ```

3. **Run the Excel generator:**
   ```bash
   python generate_training_excel_simple.py
   ```

4. **Locate the generated file:**
   ```
   IBM_Terraform_Training_Course_Details.xlsx
   ```

### Advanced Usage

#### Custom Output Filename
```python
from generate_training_excel_simple import TerraformTrainingExcelGenerator

generator = TerraformTrainingExcelGenerator()
generator.generate_excel_file('Custom_Training_Proposal.xlsx')
```

#### Individual Worksheet Creation
```python
generator = TerraformTrainingExcelGenerator()
generator.create_course_overview_sheet()
generator.create_daily_syllabus_sheet()
# ... create other sheets as needed
generator.workbook.save('Partial_Workbook.xlsx')
```

## File Structure

### Generated Excel Worksheets

#### 1. Course Overview
- **Content**: Executive summary, course details, learning outcomes, highlights
- **Format**: Professional layout with IBM branding colors
- **Purpose**: High-level overview for decision makers

#### 2. Daily Syllabus
- **Content**: 4-day detailed schedule with topics, timing, and lab exercises
- **Format**: Structured table with clear day/session breakdown
- **Purpose**: Detailed planning and instructor guidance

#### 3. Lab Sessions
- **Content**: 8 comprehensive labs with objectives and activities
- **Format**: Lab-by-lab breakdown with duration and key activities
- **Purpose**: Hands-on learning component details

#### 4. Sandbox Environment
- **Content**: Technical infrastructure, development tools, setup process
- **Format**: Component-based breakdown with benefits
- **Purpose**: Environment specifications and requirements

#### 5. Delivery Options
- **Content**: 3 delivery formats with comparison and recommendations
- **Format**: Comparison table with benefits and ideal use cases
- **Purpose**: Flexible delivery planning

#### 6. Prerequisites
- **Content**: Required knowledge, recommended experience, technical requirements
- **Format**: Categorized requirements with descriptions
- **Purpose**: Student preparation and readiness assessment

## Customization

### Styling Modifications
The script uses a professional IBM Blue color scheme. To customize:

```python
# Modify colors in setup_styles() method
self.colors = {
    'header_bg': 'C6E0FF',      # Light blue
    'subheader_bg': 'E6F3FF',   # Very light blue
    'accent_bg': 'F0F8FF',      # Alice blue
    'border_color': '4A90E2',   # IBM blue
}
```

### Content Updates
To update content, modify the data arrays in each worksheet creation method:

```python
# Example: Update course information
course_info = [
    ['Duration:', '5 Days (40 hours)', '', ''],  # Modified duration
    # ... other course details
]
```

## Troubleshooting

### Common Issues

#### 1. Virtual Environment Not Found
```bash
# Error: diagram-env not found
# Solution: Ensure you're in the correct directory
cd /home/ubuntu/Projects/IBM/IBM-Terraform-Training/Terraform-IBM-Cloud-Training
```

#### 2. Permission Errors
```bash
# Error: Permission denied writing Excel file
# Solution: Check file permissions and ensure file isn't open
chmod 664 IBM_Terraform_Training_Course_Details.xlsx
```

#### 3. Missing Dependencies
```bash
# Error: ModuleNotFoundError: No module named 'openpyxl'
# Solution: Activate virtual environment and install dependencies
source diagram-env/bin/activate
pip install openpyxl
```

### Validation Steps

1. **Check file generation:**
   ```bash
   ls -la IBM_Terraform_Training_Course_Details.xlsx
   ```

2. **Verify file size (should be ~13KB):**
   ```bash
   du -h IBM_Terraform_Training_Course_Details.xlsx
   ```

3. **Test file opening:**
   - Open with Excel, LibreOffice Calc, or Google Sheets
   - Verify all 6 worksheets are present
   - Check formatting and content accuracy

## Output Specifications

### File Details
- **Filename**: `IBM_Terraform_Training_Course_Details.xlsx`
- **Format**: Excel 2010+ (.xlsx)
- **Size**: Approximately 13-15 KB
- **Worksheets**: 6 professionally formatted sheets
- **Compatibility**: Excel 2010+, LibreOffice Calc, Google Sheets

### Quality Standards
- **Professional Appearance** - Client-ready formatting
- **Comprehensive Content** - All training details included
- **Consistent Branding** - IBM Blue color scheme throughout
- **Optimized Layout** - Proper spacing and readability
- **Error-Free** - Validated content and formatting

## Support & Maintenance

### Script Maintenance
- **Content Updates**: Modify data arrays in worksheet methods
- **Styling Changes**: Update `setup_styles()` method
- **New Worksheets**: Add new `create_*_sheet()` methods
- **Bug Fixes**: Check error handling and validation logic

### Version History
- **v1.0** - Initial release with 6 core worksheets
- **v1.1** - Simplified version with improved error handling
- **Current** - Stable production version

## License & Usage

This script is part of the IBM Cloud Terraform Training project and is intended for:
- **Internal Use** - Training development and delivery
- **Client Presentations** - Professional proposal generation
- **Educational Purposes** - Training material creation

---

**Generated by**: Augment Agent  
**Date**: September 29, 2025  
**Version**: 1.1  
**Status**: Production Ready
