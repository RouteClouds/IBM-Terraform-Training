# Git Collaboration Diagrams - Diagram as Code (DaC)

## 📋 **Overview**

This directory contains the Diagram as Code (DaC) implementation for **Topic 5.3: Version Control and Collaboration with Git**. The Python script generates 5 professional diagrams at 300 DPI resolution, demonstrating enterprise Git workflows, CI/CD pipelines, team collaboration patterns, and security integration.

### **Generated Diagrams**

1. **Figure 5.3.1**: Git Workflow Patterns for Infrastructure Teams
2. **Figure 5.3.2**: Multi-Team Branching Strategy with Dependency Management  
3. **Figure 5.3.3**: CI/CD Pipeline Architecture with State Management
4. **Figure 5.3.4**: Team Collaboration Workflow with RBAC and Approval Gates
5. **Figure 5.3.5**: Security and Compliance Integration Architecture

---

## 🚀 **Quick Start**

### **Prerequisites**
- Python 3.8 or higher
- pip package manager
- 4GB+ available disk space for diagram generation

### **Installation**
```bash
# Install dependencies
pip install -r requirements.txt

# Generate all diagrams
python git_collaboration_diagrams.py
```

### **Output**
```
generated_diagrams/
├── 11_git_workflow_patterns.png          (2.1 MB)
├── 12_multi_team_branching.png           (2.3 MB)
├── 13_cicd_pipeline_architecture.png     (2.4 MB)
├── 14_team_collaboration_workflow.png    (2.2 MB)
└── 15_security_compliance_integration.png (2.0 MB)
```

---

## 🎨 **Diagram Specifications**

### **Technical Specifications**
- **Resolution**: 300 DPI (Professional Print Quality)
- **Format**: PNG with transparency support
- **Color Space**: RGB with IBM brand color compliance
- **Dimensions**: 16" × 12" (4800 × 3600 pixels)
- **File Size**: ~2.0-2.5 MB per diagram
- **Total Package**: ~11 MB for all diagrams

### **Design Standards**
- **Typography**: Professional fonts with consistent sizing
- **Color Palette**: IBM brand colors with accessibility compliance
- **Layout**: Grid-based positioning with proper spacing
- **Styling**: Enterprise-grade visual hierarchy and clarity
- **Annotations**: Clear labeling with contextual information

### **IBM Brand Color Compliance**
```python
IBM_BLUE = '#1261FE'        # Primary brand color
IBM_DARK_BLUE = '#0F62FE'   # Secondary brand color
IBM_LIGHT_BLUE = '#4589FF'  # Accent color
IBM_GRAY = '#525252'        # Text and borders
IBM_LIGHT_GRAY = '#F4F4F4'  # Background elements
IBM_GREEN = '#24A148'       # Success states
IBM_RED = '#DA1E28'         # Error states and alerts
IBM_YELLOW = '#F1C21B'      # Warning states
IBM_PURPLE = '#8A3FFC'      # Special emphasis
```

---

## 📊 **Diagram Details**

### **Figure 5.3.1: Git Workflow Patterns**
**Purpose**: Illustrate different Git workflow patterns adapted for infrastructure teams

**Components**:
- GitFlow branching model with infrastructure-specific adaptations
- GitHub Flow simplified pattern for continuous deployment
- Environment-based branching for controlled promotion
- Terraform-specific workflow considerations

**Key Features**:
- Branch protection rules and merge strategies
- State management integration points
- Compliance and approval workflows
- Resource dependency handling

### **Figure 5.3.2: Multi-Team Branching Strategy**
**Purpose**: Demonstrate team-based collaboration with shared modules and dependencies

**Components**:
- Team-specific development areas (Platform, Web, API, Data)
- Shared module repository with versioning
- Cross-team dependency management
- Integration testing and coordination points

**Key Features**:
- Clear team ownership boundaries
- Module versioning and distribution
- Dependency resolution workflows
- Coordinated release management

### **Figure 5.3.3: CI/CD Pipeline Architecture**
**Purpose**: Show comprehensive CI/CD pipeline with validation and deployment automation

**Components**:
- Multi-stage validation pipeline (syntax, security, cost, policy)
- Environment-specific deployment workflows
- State management and locking mechanisms
- Approval gates and manual checkpoints

**Key Features**:
- Automated quality gates
- Security scanning integration
- Cost analysis and budget validation
- Remote state management with backups

### **Figure 5.3.4: Team Collaboration Workflow**
**Purpose**: Illustrate role-based access control and approval processes

**Components**:
- RBAC permission matrix for different team roles
- Multi-stage approval workflow with requirements
- Code review checklist and quality standards
- Collaboration metrics and KPIs

**Key Features**:
- Clear role definitions and responsibilities
- Structured approval processes
- Quality assurance checkpoints
- Performance measurement and tracking

### **Figure 5.3.5: Security and Compliance Integration**
**Purpose**: Demonstrate security controls and compliance automation

**Components**:
- Policy-as-code implementation with OPA
- Secrets management and protection strategies
- Compliance framework integration (SOC 2, ISO 27001, etc.)
- Audit trail and monitoring capabilities

**Key Features**:
- Automated policy validation
- Comprehensive secrets protection
- Multi-framework compliance support
- Complete audit and monitoring coverage

---

## 🛠️ **Development and Customization**

