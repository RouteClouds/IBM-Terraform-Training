#!/usr/bin/env python3
"""
Professional Diagram Generation for Configuration Organization
Generates 5 high-quality diagrams (300 DPI) for Terraform configuration organization concepts
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import seaborn as sns
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import os

# IBM Brand Colors
IBM_COLORS = {
    'blue': '#0f62fe',
    'dark_blue': '#002d9c',
    'light_blue': '#4589ff',
    'gray': '#525252',
    'light_gray': '#f4f4f4',
    'white': '#ffffff',
    'green': '#24a148',
    'yellow': '#f1c21b',
    'red': '#da1e28',
    'purple': '#8a3ffc'
}

# Set style
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette([IBM_COLORS['blue'], IBM_COLORS['green'], IBM_COLORS['yellow'], 
                IBM_COLORS['red'], IBM_COLORS['purple']])

def setup_figure(figsize=(16, 12)):
    """Setup figure with IBM styling"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_facecolor(IBM_COLORS['white'])
    fig.patch.set_facecolor(IBM_COLORS['white'])
    return fig, ax

def add_title_and_branding(ax, title, subtitle=""):
    """Add title and IBM branding"""
    ax.text(0.02, 0.98, title, transform=ax.transAxes, fontsize=20, 
            fontweight='bold', color=IBM_COLORS['dark_blue'], va='top')
    if subtitle:
        ax.text(0.02, 0.94, subtitle, transform=ax.transAxes, fontsize=14, 
                color=IBM_COLORS['gray'], va='top')
    
    # IBM branding
    ax.text(0.98, 0.02, 'IBM Cloud Terraform Training', transform=ax.transAxes, 
            fontsize=10, color=IBM_COLORS['gray'], ha='right', va='bottom')

def create_rounded_box(ax, x, y, width, height, text, color, text_color='white'):
    """Create a rounded rectangle with text"""
    box = FancyBboxPatch((x, y), width, height, boxstyle="round,pad=0.02",
                         facecolor=color, edgecolor=IBM_COLORS['gray'], linewidth=1)
    ax.add_patch(box)
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=10, color=text_color, fontweight='bold', wrap=True)

