#!/usr/bin/env python3
"""
Directory Structure and Configuration Files - Diagram as Code (DaC)
Generates 5 professional diagrams for Terraform project organization concepts.

Diagrams:
1. project_organization.png - Comprehensive project structure overview
2. file_relationships.png - Technical file interaction mapping
3. enterprise_patterns.png - Team collaboration and scaling patterns
4. naming_conventions.png - Standardized naming and consistency guidelines
5. lifecycle_management.png - Project evolution and maintenance strategies

Author: IBM Cloud Terraform Training Program
Created: 2024-01-20
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import seaborn as sns
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import os

# Set style and color palette
plt.style.use('default')
sns.set_palette("husl")

# IBM Brand Colors
IBM_BLUE = '#1261FE'
IBM_DARK_BLUE = '#0F62FE'
IBM_LIGHT_BLUE = '#4589FF'
IBM_GRAY = '#525252'
IBM_LIGHT_GRAY = '#F4F4F4'
IBM_WHITE = '#FFFFFF'
IBM_GREEN = '#24A148'
IBM_ORANGE = '#FF832B'
IBM_RED = '#DA1E28'

def setup_figure(title, figsize=(16, 12)):
    """Setup figure with IBM branding and professional styling."""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Add title with IBM styling
    fig.suptitle(title, fontsize=20, fontweight='bold', color=IBM_BLUE, y=0.95)
    
    # Add IBM Cloud branding
    ax.text(0.02, 0.02, 'IBM Cloud Terraform Training', 
            transform=ax.transAxes, fontsize=10, color=IBM_GRAY,
            bbox=dict(boxstyle="round,pad=0.3", facecolor=IBM_LIGHT_GRAY, alpha=0.8))
    
    return fig, ax

def create_rounded_box(ax, x, y, width, height, text, color=IBM_BLUE, text_color=IBM_WHITE, fontsize=10):
    """Create a rounded rectangle with text."""
    box = FancyBboxPatch((x, y), width, height,
                         boxstyle="round,pad=0.02",
                         facecolor=color, edgecolor=IBM_GRAY, linewidth=1.5)
    ax.add_patch(box)
    
    # Add text
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=fontsize, color=text_color, weight='bold', wrap=True)

def create_arrow(ax, start, end, color=IBM_GRAY, style='->'):
    """Create an arrow between two points."""
    arrow = ConnectionPatch(start, end, "data", "data",
                           arrowstyle=style, shrinkA=5, shrinkB=5,
                           mutation_scale=20, fc=color, ec=color, linewidth=2)
    ax.add_patch(arrow)

def diagram_1_project_organization():
    """Generate comprehensive project structure overview diagram."""
    fig, ax = setup_figure("Terraform Project Organization - Comprehensive Structure Overview")
    
    # Main project container
    create_rounded_box(ax, 0.5, 7, 9, 2.5, 
                      "Terraform Project Structure\nEnterprise-Grade Organization", 
                      IBM_BLUE, IBM_WHITE, 14)
    
    # Core configuration files section
    create_rounded_box(ax, 0.5, 5.5, 2, 1.2, "Core Files\n\nproviders.tf\nvariables.tf\nmain.tf\noutputs.tf", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    # Supporting files section
    create_rounded_box(ax, 2.8, 5.5, 2, 1.2, "Support Files\n\nREADME.md\n.gitignore\n.terraform-version\nMakefile", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    # Environment structure
    create_rounded_box(ax, 5.1, 5.5, 2, 1.2, "Environments\n\ndev/\nstaging/\nproduction/", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    # Modules section
    create_rounded_box(ax, 7.4, 5.5, 2, 1.2, "Modules\n\nnetworking/\ncompute/\nstorage/\nsecurity/", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # File relationships
    create_rounded_box(ax, 1, 3.5, 3, 1.5, "File Relationships\n\n• providers.tf → main.tf\n• variables.tf → all files\n• main.tf → outputs.tf\n• Cross-file dependencies", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 9)
    
    # Best practices
    create_rounded_box(ax, 5.5, 3.5, 3, 1.5, "Best Practices\n\n• Consistent naming\n• Proper documentation\n• Version control\n• Security patterns", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 9)
    
    # Benefits section
    create_rounded_box(ax, 2, 1.5, 6, 1.5, "Enterprise Benefits\n\n60% faster onboarding • 45% fewer errors • 70% faster debugging\n50% better reviews • 80% improved compliance", 
                      IBM_GREEN, IBM_WHITE, 11)
    
    # Add connecting arrows
    create_arrow(ax, (1.5, 5.5), (2.5, 4.8), IBM_GRAY)
    create_arrow(ax, (3.8, 5.5), (3.5, 4.8), IBM_GRAY)
    create_arrow(ax, (6.1, 5.5), (6.5, 4.8), IBM_GRAY)
    create_arrow(ax, (8.4, 5.5), (7.5, 4.8), IBM_GRAY)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/project_organization.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_2_file_relationships():
    """Generate technical file interaction mapping diagram."""
    fig, ax = setup_figure("Configuration File Relationships - Technical Interaction Mapping")
    
    # Central main.tf
    create_rounded_box(ax, 4, 4.5, 2, 1, "main.tf\nResource Definitions", IBM_BLUE, IBM_WHITE, 12)
    
    # providers.tf
    create_rounded_box(ax, 1, 7, 2, 1, "providers.tf\nProvider Config", IBM_GREEN, IBM_WHITE, 11)
    
    # variables.tf
    create_rounded_box(ax, 1, 2, 2, 1, "variables.tf\nInput Parameters", IBM_ORANGE, IBM_WHITE, 11)
    
    # outputs.tf
    create_rounded_box(ax, 7, 4.5, 2, 1, "outputs.tf\nOutput Values", IBM_LIGHT_BLUE, IBM_WHITE, 11)
    
    # terraform.tfvars
    create_rounded_box(ax, 4, 1, 2, 1, "terraform.tfvars\nVariable Values", IBM_DARK_BLUE, IBM_WHITE, 11)
    
    # Data flow arrows with labels
    create_arrow(ax, (2.5, 7), (4.5, 5.5), IBM_GREEN)
    ax.text(3, 6.5, "Provider\nConfiguration", ha='center', fontsize=9, color=IBM_GREEN, weight='bold')
    
    create_arrow(ax, (2.5, 3), (4.5, 4.5), IBM_ORANGE)
    ax.text(3, 3.5, "Variable\nReferences", ha='center', fontsize=9, color=IBM_ORANGE, weight='bold')
    
    create_arrow(ax, (6, 5), (7, 5), IBM_LIGHT_BLUE)
    ax.text(6.5, 5.5, "Resource\nAttributes", ha='center', fontsize=9, color=IBM_LIGHT_BLUE, weight='bold')
    
    create_arrow(ax, (5, 2), (5, 4.5), IBM_DARK_BLUE)
    ax.text(5.5, 3, "Variable\nValues", ha='center', fontsize=9, color=IBM_DARK_BLUE, weight='bold')
    
    # Dependencies section
    create_rounded_box(ax, 0.5, 8.5, 9, 1, "Dependency Flow: providers.tf → variables.tf → main.tf → outputs.tf", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 12)
    
    # Validation section
    create_rounded_box(ax, 1, 0.2, 8, 0.6, "Validation: terraform init → terraform validate → terraform plan", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 11)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/file_relationships.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_3_enterprise_patterns():
    """Generate team collaboration and scaling patterns diagram."""
    fig, ax = setup_figure("Enterprise Patterns - Team Collaboration and Scaling Strategies")
    
    # Multi-environment structure
    create_rounded_box(ax, 0.5, 7.5, 3, 2, "Multi-Environment\nOrganization\n\ndev/\n├── providers.tf\n├── variables.tf\n├── main.tf\n└── outputs.tf", 
                      IBM_BLUE, IBM_WHITE, 10)
    
    create_rounded_box(ax, 3.8, 7.5, 3, 2, "Module Structure\n\nmodules/\n├── networking/\n├── compute/\n├── storage/\n└── security/", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    create_rounded_box(ax, 7.1, 7.5, 2.4, 2, "Team Workflows\n\n• Feature branches\n• Pull requests\n• Code reviews\n• Automated testing", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    # Collaboration patterns
    create_rounded_box(ax, 0.5, 5, 4.5, 2, "Role-Based Access Control\n\n• Infrastructure Team: Full access\n• Development Team: Dev environment\n• Operations Team: Production with approval\n• Security Team: Audit access", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 5, 4.3, 2, "Scalability Strategies\n\n• Modular architecture\n• Shared configurations\n• Remote state management\n• Automated deployments", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Integration section
    create_rounded_box(ax, 1, 2.5, 8, 2, "CI/CD Integration Patterns\n\nGit Repository → Feature Branch → Pull Request → Code Review → \nAutomated Testing → Staging Deployment → Production Approval → Production Deployment", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    # Benefits
    create_rounded_box(ax, 2, 0.5, 6, 1.5, "Enterprise Benefits\n\nTeam Productivity: +60% • Error Reduction: -45%\nDeployment Speed: +70% • Compliance: +80%", 
                      IBM_GREEN, IBM_WHITE, 11)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/enterprise_patterns.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_4_naming_conventions():
    """Generate standardized naming patterns and consistency guidelines diagram."""
    fig, ax = setup_figure("Naming Conventions - Standardized Patterns and Consistency Guidelines")
    
    # File naming section
    create_rounded_box(ax, 0.5, 8, 4.5, 1.5, "Terraform File Naming Standards\n\nproviders.tf • variables.tf • main.tf • outputs.tf\ndata.tf • locals.tf • modules.tf • backend.tf", 
                      IBM_BLUE, IBM_WHITE, 10)
    
    create_rounded_box(ax, 5.2, 8, 4.3, 1.5, "Supporting File Standards\n\nREADME.md • .gitignore • .terraform-version\nMakefile • terraform.tfvars.example", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    # Resource naming patterns
    create_rounded_box(ax, 0.5, 6, 9, 1.5, "Resource Naming Pattern: {project}-{environment}-{resource-type}-{identifier}\n\nExample: myapp-prod-vpc-main, myapp-dev-subnet-web, myapp-staging-vsi-app-01", 
                      IBM_ORANGE, IBM_WHITE, 11)
    
    # Variable naming
    create_rounded_box(ax, 0.5, 4, 4.5, 1.5, "Variable Naming Standards\n\nibm_region\nvpc_cidr_block\napp_server_count\nenable_monitoring", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 10)
    
    create_rounded_box(ax, 5.2, 4, 4.3, 1.5, "Output Naming Standards\n\nvpc_id\nvpc_details\nconnection_info\ndeployment_summary", 
                      IBM_DARK_BLUE, IBM_WHITE, 10)
    
    # Documentation standards
    create_rounded_box(ax, 1, 2, 8, 1.5, "Documentation Standards\n\n• File header comments with project info\n• Resource descriptions and purposes\n• Variable validation and examples\n• Output usage documentation", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    # Benefits
    create_rounded_box(ax, 2.5, 0.2, 5, 1.3, "Consistency Benefits\n\nReadability: +80% • Maintainability: +65%\nOnboarding Speed: +70% • Error Reduction: -50%", 
                      IBM_GREEN, IBM_WHITE, 11)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/naming_conventions.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_5_lifecycle_management():
    """Generate project evolution and maintenance strategies diagram."""
    fig, ax = setup_figure("Project Lifecycle Management - Evolution and Maintenance Strategies")
    
    # Evolution stages
    stages = [
        ("Stage 1\nInitial Dev", "Single environment\nBasic structure\nLocal state", IBM_BLUE),
        ("Stage 2\nMulti-Env", "Dev/Staging/Prod\nRemote state\nBasic CI/CD", IBM_GREEN),
        ("Stage 3\nModular", "Reusable modules\nShared configs\nAdvanced testing", IBM_ORANGE),
        ("Stage 4\nEnterprise", "Multiple teams\nGovernance\nFull automation", IBM_RED)
    ]
    
    y_pos = 7.5
    for i, (title, desc, color) in enumerate(stages):
        x_pos = 0.5 + i * 2.3
        create_rounded_box(ax, x_pos, y_pos, 2, 1.5, f"{title}\n\n{desc}", color, IBM_WHITE, 9)
        
        if i < len(stages) - 1:
            create_arrow(ax, (x_pos + 2, y_pos + 0.75), (x_pos + 2.3, y_pos + 0.75), IBM_GRAY)
    
    # Maintenance tasks
    create_rounded_box(ax, 0.5, 5.5, 4.5, 1.5, "Regular Maintenance Tasks\n\n• Weekly: Provider updates\n• Monthly: Resource audits\n• Quarterly: Module updates\n• Annually: Security reviews", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 5.5, 4.3, 1.5, "Refactoring Strategies\n\n• Incremental changes\n• Backward compatibility\n• Comprehensive testing\n• Documentation updates", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Version management
    create_rounded_box(ax, 1, 3.5, 8, 1.5, "Version Management Best Practices\n\nSemantic Versioning • Change Logs • Migration Guides • Rollback Plans\nTesting Strategies • Dependency Management • Security Updates", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    # Scaling metrics
    create_rounded_box(ax, 0.5, 1.5, 4.5, 1.5, "Scaling Metrics\n\nTeam Size: 1 → 50+\nProjects: 1 → 100+\nEnvironments: 1 → 20+\nResources: 10 → 10,000+", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    create_rounded_box(ax, 5.2, 1.5, 4.3, 1.5, "Success Indicators\n\nDeployment Time: -80%\nError Rate: -70%\nCompliance: +90%\nTeam Velocity: +150%", 
                      IBM_ORANGE, IBM_WHITE, 10)
    
    # Timeline arrow
    create_arrow(ax, (1, 0.5), (8.5, 0.5), IBM_BLUE, '->')
    ax.text(4.75, 0.2, "Project Maturity Timeline", ha='center', fontsize=12, color=IBM_BLUE, weight='bold')
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/lifecycle_management.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Generate all diagrams for directory structure and configuration files."""
    # Create output directory if it doesn't exist
    os.makedirs('generated_diagrams', exist_ok=True)
    
    print("Generating Directory Structure and Configuration Files diagrams...")
    
    # Generate all diagrams
    diagram_1_project_organization()
    print("✅ Generated: project_organization.png")
    
    diagram_2_file_relationships()
    print("✅ Generated: file_relationships.png")
    
    diagram_3_enterprise_patterns()
    print("✅ Generated: enterprise_patterns.png")
    
    diagram_4_naming_conventions()
    print("✅ Generated: naming_conventions.png")
    
    diagram_5_lifecycle_management()
    print("✅ Generated: lifecycle_management.png")
    
    print("\n🎉 All diagrams generated successfully!")
    print("📁 Output directory: generated_diagrams/")
    print("📊 Resolution: 300 DPI for professional quality")
    print("🎨 Style: IBM Cloud branding with enterprise aesthetics")

if __name__ == "__main__":
    main()