### **Script Structure**
```python
git_collaboration_diagrams.py
├── create_professional_style()     # Consistent styling configuration
├── add_watermark()                 # Professional branding
├── diagram_11_git_workflow_patterns()
├── diagram_12_multi_team_branching()
├── diagram_13_cicd_pipeline_architecture()
├── diagram_14_team_collaboration_workflow()
├── diagram_15_security_compliance_integration()
└── main()                          # Orchestration and execution
```

### **Customization Options**

#### **Color Scheme Modification**
```python
# Modify color constants at the top of the script
IBM_BLUE = '#1261FE'  # Change to your brand color
IBM_GREEN = '#24A148' # Modify success color
# ... other color definitions
```

#### **Diagram Dimensions**
```python
# Adjust in create_professional_style()
'figure_size': (16, 12),  # Width x Height in inches
'dpi': 300,               # Resolution (300 for print, 150 for web)
```

#### **Font and Typography**
```python
# Modify font sizes in style configuration
'title_size': 20,         # Main title font size
'subtitle_size': 14,      # Section title font size
'label_size': 12,         # Label font size
'annotation_size': 10,    # Annotation font size
```

### **Adding New Diagrams**
```python
def diagram_16_custom_workflow(style):
    """Custom diagram implementation"""
    fig, ax = plt.subplots(figsize=style['figure_size'], dpi=style['dpi'])
    
    # Your diagram implementation here
    
    add_watermark(ax, style)
    plt.savefig(f'{output_dir}/16_custom_workflow.png', 
                dpi=style['dpi'], bbox_inches='tight')
    plt.close()

# Add to main() function diagrams list
diagrams.append(("Custom Workflow", diagram_16_custom_workflow))
```

---

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Memory Errors**
```bash
# Reduce DPI for lower memory usage
# In create_professional_style(), change:
'dpi': 150,  # Instead of 300
```

#### **Font Rendering Issues**
```bash
# Install additional fonts (Ubuntu/Debian)
sudo apt-get install fonts-liberation fonts-dejavu

# macOS - install via Homebrew
brew install font-liberation font-dejavu
```

#### **Missing Dependencies**
```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get install python3-dev python3-pip
sudo apt-get install libfreetype6-dev libpng-dev

# macOS
brew install freetype libpng
```

#### **Permission Errors**
```bash
# Ensure write permissions for output directory
chmod 755 generated_diagrams/
```

### **Performance Optimization**

#### **Faster Generation**
```bash
# Use conda for faster dependency resolution
conda install matplotlib numpy seaborn

# Or use mamba for even faster installation
mamba install matplotlib numpy seaborn
```

#### **Parallel Generation**
```python
# Modify main() to use multiprocessing
from multiprocessing import Pool

def generate_diagram(diagram_info):
    name, func = diagram_info
    func(create_professional_style())

# In main():
with Pool() as pool:
    pool.map(generate_diagram, diagrams)
```

---

## 📈 **Quality Assurance**

### **Validation Checklist**
- [ ] All 5 diagrams generate without errors
- [ ] File sizes are within expected range (2-3 MB each)
- [ ] Colors match IBM brand guidelines
- [ ] Text is readable at 300 DPI resolution
- [ ] Watermarks are properly positioned
- [ ] Output directory is created successfully

### **Testing Commands**
```bash
# Test diagram generation
python git_collaboration_diagrams.py

# Verify output files
ls -la generated_diagrams/

# Check file sizes
du -h generated_diagrams/*.png

# Validate image integrity
file generated_diagrams/*.png
```

### **Integration Testing**
```bash
# Test with different Python versions
python3.8 git_collaboration_diagrams.py
python3.9 git_collaboration_diagrams.py
python3.10 git_collaboration_diagrams.py

# Test with minimal dependencies
pip install matplotlib numpy seaborn
python git_collaboration_diagrams.py
```

---

## 📚 **Documentation Integration**

### **Markdown Integration**
```markdown
![Git Workflow Patterns](DaC/generated_diagrams/11_git_workflow_patterns.png)
*Figure 5.3.1: Git Workflow Patterns for Infrastructure Teams*
```

### **LaTeX Integration**
```latex
\begin{figure}[h]
\centering
\includegraphics[width=\textwidth]{DaC/generated_diagrams/11_git_workflow_patterns.png}
\caption{Git Workflow Patterns for Infrastructure Teams}
\label{fig:git-workflow-patterns}
\end{figure}
```

### **HTML Integration**
```html
<figure>
  <img src="DaC/generated_diagrams/11_git_workflow_patterns.png" 
       alt="Git Workflow Patterns" style="width: 100%; max-width: 800px;">
  <figcaption>Figure 5.3.1: Git Workflow Patterns for Infrastructure Teams</figcaption>
</figure>
```

---

## 🎯 **Success Metrics**

### **Generation Statistics**
- **Total Diagrams**: 5 professional diagrams
- **Total Size**: ~11 MB (high-quality 300 DPI)
- **Generation Time**: ~30-60 seconds on modern hardware
- **Memory Usage**: ~500 MB peak during generation
- **Quality Score**: Professional print-ready (300 DPI)

### **Educational Impact**
- **Visual Learning**: Complex Git workflows simplified through diagrams
- **Professional Standards**: Enterprise-grade documentation quality
- **Accessibility**: Clear visual hierarchy and color contrast
- **Reusability**: Modular design for easy customization
- **Integration**: Seamless integration with course materials

**Success Criteria**: All diagrams generate successfully with professional quality suitable for enterprise training materials and documentation.

---

*Generated diagrams support the comprehensive understanding of Git workflows and collaboration patterns for enterprise Terraform infrastructure projects.*
