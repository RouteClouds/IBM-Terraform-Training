#!/usr/bin/env python3
"""
Terraform State Management Diagrams Generator
Subtopic 6.1: Local and Remote State Files

This script generates 5 professional diagrams for state management education:
1. State Lifecycle Overview
2. Local vs Remote State Comparison
3. IBM COS Backend Architecture
4. State Migration Workflow
5. Team Collaboration Model

All diagrams are generated at 300 DPI with IBM brand compliance.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Rectangle, Arrow
import numpy as np
import os

# IBM Brand Colors
IBM_BLUE = '#1261FE'
IBM_DARK_BLUE = '#0F62FE'
IBM_LIGHT_BLUE = '#4589FF'
IBM_GRAY = '#525252'
IBM_LIGHT_GRAY = '#F4F4F4'
IBM_GREEN = '#24A148'
IBM_ORANGE = '#FF832B'
IBM_RED = '#DA1E28'
IBM_PURPLE = '#8A3FFC'

# Create output directory
os.makedirs('generated_diagrams', exist_ok=True)

def setup_diagram_style():
    """Setup consistent diagram styling"""
    plt.style.use('default')
    return {
        'title_size': 16,
        'label_size': 12,
        'text_size': 10,
        'small_text': 8,
        'line_width': 2,
        'dpi': 300
    }

def create_figure(title, figsize=(14, 10)):
    """Create a new figure with consistent styling"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Add title
    fig.suptitle(title, fontsize=16, fontweight='bold', y=0.95)
    
    return fig, ax

def add_ibm_branding(ax):
    """Add IBM branding elements to diagram"""
    # IBM logo placeholder
    logo_rect = Rectangle((0.2, 11.2), 1.5, 0.6, facecolor=IBM_BLUE, alpha=0.8)
    ax.add_patch(logo_rect)
    ax.text(0.95, 11.5, 'IBM', fontsize=12, fontweight='bold', 
            color='white', ha='center', va='center')