def diagram_1_configuration_challenges():
    """Figure 5.6: Configuration Organization Challenges and Solutions"""
    fig, ax = setup_figure()
    add_title_and_branding(ax, "Configuration Organization Challenges at Scale",
                          "Complexity growth patterns and enterprise solutions")
    
    # Challenge side (left)
    ax.text(0.25, 0.9, "CHALLENGES", ha='center', fontsize=16, fontweight='bold', 
            color=IBM_COLORS['red'])
    
    challenges = [
        ("File Proliferation", "50+ configuration files\nDifficult to navigate", 0.05, 0.75),
        ("Team Coordination", "Multiple teams\nConflicting changes", 0.05, 0.6),
        ("Environment Drift", "Inconsistent configs\nManual variations", 0.05, 0.45),
        ("Maintenance Overhead", "Complex dependencies\nRefactoring challenges", 0.05, 0.3),
        ("Governance Gaps", "No standardization\nCompliance issues", 0.05, 0.15)
    ]
    
    for title, desc, x, y in challenges:
        create_rounded_box(ax, x, y, 0.4, 0.1, f"{title}\n{desc}", 
                          IBM_COLORS['red'], 'white')
    
    # Solution side (right)
    ax.text(0.75, 0.9, "SOLUTIONS", ha='center', fontsize=16, fontweight='bold', 
            color=IBM_COLORS['green'])
    
    solutions = [
        ("Hierarchical Structure", "Logical organization\nClear separation", 0.55, 0.75),
        ("Team Ownership", "RACI matrix\nClear responsibilities", 0.55, 0.6),
        ("Environment Standards", "Consistent patterns\nAutomated validation", 0.55, 0.45),
        ("Module Composition", "Reusable components\nStandardized interfaces", 0.55, 0.3),
        ("Policy as Code", "Automated governance\nCompliance validation", 0.55, 0.15)
    ]
    
    for title, desc, x, y in solutions:
        create_rounded_box(ax, x, y, 0.4, 0.1, f"{title}\n{desc}", 
                          IBM_COLORS['green'], 'white')
    
    # Arrows showing transformation
    for i in range(5):
        y_pos = 0.8 - i * 0.15
        arrow = patches.FancyArrowPatch((0.46, y_pos), (0.54, y_pos),
                                       arrowstyle='->', mutation_scale=20,
                                       color=IBM_COLORS['blue'], linewidth=2)
        ax.add_patch(arrow)
    
    # Complexity growth chart
    x_vals = np.linspace(0.1, 0.9, 100)
    y_vals = 0.05 + 0.02 * np.exp(x_vals * 3)
    ax.plot(x_vals, y_vals, color=IBM_COLORS['blue'], linewidth=3, alpha=0.7)
    ax.text(0.5, 0.08, "Complexity Growth Without Organization", ha='center', 
            fontsize=12, color=IBM_COLORS['blue'])
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/06_configuration_organization_challenges.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def diagram_2_hierarchical_patterns():
    """Figure 5.7: Hierarchical Configuration Patterns"""
    fig, ax = setup_figure()
    add_title_and_branding(ax, "Hierarchical Configuration Patterns",
                          "Dependency layers and enterprise governance structures")
    
    # Layer structure
    layers = [
        ("Governance Layer", "Policies • Compliance • Standards", 0.1, 0.85, IBM_COLORS['purple']),
        ("Environment Layer", "Development • Staging • Production", 0.1, 0.7, IBM_COLORS['blue']),
        ("Platform Layer", "Containers • Data • API Gateway", 0.1, 0.55, IBM_COLORS['green']),
        ("Foundation Layer", "Networking • Security • Monitoring", 0.1, 0.4, IBM_COLORS['yellow']),
        ("Infrastructure Layer", "Compute • Storage • Database", 0.1, 0.25, IBM_COLORS['red'])
    ]
    
    for name, components, x, y, color in layers:
        create_rounded_box(ax, x, y, 0.35, 0.1, f"{name}\n{components}", color, 'white')
    
    # Dependencies arrows
    for i in range(len(layers) - 1):
        y_start = 0.9 - i * 0.15
        y_end = y_start - 0.15
        arrow = patches.FancyArrowPatch((0.275, y_start - 0.02), (0.275, y_end + 0.08),
                                       arrowstyle='->', mutation_scale=15,
                                       color=IBM_COLORS['gray'], linewidth=2)
        ax.add_patch(arrow)
    
    # Module composition example
    ax.text(0.65, 0.9, "Module Composition Example", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    # VPC Module breakdown
    vpc_components = [
        ("VPC Module", 0.55, 0.75, 0.2, 0.08, IBM_COLORS['blue']),
        ("Subnets", 0.5, 0.65, 0.12, 0.06, IBM_COLORS['light_blue']),
        ("Security Groups", 0.63, 0.65, 0.12, 0.06, IBM_COLORS['light_blue']),
        ("Public Gateway", 0.5, 0.57, 0.12, 0.06, IBM_COLORS['light_blue']),
        ("Flow Logs", 0.63, 0.57, 0.12, 0.06, IBM_COLORS['light_blue'])
    ]
    
    for name, x, y, w, h, color in vpc_components:
        create_rounded_box(ax, x, y, w, h, name, color, 'white')
    
    # Composition arrows
    for i in range(1, len(vpc_components)):
        _, x, y, w, h, _ = vpc_components[i]
        arrow = patches.FancyArrowPatch((0.65, 0.75), (x + w/2, y + h),
                                       arrowstyle='->', mutation_scale=10,
                                       color=IBM_COLORS['gray'], linewidth=1)
        ax.add_patch(arrow)
    
    # Environment inheritance
    ax.text(0.65, 0.45, "Environment Inheritance", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    env_hierarchy = [
        ("Global Config", 0.6, 0.38, IBM_COLORS['purple']),
        ("Regional Config", 0.6, 0.32, IBM_COLORS['blue']),
        ("Environment Config", 0.6, 0.26, IBM_COLORS['green']),
        ("Application Config", 0.6, 0.2, IBM_COLORS['yellow'])
    ]
    
    for name, x, y, color in env_hierarchy:
        create_rounded_box(ax, x, y, 0.15, 0.05, name, color, 'white')
    
    # Inheritance arrows
    for i in range(len(env_hierarchy) - 1):
        y_start = 0.405 - i * 0.06
        y_end = y_start - 0.06
        arrow = patches.FancyArrowPatch((0.675, y_start - 0.01), (0.675, y_end + 0.04),
                                       arrowstyle='->', mutation_scale=10,
                                       color=IBM_COLORS['gray'], linewidth=1)
        ax.add_patch(arrow)
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/07_hierarchical_configuration_patterns.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def diagram_3_naming_conventions():
    """Figure 5.8: Enterprise Naming Conventions"""
    fig, ax = setup_figure()
    add_title_and_branding(ax, "Enterprise Naming Conventions",
                          "Standardized patterns with consistency validation")
    
    # Naming pattern structure
    ax.text(0.5, 0.9, "Naming Convention Structure", ha='center', fontsize=16, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    # Pattern components
    components = [
        ("Organization", "acme", 0.1, 0.8, IBM_COLORS['purple']),
        ("Environment", "prod", 0.25, 0.8, IBM_COLORS['blue']),
        ("Service", "vpc", 0.4, 0.8, IBM_COLORS['green']),
        ("Purpose", "main", 0.55, 0.8, IBM_COLORS['yellow']),
        ("Instance", "001", 0.7, 0.8, IBM_COLORS['red'])
    ]
    
    for name, example, x, y, color in components:
        create_rounded_box(ax, x, y, 0.12, 0.08, f"{name}\n{example}", color, 'white')
    
    # Separators
    for i in range(len(components) - 1):
        x_pos = 0.22 + i * 0.15
        ax.text(x_pos, 0.84, "-", ha='center', va='center', fontsize=20, 
                color=IBM_COLORS['gray'], fontweight='bold')
    
    # Result
    ax.text(0.5, 0.7, "Result: acme-prod-vpc-main-001", ha='center', fontsize=18, 
            fontweight='bold', color=IBM_COLORS['dark_blue'],
            bbox=dict(boxstyle="round,pad=0.5", facecolor=IBM_COLORS['light_gray']))
    
    # Validation rules
    ax.text(0.25, 0.6, "Validation Rules", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    rules = [
        "✓ Lowercase only",
        "✓ Start with letter",
        "✓ Alphanumeric + hyphens",
        "✓ Max 63 characters",
        "✓ No consecutive hyphens"
    ]
    
    for i, rule in enumerate(rules):
        ax.text(0.05, 0.52 - i * 0.04, rule, fontsize=11, color=IBM_COLORS['green'])
    
    # Tag structure
    ax.text(0.75, 0.6, "Standard Tags", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    tags = [
        ("Organization", "ACME Corporation"),
        ("Environment", "production"),
        ("CostCenter", "CC-PROD-001"),
        ("Owner", "platform-team"),
        ("ManagedBy", "terraform")
    ]
    
    for i, (key, value) in enumerate(tags):
        y_pos = 0.52 - i * 0.04
        ax.text(0.55, y_pos, f"{key}:", fontsize=10, color=IBM_COLORS['gray'], fontweight='bold')
        ax.text(0.7, y_pos, value, fontsize=10, color=IBM_COLORS['blue'])
    
    # Consistency metrics
    ax.text(0.5, 0.25, "Consistency Validation", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    # Pie chart for consistency
    sizes = [95, 5]
    labels = ['Compliant', 'Non-compliant']
    colors = [IBM_COLORS['green'], IBM_COLORS['red']]
    
    pie_ax = fig.add_axes([0.4, 0.05, 0.2, 0.15])
    pie_ax.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', startangle=90)
    pie_ax.set_title('Naming Compliance', fontsize=12, color=IBM_COLORS['dark_blue'])
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/08_enterprise_naming_conventions.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def diagram_4_validation_workflows():
    """Figure 5.9: Configuration Validation Workflows"""
    fig, ax = setup_figure()
    add_title_and_branding(ax, "Configuration Validation Workflows",
                          "Multi-stage validation and quality gates")
    
    # Validation pipeline stages
    stages = [
        ("Developer\nWorkstation", 0.05, 0.7, IBM_COLORS['blue']),
        ("Git\nRepository", 0.2, 0.7, IBM_COLORS['green']),
        ("CI/CD\nPipeline", 0.35, 0.7, IBM_COLORS['yellow']),
        ("Policy\nValidation", 0.5, 0.7, IBM_COLORS['purple']),
        ("Deployment\nGate", 0.65, 0.7, IBM_COLORS['red']),
        ("Production\nMonitoring", 0.8, 0.7, IBM_COLORS['dark_blue'])
    ]
    
    for name, x, y, color in stages:
        create_rounded_box(ax, x, y, 0.12, 0.1, name, color, 'white')
    
    # Flow arrows
    for i in range(len(stages) - 1):
        x_start = 0.17 + i * 0.15
        x_end = x_start + 0.03
        arrow = patches.FancyArrowPatch((x_start, 0.75), (x_end, 0.75),
                                       arrowstyle='->', mutation_scale=15,
                                       color=IBM_COLORS['gray'], linewidth=2)
        ax.add_patch(arrow)
    
    # Validation checks for each stage
    validations = [
        ("• terraform fmt\n• terraform validate\n• Local testing", 0.05, 0.55),
        ("• Branch protection\n• Code review\n• Merge checks", 0.2, 0.55),
        ("• Syntax validation\n• Security scan\n• Cost estimation", 0.35, 0.55),
        ("• Policy compliance\n• Resource limits\n• Governance rules", 0.5, 0.55),
        ("• Approval workflow\n• Change management\n• Risk assessment", 0.65, 0.55),
        ("• Health checks\n• Performance\n• Compliance audit", 0.8, 0.55)
    ]
    
    for checks, x, y in validations:
        ax.text(x + 0.06, y, checks, ha='center', va='top', fontsize=9, 
                color=IBM_COLORS['gray'])
    
    # Quality gates
    ax.text(0.5, 0.4, "Quality Gates", ha='center', fontsize=16, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    gates = [
        ("Syntax Gate", "terraform validate\nTFLint checks", 0.15, 0.3, IBM_COLORS['green']),
        ("Security Gate", "TFSec scan\nCompliance check", 0.4, 0.3, IBM_COLORS['yellow']),
        ("Cost Gate", "Budget validation\nCost estimation", 0.65, 0.3, IBM_COLORS['red'])
    ]
    
    for name, desc, x, y, color in gates:
        create_rounded_box(ax, x, y, 0.18, 0.08, f"{name}\n{desc}", color, 'white')
    
    # Feedback loops
    feedback_arrows = [
        ((0.11, 0.7), (0.11, 0.6)),
        ((0.26, 0.7), (0.26, 0.6)),
        ((0.41, 0.7), (0.41, 0.6))
    ]
    
    for start, end in feedback_arrows:
        arrow = patches.FancyArrowPatch(start, end, arrowstyle='<->', 
                                       mutation_scale=10, color=IBM_COLORS['blue'], 
                                       linewidth=1, alpha=0.7)
        ax.add_patch(arrow)
    
    # Metrics dashboard
    ax.text(0.5, 0.15, "Validation Metrics", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    metrics = [
        "Pass Rate: 94%", "Avg Time: 3.2 min", "Issues Found: 12",
        "Security Score: 98%", "Cost Compliance: 100%", "Policy Violations: 0"
    ]
    
    for i, metric in enumerate(metrics):
        x_pos = 0.15 + (i % 3) * 0.25
        y_pos = 0.08 if i < 3 else 0.04
        ax.text(x_pos, y_pos, metric, ha='center', fontsize=10, 
                color=IBM_COLORS['blue'], fontweight='bold')
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/09_configuration_validation_workflows.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def diagram_5_team_collaboration():
    """Figure 5.10: Team Collaboration and Governance"""
    fig, ax = setup_figure()
    add_title_and_branding(ax, "Team Collaboration and Governance",
                          "Ownership matrices and integration patterns")
    
    # RACI Matrix
    ax.text(0.3, 0.9, "RACI Responsibility Matrix", ha='center', fontsize=16, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    # Matrix headers
    teams = ["Platform", "App Team 1", "App Team 2", "Security"]
    components = ["Foundation", "Networking", "Security", "Applications", "Policies"]
    
    # Draw matrix
    matrix_data = [
        ["R,A", "C", "C", "I"],      # Foundation
        ["R,A", "C", "C", "C"],      # Networking
        ["C", "I", "I", "R,A"],      # Security
        ["I", "R,A", "R,A", "C"],    # Applications
        ["C", "I", "I", "R,A"]       # Policies
    ]
    
    # Headers
    for i, team in enumerate(teams):
        ax.text(0.15 + i * 0.08, 0.82, team, ha='center', fontsize=10, 
                fontweight='bold', color=IBM_COLORS['blue'], rotation=45)
    
    for i, component in enumerate(components):
        ax.text(0.05, 0.78 - i * 0.04, component, ha='left', fontsize=10, 
                fontweight='bold', color=IBM_COLORS['blue'])
    
    # Matrix cells
    for i, row in enumerate(matrix_data):
        for j, cell in enumerate(row):
            color = IBM_COLORS['green'] if 'R' in cell else IBM_COLORS['light_gray']
            rect = patches.Rectangle((0.12 + j * 0.08, 0.76 - i * 0.04), 
                                   0.07, 0.03, facecolor=color, alpha=0.7)
            ax.add_patch(rect)
            ax.text(0.155 + j * 0.08, 0.775 - i * 0.04, cell, ha='center', 
                   va='center', fontsize=8, fontweight='bold')
    
    # Legend
    ax.text(0.05, 0.55, "R: Responsible  A: Accountable  C: Consulted  I: Informed", 
            fontsize=10, color=IBM_COLORS['gray'])
    
    # Workflow diagram
    ax.text(0.7, 0.9, "Change Management Workflow", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    workflow_steps = [
        ("Feature\nBranch", 0.6, 0.8, IBM_COLORS['blue']),
        ("Code\nReview", 0.6, 0.7, IBM_COLORS['green']),
        ("Validation\nPipeline", 0.6, 0.6, IBM_COLORS['yellow']),
        ("Approval\nGate", 0.6, 0.5, IBM_COLORS['purple']),
        ("Merge to\nMain", 0.6, 0.4, IBM_COLORS['red'])
    ]
    
    for name, x, y, color in workflow_steps:
        create_rounded_box(ax, x, y, 0.12, 0.06, name, color, 'white')
    
    # Workflow arrows
    for i in range(len(workflow_steps) - 1):
        y_start = 0.83 - i * 0.1
        y_end = y_start - 0.1
        arrow = patches.FancyArrowPatch((0.66, y_start - 0.01), (0.66, y_end + 0.05),
                                       arrowstyle='->', mutation_scale=12,
                                       color=IBM_COLORS['gray'], linewidth=2)
        ax.add_patch(arrow)
    
    # Integration patterns
    ax.text(0.85, 0.8, "Integration\nPatterns", ha='center', fontsize=12, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    patterns = [
        ("Module\nRegistry", 0.8, 0.7, IBM_COLORS['blue']),
        ("Shared\nPolicies", 0.8, 0.6, IBM_COLORS['green']),
        ("Common\nTemplates", 0.8, 0.5, IBM_COLORS['yellow'])
    ]
    
    for name, x, y, color in patterns:
        create_rounded_box(ax, x, y, 0.1, 0.05, name, color, 'white')
    
    # Team communication
    ax.text(0.3, 0.3, "Communication Channels", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    channels = [
        ("Daily Standups", "Team coordination", 0.05, 0.22),
        ("Architecture Reviews", "Design decisions", 0.25, 0.22),
        ("Security Reviews", "Compliance validation", 0.45, 0.22)
    ]
    
    for title, desc, x, y in channels:
        create_rounded_box(ax, x, y, 0.15, 0.06, f"{title}\n{desc}", 
                          IBM_COLORS['light_blue'], 'white')
    
    # Governance metrics
    ax.text(0.3, 0.1, "Governance Metrics", ha='center', fontsize=14, 
            fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    metrics_text = "Code Review Coverage: 100% • Policy Compliance: 98% • Change Success Rate: 96%"
    ax.text(0.3, 0.05, metrics_text, ha='center', fontsize=10, 
            color=IBM_COLORS['blue'])
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/10_team_collaboration_governance.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def main():
    """Generate all configuration organization diagrams"""
    # Create output directory
    os.makedirs('generated_diagrams', exist_ok=True)
    
    print("Generating Configuration Organization Diagrams...")
    
    # Generate all diagrams
    diagram_1_configuration_challenges()
    print("✓ Generated Figure 5.6: Configuration Organization Challenges")
    
    diagram_2_hierarchical_patterns()
    print("✓ Generated Figure 5.7: Hierarchical Configuration Patterns")
    
    diagram_3_naming_conventions()
    print("✓ Generated Figure 5.8: Enterprise Naming Conventions")
    
    diagram_4_validation_workflows()
    print("✓ Generated Figure 5.9: Configuration Validation Workflows")
    
    diagram_5_team_collaboration()
    print("✓ Generated Figure 5.10: Team Collaboration and Governance")
    
    # Calculate total file size
    total_size = 0
    for filename in os.listdir('generated_diagrams'):
        if filename.endswith('.png'):
            filepath = os.path.join('generated_diagrams', filename)
            total_size += os.path.getsize(filepath)
    
    print(f"\n📊 Generation Summary:")
    print(f"   • Total diagrams: 5")
    print(f"   • Resolution: 300 DPI")
    print(f"   • Total size: {total_size / (1024*1024):.2f} MB")
    print(f"   • Output directory: generated_diagrams/")
    print(f"   • Status: ✅ All diagrams generated successfully")

if __name__ == "__main__":
    main()