def diagram_1_state_lifecycle():
    """Figure 6.1.1: Terraform State Lifecycle Overview"""
    fig, ax = create_figure('Figure 6.1.1: Terraform State Lifecycle Overview')
    style = setup_diagram_style()
    
    # Lifecycle stages
    stages = [
        (2, 9, 'Init', 'terraform init'),
        (5, 9, 'Plan', 'terraform plan'),
        (8, 9, 'Apply', 'terraform apply'),
        (11, 9, 'State Update', 'State Modified'),
        (14, 9, 'Validation', 'Integrity Check')
    ]
    
    # Draw lifecycle flow
    for i, (x, y, title, desc) in enumerate(stages):
        # Stage circle
        circle = Circle((x, y), 0.8, facecolor=IBM_BLUE, alpha=0.8, edgecolor=IBM_DARK_BLUE)
        ax.add_patch(circle)
        ax.text(x, y + 0.1, title, fontsize=style['text_size'], fontweight='bold',
                ha='center', va='center', color='white')
        ax.text(x, y - 0.3, desc, fontsize=style['small_text'],
                ha='center', va='center', color='white')
        
        # Arrow to next stage
        if i < len(stages) - 1:
            arrow = patches.FancyArrowPatch((x + 0.8, y), (stages[i+1][0] - 0.8, y),
                                          arrowstyle='->', mutation_scale=20,
                                          color=IBM_GRAY, linewidth=2)
            ax.add_patch(arrow)
    
    # State file representation
    state_rect = FancyBboxPatch((6, 6), 4, 2, boxstyle="round,pad=0.1",
                               facecolor=IBM_LIGHT_GRAY, edgecolor=IBM_GRAY, linewidth=2)
    ax.add_patch(state_rect)
    ax.text(8, 7.2, 'terraform.tfstate', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center')
    ax.text(8, 6.8, 'Resource Mapping', fontsize=style['text_size'], ha='center', va='center')
    ax.text(8, 6.4, 'Metadata & Dependencies', fontsize=style['text_size'], ha='center', va='center')
    
    # Storage options
    local_rect = FancyBboxPatch((2, 3), 3, 1.5, boxstyle="round,pad=0.1",
                               facecolor=IBM_ORANGE, alpha=0.7, edgecolor=IBM_ORANGE)
    ax.add_patch(local_rect)
    ax.text(3.5, 3.75, 'Local Storage', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    remote_rect = FancyBboxPatch((11, 3), 3, 1.5, boxstyle="round,pad=0.1",
                                facecolor=IBM_GREEN, alpha=0.7, edgecolor=IBM_GREEN)
    ax.add_patch(remote_rect)
    ax.text(12.5, 3.75, 'Remote Storage', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    # IBM Cloud services integration
    services_y = 1
    services = ['Object Storage', 'Activity Tracker', 'Key Protect']
    for i, service in enumerate(services):
        service_rect = Rectangle((4 + i * 2.5, services_y), 2, 0.8,
                               facecolor=IBM_LIGHT_BLUE, alpha=0.8, edgecolor=IBM_BLUE)
        ax.add_patch(service_rect)
        ax.text(5 + i * 2.5, services_y + 0.4, service, fontsize=style['small_text'],
                ha='center', va='center', color='white', fontweight='bold')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_1_1_state_lifecycle.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_2_local_vs_remote():
    """Figure 6.1.2: Local vs Remote State Architecture Comparison"""
    fig, ax = create_figure('Figure 6.1.2: Local vs Remote State Architecture Comparison')
    style = setup_diagram_style()
    
    # Local state side (left)
    local_title = Rectangle((1, 10), 6, 1, facecolor=IBM_ORANGE, alpha=0.8)
    ax.add_patch(local_title)
    ax.text(4, 10.5, 'LOCAL STATE', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    # Local state components
    local_components = [
        (2, 8.5, 'Single Developer', 'Individual Access'),
        (2, 7.5, 'File System', 'Local Storage'),
        (2, 6.5, 'No Locking', 'Conflict Risk'),
        (2, 5.5, 'Manual Backup', 'User Responsibility'),
        (2, 4.5, 'No Encryption', 'Security Risk')
    ]
    
    for x, y, title, desc in local_components:
        comp_rect = FancyBboxPatch((x - 0.8, y - 0.3), 3.6, 0.6, boxstyle="round,pad=0.05",
                                  facecolor=IBM_LIGHT_GRAY, edgecolor=IBM_GRAY)
        ax.add_patch(comp_rect)
        ax.text(x, y + 0.1, title, fontsize=style['text_size'], fontweight='bold', ha='left')
        ax.text(x, y - 0.1, desc, fontsize=style['small_text'], ha='left', color=IBM_GRAY)
    
    # Remote state side (right)
    remote_title = Rectangle((9, 10), 6, 1, facecolor=IBM_GREEN, alpha=0.8)
    ax.add_patch(remote_title)
    ax.text(12, 10.5, 'REMOTE STATE', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    # Remote state components
    remote_components = [
        (10, 8.5, 'Team Collaboration', 'Multi-user Access'),
        (10, 7.5, 'IBM Cloud COS', 'S3-Compatible'),
        (10, 6.5, 'State Locking', 'Conflict Prevention'),
        (10, 5.5, 'Auto Backup', 'Versioning & Recovery'),
        (10, 4.5, 'Encryption', 'Key Protect Integration')
    ]
    
    for x, y, title, desc in remote_components:
        comp_rect = FancyBboxPatch((x - 0.8, y - 0.3), 3.6, 0.6, boxstyle="round,pad=0.05",
                                  facecolor=IBM_LIGHT_BLUE, alpha=0.3, edgecolor=IBM_BLUE)
        ax.add_patch(comp_rect)
        ax.text(x, y + 0.1, title, fontsize=style['text_size'], fontweight='bold', ha='left')
        ax.text(x, y - 0.1, desc, fontsize=style['small_text'], ha='left', color=IBM_BLUE)
    
    # Migration arrow
    migration_arrow = patches.FancyArrowPatch((7, 6), (9, 6),
                                            arrowstyle='->', mutation_scale=30,
                                            color=IBM_PURPLE, linewidth=3)
    ax.add_patch(migration_arrow)
    ax.text(8, 6.5, 'MIGRATE', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color=IBM_PURPLE)
    
    # Comparison matrix
    matrix_rect = FancyBboxPatch((3, 1.5), 10, 2, boxstyle="round,pad=0.1",
                                facecolor=IBM_LIGHT_GRAY, alpha=0.3, edgecolor=IBM_GRAY)
    ax.add_patch(matrix_rect)
    ax.text(8, 3, 'COMPARISON MATRIX', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center')
    
    # Matrix content
    matrix_items = [
        'Scalability: Local (❌) vs Remote (✅)',
        'Security: Local (⚠️) vs Remote (✅)',
        'Collaboration: Local (❌) vs Remote (✅)',
        'Backup: Local (Manual) vs Remote (Automated)'
    ]
    
    for i, item in enumerate(matrix_items):
        ax.text(8, 2.6 - i * 0.2, item, fontsize=style['small_text'],
                ha='center', va='center')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_1_2_local_vs_remote.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_3_cos_backend():
    """Figure 6.1.3: IBM Cloud Object Storage Backend Architecture"""
    fig, ax = create_figure('Figure 6.1.3: IBM Cloud Object Storage Backend Architecture')
    style = setup_diagram_style()
    
    # COS Infrastructure layer
    cos_rect = FancyBboxPatch((2, 8), 12, 2.5, boxstyle="round,pad=0.1",
                             facecolor=IBM_BLUE, alpha=0.8, edgecolor=IBM_DARK_BLUE, linewidth=2)
    ax.add_patch(cos_rect)
    ax.text(8, 9.7, 'IBM Cloud Object Storage', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(8, 9.3, 'S3-Compatible API • Global Availability • Enterprise Security',
            fontsize=style['text_size'], ha='center', va='center', color='white')
    
    # Storage buckets
    buckets = [
        (4, 8.5, 'State Bucket', 'terraform.tfstate'),
        (8, 8.5, 'Backup Bucket', 'state-backups'),
        (12, 8.5, 'Audit Bucket', 'activity-logs')
    ]
    
    for x, y, title, desc in buckets:
        bucket_rect = FancyBboxPatch((x - 1, y - 0.4), 2, 0.8, boxstyle="round,pad=0.05",
                                    facecolor='white', alpha=0.9, edgecolor=IBM_BLUE)
        ax.add_patch(bucket_rect)
        ax.text(x, y + 0.1, title, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center')
        ax.text(x, y - 0.1, desc, fontsize=style['small_text'],
                ha='center', va='center', color=IBM_GRAY)
    
    # Security layer
    security_rect = FancyBboxPatch((2, 5.5), 12, 1.5, boxstyle="round,pad=0.1",
                                  facecolor=IBM_GREEN, alpha=0.8, edgecolor=IBM_GREEN, linewidth=2)
    ax.add_patch(security_rect)
    ax.text(8, 6.7, 'SECURITY LAYER', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    # Security components
    security_components = [
        (4, 6, 'Key Protect', 'Encryption'),
        (8, 6, 'IAM', 'Access Control'),
        (12, 6, 'Activity Tracker', 'Audit Logging')
    ]
    
    for x, y, title, desc in security_components:
        sec_rect = FancyBboxPatch((x - 0.8, y - 0.3), 1.6, 0.6, boxstyle="round,pad=0.05",
                                 facecolor='white', alpha=0.9, edgecolor=IBM_GREEN)
        ax.add_patch(sec_rect)
        ax.text(x, y + 0.1, title, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center')
        ax.text(x, y - 0.1, desc, fontsize=style['small_text'],
                ha='center', va='center', color=IBM_GRAY)
    
    # API layer
    api_rect = FancyBboxPatch((2, 3.5), 12, 1, boxstyle="round,pad=0.1",
                             facecolor=IBM_LIGHT_BLUE, alpha=0.8, edgecolor=IBM_BLUE)
    ax.add_patch(api_rect)
    ax.text(8, 4, 'S3-COMPATIBLE API LAYER', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    # Terraform integration
    terraform_rect = FancyBboxPatch((6, 1.5), 4, 1, boxstyle="round,pad=0.1",
                                   facecolor=IBM_PURPLE, alpha=0.8, edgecolor=IBM_PURPLE)
    ax.add_patch(terraform_rect)
    ax.text(8, 2, 'Terraform Backend', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color='white')
    
    # Connection arrows
    arrows = [
        ((8, 1.5), (8, 3.5)),  # Terraform to API
        ((8, 4.5), (8, 5.5)),  # API to Security
        ((8, 7), (8, 8))       # Security to COS
    ]
    
    for start, end in arrows:
        arrow = patches.FancyArrowPatch(start, end, arrowstyle='<->', mutation_scale=15,
                                      color=IBM_GRAY, linewidth=2)
        ax.add_patch(arrow)
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_1_3_cos_backend.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_4_migration_workflow():
    """Figure 6.1.4: State Migration Workflow Process"""
    fig, ax = create_figure('Figure 6.1.4: State Migration Workflow Process')
    style = setup_diagram_style()
    
    # Migration phases
    phases = [
        (2, 9, 'Preparation', IBM_ORANGE, ['Backup State', 'Assess Resources', 'Plan Migration']),
        (6, 9, 'Configuration', IBM_BLUE, ['Setup COS', 'Configure Backend', 'Test Access']),
        (10, 9, 'Migration', IBM_PURPLE, ['Init Backend', 'Migrate State', 'Validate']),
        (14, 9, 'Validation', IBM_GREEN, ['Test Operations', 'Verify Integrity', 'Cleanup'])
    ]
    
    # Draw phases
    for i, (x, y, title, color, steps) in enumerate(phases):
        # Phase header
        phase_rect = FancyBboxPatch((x - 1.5, y - 0.5), 3, 1, boxstyle="round,pad=0.1",
                                   facecolor=color, alpha=0.8, edgecolor=color)
        ax.add_patch(phase_rect)
        ax.text(x, y, title, fontsize=style['text_size'], fontweight='bold',
                ha='center', va='center', color='white')
        
        # Phase steps
        for j, step in enumerate(steps):
            step_y = y - 1.5 - j * 0.8
            step_rect = FancyBboxPatch((x - 1.3, step_y - 0.3), 2.6, 0.6, boxstyle="round,pad=0.05",
                                      facecolor=IBM_LIGHT_GRAY, alpha=0.7, edgecolor=color)
            ax.add_patch(step_rect)
            ax.text(x, step_y, step, fontsize=style['small_text'],
                    ha='center', va='center')
        
        # Arrow to next phase
        if i < len(phases) - 1:
            arrow = patches.FancyArrowPatch((x + 1.5, y), (phases[i+1][0] - 1.5, y),
                                          arrowstyle='->', mutation_scale=20,
                                          color=IBM_GRAY, linewidth=2)
            ax.add_patch(arrow)
    
    # Risk mitigation section
    risk_rect = FancyBboxPatch((2, 3), 12, 2, boxstyle="round,pad=0.1",
                              facecolor=IBM_RED, alpha=0.1, edgecolor=IBM_RED, linewidth=2)
    ax.add_patch(risk_rect)
    ax.text(8, 4.5, 'RISK MITIGATION PROCEDURES', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color=IBM_RED)
    
    # Risk mitigation items
    risk_items = [
        'Comprehensive state backup before migration',
        'Validation checkpoints at each phase',
        'Rollback procedures for migration failure',
        'Team coordination and communication plan'
    ]
    
    for i, item in enumerate(risk_items):
        ax.text(8, 4.1 - i * 0.3, f'• {item}', fontsize=style['small_text'],
                ha='center', va='center')
    
    # Success criteria
    success_rect = FancyBboxPatch((2, 0.5), 12, 1.5, boxstyle="round,pad=0.1",
                                 facecolor=IBM_GREEN, alpha=0.1, edgecolor=IBM_GREEN, linewidth=2)
    ax.add_patch(success_rect)
    ax.text(8, 1.7, 'SUCCESS CRITERIA', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color=IBM_GREEN)
    ax.text(8, 1.3, '✅ All resources migrated  ✅ No configuration drift  ✅ Team access verified',
            fontsize=style['small_text'], ha='center', va='center')
    ax.text(8, 0.9, '✅ Backup procedures tested  ✅ Monitoring operational',
            fontsize=style['small_text'], ha='center', va='center')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_1_4_migration_workflow.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_5_team_collaboration():
    """Figure 6.1.5: Team Collaboration and Access Control Model"""
    fig, ax = create_figure('Figure 6.1.5: Team Collaboration and Access Control Model')
    style = setup_diagram_style()
    
    # Team roles
    roles = [
        (3, 9, 'Developers', IBM_BLUE, 'Read-Only Access'),
        (8, 9, 'Operators', IBM_GREEN, 'Read-Write Access'),
        (13, 9, 'Administrators', IBM_PURPLE, 'Full Control')
    ]
    
    for x, y, role, color, access in roles:
        role_circle = Circle((x, y), 1, facecolor=color, alpha=0.8, edgecolor=color)
        ax.add_patch(role_circle)
        ax.text(x, y + 0.2, role, fontsize=style['text_size'], fontweight='bold',
                ha='center', va='center', color='white')
        ax.text(x, y - 0.2, access, fontsize=style['small_text'],
                ha='center', va='center', color='white')
    
    # Central state management
    state_rect = FancyBboxPatch((6, 5.5), 4, 2, boxstyle="round,pad=0.1",
                               facecolor=IBM_LIGHT_GRAY, alpha=0.8, edgecolor=IBM_GRAY, linewidth=2)
    ax.add_patch(state_rect)
    ax.text(8, 6.8, 'Remote State', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center')
    ax.text(8, 6.4, 'IBM Cloud Object Storage', fontsize=style['text_size'],
            ha='center', va='center')
    ax.text(8, 6, 'Centralized • Secure • Collaborative', fontsize=style['small_text'],
            ha='center', va='center', color=IBM_GRAY)
    
    # Access control arrows
    access_arrows = [
        ((3, 8), (7, 7), 'Plan Only'),
        ((8, 8), (8, 7.5), 'Plan & Apply'),
        ((13, 8), (9, 7), 'Full Admin')
    ]
    
    for start, end, label in access_arrows:
        arrow = patches.FancyArrowPatch(start, end, arrowstyle='->', mutation_scale=15,
                                      color=IBM_GRAY, linewidth=2)
        ax.add_patch(arrow)
        mid_x, mid_y = (start[0] + end[0]) / 2, (start[1] + end[1]) / 2
        ax.text(mid_x, mid_y + 0.3, label, fontsize=style['small_text'],
                ha='center', va='center', color=IBM_GRAY)
    
    # Workflow integration
    workflow_rect = FancyBboxPatch((2, 2.5), 12, 2, boxstyle="round,pad=0.1",
                                  facecolor=IBM_LIGHT_BLUE, alpha=0.3, edgecolor=IBM_BLUE)
    ax.add_patch(workflow_rect)
    ax.text(8, 4, 'WORKFLOW INTEGRATION', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color=IBM_BLUE)
    
    # Workflow steps
    workflow_steps = [
        (4, 3.3, 'Git Pull'),
        (6, 3.3, 'Terraform Plan'),
        (8, 3.3, 'Pull Request'),
        (10, 3.3, 'Review & Approve'),
        (12, 3.3, 'Terraform Apply')
    ]
    
    for i, (x, y, step) in enumerate(workflow_steps):
        step_rect = FancyBboxPatch((x - 0.7, y - 0.2), 1.4, 0.4, boxstyle="round,pad=0.05",
                                  facecolor='white', alpha=0.9, edgecolor=IBM_BLUE)
        ax.add_patch(step_rect)
        ax.text(x, y, step, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center')
        
        if i < len(workflow_steps) - 1:
            arrow = patches.FancyArrowPatch((x + 0.7, y), (workflow_steps[i+1][0] - 0.7, y),
                                          arrowstyle='->', mutation_scale=10,
                                          color=IBM_BLUE, linewidth=1)
            ax.add_patch(arrow)
    
    # Governance framework
    governance_rect = FancyBboxPatch((2, 0.5), 12, 1.5, boxstyle="round,pad=0.1",
                                    facecolor=IBM_GREEN, alpha=0.1, edgecolor=IBM_GREEN)
    ax.add_patch(governance_rect)
    ax.text(8, 1.7, 'GOVERNANCE FRAMEWORK', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color=IBM_GREEN)
    ax.text(8, 1.3, 'Policy Enforcement • Audit Trails • Compliance Monitoring',
            fontsize=style['text_size'], ha='center', va='center')
    ax.text(8, 0.9, 'Automated Backup • Change Tracking • Security Controls',
            fontsize=style['text_size'], ha='center', va='center')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_1_5_team_collaboration.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Generate all state management diagrams"""
    print("Generating Terraform State Management Diagrams...")
    print("=" * 50)
    
    diagrams = [
        ("Figure 6.1.1: State Lifecycle Overview", diagram_1_state_lifecycle),
        ("Figure 6.1.2: Local vs Remote Comparison", diagram_2_local_vs_remote),
        ("Figure 6.1.3: IBM COS Backend Architecture", diagram_3_cos_backend),
        ("Figure 6.1.4: Migration Workflow Process", diagram_4_migration_workflow),
        ("Figure 6.1.5: Team Collaboration Model", diagram_5_team_collaboration)
    ]
    
    for name, func in diagrams:
        print(f"Generating {name}...")
        func()
        print(f"✅ {name} completed")
    
    print("=" * 50)
    print("All diagrams generated successfully!")
    print(f"Output directory: generated_diagrams/")
    print(f"Resolution: 300 DPI")
    print(f"Format: PNG")
    
    # List generated files
    import glob
    files = glob.glob('generated_diagrams/*.png')
    print(f"\nGenerated files ({len(files)}):")
    for file in sorted(files):
        print(f"  - {file}")

if __name__ == "__main__":
    main()
