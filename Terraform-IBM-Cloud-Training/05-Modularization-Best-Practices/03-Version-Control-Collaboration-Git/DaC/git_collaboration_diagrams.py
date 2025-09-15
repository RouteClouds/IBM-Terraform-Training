#!/usr/bin/env python3
"""
Git Collaboration Diagrams Generator
Professional diagram generation for Topic 5.3: Version Control and Collaboration with Git

This script generates 5 comprehensive diagrams demonstrating Git workflows,
CI/CD pipelines, team collaboration patterns, and enterprise governance.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import seaborn as sns
from datetime import datetime
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
IBM_GREEN = '#24A148'
IBM_RED = '#DA1E28'
IBM_YELLOW = '#F1C21B'
IBM_PURPLE = '#8A3FFC'

# Create output directory
output_dir = 'generated_diagrams'
os.makedirs(output_dir, exist_ok=True)

def create_professional_style():
    """Create consistent professional styling for all diagrams"""
    return {
        'figure_size': (16, 12),
        'dpi': 300,
        'title_size': 20,
        'subtitle_size': 14,
        'label_size': 12,
        'annotation_size': 10,
        'line_width': 2,
        'box_style': "round,pad=0.3",
        'arrow_style': '->'
    }

def add_watermark(ax, style):
    """Add professional watermark to diagrams"""
    ax.text(0.99, 0.01, f'IBM Cloud Terraform Training - Topic 5.3\nGenerated: {datetime.now().strftime("%Y-%m-%d")}',
            transform=ax.transAxes, fontsize=8, alpha=0.6,
            ha='right', va='bottom', style='italic')

def diagram_11_git_workflow_patterns(style):
    """
    Figure 5.3.1: Git Workflow Patterns for Infrastructure Teams
    Shows GitFlow, GitHub Flow, and GitLab Flow with Terraform-specific adaptations
    """
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=style['figure_size'], dpi=style['dpi'])
    fig.suptitle('Git Workflow Patterns for Infrastructure Teams', fontsize=style['title_size'], fontweight='bold', y=0.95)
    
    # GitFlow Pattern
    ax1.set_title('GitFlow for Infrastructure', fontsize=style['subtitle_size'], fontweight='bold')
    
    # Branch structure
    branches = {
        'main': {'y': 5, 'color': IBM_BLUE, 'label': 'main (production)'},
        'develop': {'y': 4, 'color': IBM_GREEN, 'label': 'develop (integration)'},
        'feature': {'y': 3, 'color': IBM_YELLOW, 'label': 'feature/vpc-redesign'},
        'release': {'y': 2, 'color': IBM_PURPLE, 'label': 'release/v2.1.0'},
        'hotfix': {'y': 1, 'color': IBM_RED, 'label': 'hotfix/security-patch'}
    }
    
    # Draw branches
    for branch, props in branches.items():
        ax1.plot([0, 10], [props['y'], props['y']], color=props['color'], linewidth=3, alpha=0.8)
        ax1.text(-0.5, props['y'], props['label'], fontsize=style['annotation_size'], 
                ha='right', va='center', fontweight='bold')
    
    # Add merge arrows
    merge_points = [
        (3, 3, 4, 'Feature merge'),
        (7, 2, 5, 'Release merge'),
        (8.5, 1, 5, 'Hotfix merge')
    ]
    
    for x, from_y, to_y, label in merge_points:
        ax1.annotate('', xy=(x, to_y), xytext=(x, from_y),
                    arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=2))
        ax1.text(x, (from_y + to_y) / 2, label, fontsize=8, ha='center', 
                bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8))
    
    ax1.set_xlim(-3, 11)
    ax1.set_ylim(0.5, 5.5)
    ax1.set_xlabel('Time →', fontsize=style['label_size'])
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks([])
    ax1.set_yticks([])
    
    # GitHub Flow Pattern
    ax2.set_title('GitHub Flow (Simplified)', fontsize=style['subtitle_size'], fontweight='bold')
    
    # Simplified flow
    ax2.plot([0, 10], [3, 3], color=IBM_BLUE, linewidth=4, label='main')
    ax2.plot([2, 6], [2, 2], color=IBM_GREEN, linewidth=3, label='feature branch')
    
    # Feature branch creation and merge
    ax2.plot([2, 2], [3, 2], color=IBM_GREEN, linewidth=2, linestyle='--')
    ax2.plot([6, 6], [2, 3], color=IBM_GREEN, linewidth=2, linestyle='--')
    
    # Add annotations
    annotations = [
        (1, 3.2, 'Continuous\nDeployment'),
        (4, 1.7, 'Feature\nDevelopment'),
        (6.5, 2.5, 'PR Review\n& Merge'),
        (8, 3.2, 'Auto Deploy\nto Production')
    ]
    
    for x, y, text in annotations:
        ax2.text(x, y, text, fontsize=style['annotation_size'], ha='center', va='center',
                bbox=dict(boxstyle="round,pad=0.3", facecolor=IBM_LIGHT_GRAY, alpha=0.8))
    
    ax2.set_xlim(-0.5, 10.5)
    ax2.set_ylim(1.5, 3.5)
    ax2.set_xlabel('Time →', fontsize=style['label_size'])
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks([])
    ax2.set_yticks([])
    ax2.legend(loc='upper left')
    
    # Environment-based Flow
    ax3.set_title('Environment-based Branching', fontsize=style['subtitle_size'], fontweight='bold')
    
    environments = [
        ('production', 4, IBM_RED),
        ('staging', 3, IBM_YELLOW),
        ('development', 2, IBM_GREEN),
        ('feature', 1, IBM_LIGHT_BLUE)
    ]
    
    for env, y, color in environments:
        ax3.plot([0, 10], [y, y], color=color, linewidth=3, alpha=0.8)
        ax3.text(-0.5, y, env, fontsize=style['annotation_size'], 
                ha='right', va='center', fontweight='bold')
    
    # Promotion arrows
    promotion_points = [(3, 1, 2), (5, 2, 3), (7, 3, 4)]
    for x, from_y, to_y in promotion_points:
        ax3.annotate('', xy=(x, to_y), xytext=(x, from_y),
                    arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=2))
        ax3.text(x + 0.2, (from_y + to_y) / 2, 'promote', fontsize=8, rotation=90, ha='center')
    
    ax3.set_xlim(-2, 11)
    ax3.set_ylim(0.5, 4.5)
    ax3.set_xlabel('Time →', fontsize=style['label_size'])
    ax3.grid(True, alpha=0.3)
    ax3.set_xticks([])
    ax3.set_yticks([])
    
    # Terraform-specific Considerations
    ax4.set_title('Terraform-specific Workflow Adaptations', fontsize=style['subtitle_size'], fontweight='bold')
    ax4.axis('off')
    
    considerations = [
        "🔒 State File Management",
        "• Remote state with locking",
        "• Environment isolation",
        "• Backup and recovery",
        "",
        "🔄 Resource Dependencies",
        "• Dependency mapping",
        "• Ordered deployments",
        "• Rollback strategies",
        "",
        "📋 Compliance Requirements",
        "• Policy validation",
        "• Approval workflows",
        "• Audit trails",
        "",
        "💰 Cost Management",
        "• Cost analysis in CI/CD",
        "• Budget validation",
        "• Resource optimization"
    ]
    
    y_pos = 0.9
    for item in considerations:
        if item.startswith("🔒") or item.startswith("🔄") or item.startswith("📋") or item.startswith("💰"):
            ax4.text(0.05, y_pos, item, fontsize=style['label_size'], fontweight='bold', 
                    transform=ax4.transAxes, color=IBM_BLUE)
        elif item == "":
            y_pos -= 0.05
            continue
        else:
            ax4.text(0.1, y_pos, item, fontsize=style['annotation_size'], 
                    transform=ax4.transAxes, color=IBM_GRAY)
        y_pos -= 0.08
    
    plt.tight_layout()
    add_watermark(ax4, style)
    plt.savefig(f'{output_dir}/11_git_workflow_patterns.png', dpi=style['dpi'], bbox_inches='tight')
    plt.close()

def diagram_12_multi_team_branching(style):
    """
    Figure 5.3.2: Multi-Team Branching Strategy with Dependency Management
    Illustrates team-based branching, shared modules, and cross-team dependencies
    """
    fig, ax = plt.subplots(figsize=style['figure_size'], dpi=style['dpi'])
    fig.suptitle('Multi-Team Branching Strategy with Dependency Management', 
                fontsize=style['title_size'], fontweight='bold', y=0.95)
    
    # Team areas
    teams = {
        'Platform Team': {'x': 1, 'y': 7, 'width': 3, 'height': 1.5, 'color': IBM_BLUE},
        'Web Team': {'x': 5, 'y': 7, 'width': 3, 'height': 1.5, 'color': IBM_GREEN},
        'API Team': {'x': 9, 'y': 7, 'width': 3, 'height': 1.5, 'color': IBM_YELLOW},
        'Data Team': {'x': 13, 'y': 7, 'width': 3, 'height': 1.5, 'color': IBM_PURPLE}
    }
    
    # Draw team areas
    for team, props in teams.items():
        rect = FancyBboxPatch((props['x'], props['y']), props['width'], props['height'],
                             boxstyle="round,pad=0.1", facecolor=props['color'], alpha=0.3,
                             edgecolor=props['color'], linewidth=2)
        ax.add_patch(rect)
        ax.text(props['x'] + props['width']/2, props['y'] + props['height']/2, team,
               fontsize=style['label_size'], ha='center', va='center', fontweight='bold')
    
    # Shared modules area
    shared_rect = FancyBboxPatch((1, 4.5), 15, 1.5, boxstyle="round,pad=0.1",
                                facecolor=IBM_LIGHT_GRAY, alpha=0.5,
                                edgecolor=IBM_GRAY, linewidth=2)
    ax.add_patch(shared_rect)
    ax.text(8.5, 5.25, 'Shared Modules Repository', fontsize=style['subtitle_size'],
           ha='center', va='center', fontweight='bold')
    
    # Module components
    modules = ['networking', 'security', 'monitoring', 'compliance']
    for i, module in enumerate(modules):
        x = 2 + i * 3.5
        module_rect = FancyBboxPatch((x, 4.7), 2.5, 1.1, boxstyle="round,pad=0.05",
                                   facecolor='white', edgecolor=IBM_GRAY, linewidth=1)
        ax.add_patch(module_rect)
        ax.text(x + 1.25, 5.25, module, fontsize=style['annotation_size'],
               ha='center', va='center')
    
    # Environment branches
    environments = ['main (prod)', 'staging', 'develop']
    for i, env in enumerate(environments):
        y = 2.5 - i * 0.8
        ax.plot([1, 16], [y, y], color=IBM_BLUE, linewidth=3, alpha=0.7)
        ax.text(0.5, y, env, fontsize=style['annotation_size'], ha='right', va='center')
    
    # Dependencies arrows
    dependencies = [
        # From teams to shared modules
        (2.5, 7, 3.5, 6),
        (6.5, 7, 5.5, 6),
        (10.5, 7, 9.5, 6),
        (14.5, 7, 13.5, 6),
        # From shared modules to environments
        (8.5, 4.5, 8.5, 3.3)
    ]
    
    for x1, y1, x2, y2 in dependencies:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=2, alpha=0.7))
    
    # Integration points
    integration_points = [
        (4, 2.5, 'Integration\nTesting'),
        (8, 1.7, 'Staging\nValidation'),
        (12, 0.9, 'Production\nDeployment')
    ]
    
    for x, y, label in integration_points:
        circle = Circle((x, y), 0.3, facecolor=IBM_RED, alpha=0.7)
        ax.add_patch(circle)
        ax.text(x, y - 0.6, label, fontsize=style['annotation_size'],
               ha='center', va='center', fontweight='bold')
    
    # Collaboration workflow
    workflow_text = [
        "Collaboration Workflow:",
        "1. Teams develop in isolated branches",
        "2. Shared modules versioned independently",
        "3. Integration testing validates dependencies",
        "4. Coordinated releases across teams",
        "5. Automated dependency management"
    ]
    
    for i, text in enumerate(workflow_text):
        style_props = {'fontweight': 'bold'} if i == 0 else {}
        ax.text(17, 8 - i * 0.4, text, fontsize=style['annotation_size'],
               ha='left', va='center', **style_props)
    
    ax.set_xlim(0, 22)
    ax.set_ylim(0, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    
    add_watermark(ax, style)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/12_multi_team_branching.png', dpi=style['dpi'], bbox_inches='tight')
    plt.close()

def diagram_13_cicd_pipeline_architecture(style):
    """
    Figure 5.3.3: CI/CD Pipeline Architecture with State Management
    Shows complete CI/CD pipeline with validation stages, deployment gates, and state management
    """
    fig, ax = plt.subplots(figsize=style['figure_size'], dpi=style['dpi'])
    fig.suptitle('CI/CD Pipeline Architecture with State Management', 
                fontsize=style['title_size'], fontweight='bold', y=0.95)
    
    # Pipeline stages
    stages = [
        {'name': 'Code\nCommit', 'x': 1, 'color': IBM_LIGHT_BLUE},
        {'name': 'Syntax\nValidation', 'x': 3, 'color': IBM_GREEN},
        {'name': 'Security\nScan', 'x': 5, 'color': IBM_RED},
        {'name': 'Cost\nAnalysis', 'x': 7, 'color': IBM_YELLOW},
        {'name': 'Policy\nValidation', 'x': 9, 'color': IBM_PURPLE},
        {'name': 'Plan\nGeneration', 'x': 11, 'color': IBM_BLUE},
        {'name': 'Manual\nApproval', 'x': 13, 'color': IBM_GRAY},
        {'name': 'Deploy', 'x': 15, 'color': IBM_GREEN}
    ]
    
    # Draw pipeline flow
    y_main = 6
    for i, stage in enumerate(stages):
        # Stage box
        rect = FancyBboxPatch((stage['x'] - 0.4, y_main - 0.4), 0.8, 0.8,
                             boxstyle="round,pad=0.1", facecolor=stage['color'], alpha=0.7,
                             edgecolor=stage['color'], linewidth=2)
        ax.add_patch(rect)
        ax.text(stage['x'], y_main, stage['name'], fontsize=style['annotation_size'],
               ha='center', va='center', fontweight='bold', color='white')
        
        # Connection arrow
        if i < len(stages) - 1:
            ax.annotate('', xy=(stages[i+1]['x'] - 0.4, y_main), 
                       xytext=(stage['x'] + 0.4, y_main),
                       arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=2))
    
    # Validation details
    validation_details = {
        3: ['terraform fmt', 'terraform validate', 'tflint'],
        5: ['tfsec scan', 'checkov analysis', 'policy check'],
        7: ['infracost analysis', 'budget validation', 'cost alerts'],
        9: ['OPA policies', 'compliance check', 'governance rules']
    }
    
    for x, details in validation_details.items():
        for i, detail in enumerate(details):
            ax.text(x, 4.5 - i * 0.3, f"• {detail}", fontsize=8,
                   ha='center', va='center', color=IBM_GRAY)
    
    # Environment deployment flow
    environments = [
        {'name': 'Development', 'x': 3, 'y': 2, 'color': IBM_GREEN},
        {'name': 'Staging', 'x': 8, 'y': 2, 'color': IBM_YELLOW},
        {'name': 'Production', 'x': 13, 'y': 2, 'color': IBM_RED}
    ]
    
    for env in environments:
        rect = FancyBboxPatch((env['x'] - 1, env['y'] - 0.5), 2, 1,
                             boxstyle="round,pad=0.1", facecolor=env['color'], alpha=0.3,
                             edgecolor=env['color'], linewidth=2)
        ax.add_patch(rect)
        ax.text(env['x'], env['y'], env['name'], fontsize=style['label_size'],
               ha='center', va='center', fontweight='bold')
    
    # Environment promotion arrows
    ax.annotate('', xy=(7, 2), xytext=(4, 2),
               arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=3))
    ax.annotate('', xy=(12, 2), xytext=(9, 2),
               arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=3))
    
    # State management section
    state_y = 0.5
    state_rect = FancyBboxPatch((1, state_y - 0.3), 14, 0.6,
                               boxstyle="round,pad=0.1", facecolor=IBM_LIGHT_GRAY, alpha=0.5,
                               edgecolor=IBM_GRAY, linewidth=1)
    ax.add_patch(state_rect)
    ax.text(8, state_y, 'Remote State Management: S3 Backend + DynamoDB Locking + Automated Backups',
           fontsize=style['label_size'], ha='center', va='center', fontweight='bold')
    
    # Gates and checkpoints
    gates = [
        (6, 7, 'Security\nGate'),
        (10, 7, 'Policy\nGate'),
        (14, 7, 'Approval\nGate')
    ]
    
    for x, y, label in gates:
        diamond = patches.RegularPolygon((x, y), 4, radius=0.3, orientation=np.pi/4,
                                       facecolor=IBM_RED, alpha=0.7, edgecolor=IBM_RED)
        ax.add_patch(diamond)
        ax.text(x, y - 0.6, label, fontsize=8, ha='center', va='center', fontweight='bold')
    
    ax.set_xlim(0, 16)
    ax.set_ylim(-0.5, 8)
    ax.axis('off')
    
    add_watermark(ax, style)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/13_cicd_pipeline_architecture.png', dpi=style['dpi'], bbox_inches='tight')
    plt.close()

def diagram_14_team_collaboration_workflow(style):
    """
    Figure 5.3.4: Team Collaboration Workflow with RBAC and Approval Gates
    Shows team roles, permission matrix, review workflows, and approval processes
    """
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=style['figure_size'], dpi=style['dpi'])
    fig.suptitle('Team Collaboration Workflow with RBAC and Approval Gates', 
                fontsize=style['title_size'], fontweight='bold', y=0.95)
    
    # Team Roles and Permissions Matrix
    ax1.set_title('Role-Based Access Control Matrix', fontsize=style['subtitle_size'], fontweight='bold')
    
    roles = ['Infrastructure\nArchitect', 'Senior\nEngineer', 'Engineer', 'Security\nReviewer', 'Compliance\nOfficer']
    permissions = ['Repository\nAccess', 'Branch\nPermissions', 'Deployment\nRights', 'Review\nRequirements']
    
    # Create permission matrix
    permission_matrix = [
        ['Admin', 'All branches', 'Production', 'Required'],
        ['Write', 'Feature + Develop', 'Staging', 'Senior review'],
        ['Write', 'Feature only', 'Development', 'Peer review'],
        ['Read', 'Review access', 'None', 'Security approval'],
        ['Read', 'Audit access', 'None', 'Compliance check']
    ]
    
    # Color coding for permission levels
    colors = [
        [IBM_RED, IBM_RED, IBM_RED, IBM_RED],
        [IBM_YELLOW, IBM_YELLOW, IBM_YELLOW, IBM_YELLOW],
        [IBM_GREEN, IBM_GREEN, IBM_GREEN, IBM_GREEN],
        [IBM_BLUE, IBM_BLUE, IBM_LIGHT_GRAY, IBM_BLUE],
        [IBM_PURPLE, IBM_PURPLE, IBM_LIGHT_GRAY, IBM_PURPLE]
    ]
    
    for i, role in enumerate(roles):
        ax1.text(-0.5, 4-i, role, fontsize=style['annotation_size'], ha='right', va='center', fontweight='bold')
        for j, perm in enumerate(permission_matrix[i]):
            rect = FancyBboxPatch((j-0.4, 4-i-0.3), 0.8, 0.6,
                                 boxstyle="round,pad=0.05", facecolor=colors[i][j], alpha=0.3,
                                 edgecolor=colors[i][j], linewidth=1)
            ax1.add_patch(rect)
            ax1.text(j, 4-i, perm, fontsize=8, ha='center', va='center')
    
    for j, perm in enumerate(permissions):
        ax1.text(j, 4.7, perm, fontsize=style['annotation_size'], ha='center', va='center', fontweight='bold')
    
    ax1.set_xlim(-2, 4)
    ax1.set_ylim(-0.5, 5)
    ax1.axis('off')
    
    # Approval Workflow
    ax2.set_title('Multi-Stage Approval Process', fontsize=style['subtitle_size'], fontweight='bold')
    
    approval_stages = [
        {'name': 'Technical\nReview', 'y': 4, 'color': IBM_GREEN, 'requirements': 'Peer review\nAutomated validation'},
        {'name': 'Security\nReview', 'y': 3, 'color': IBM_RED, 'requirements': 'Security team\nCompliance check'},
        {'name': 'Architecture\nReview', 'y': 2, 'color': IBM_BLUE, 'requirements': 'Senior review\nSignificant changes'},
        {'name': 'Business\nApproval', 'y': 1, 'color': IBM_PURPLE, 'requirements': 'Stakeholder\nProduction changes'}
    ]
    
    for stage in approval_stages:
        # Stage box
        rect = FancyBboxPatch((0.5, stage['y']-0.3), 1.5, 0.6,
                             boxstyle="round,pad=0.1", facecolor=stage['color'], alpha=0.7,
                             edgecolor=stage['color'], linewidth=2)
        ax2.add_patch(rect)
        ax2.text(1.25, stage['y'], stage['name'], fontsize=style['annotation_size'],
                ha='center', va='center', fontweight='bold', color='white')
        
        # Requirements
        ax2.text(2.5, stage['y'], stage['requirements'], fontsize=8,
                ha='left', va='center', color=IBM_GRAY)
        
        # Arrow to next stage
        if stage['y'] > 1:
            ax2.annotate('', xy=(1.25, stage['y']-0.7), xytext=(1.25, stage['y']-0.3),
                        arrowprops=dict(arrowstyle='->', color=IBM_GRAY, lw=2))
    
    ax2.set_xlim(0, 5)
    ax2.set_ylim(0.5, 4.5)
    ax2.axis('off')
    
    # Code Review Checklist
    ax3.set_title('Code Review Checklist', fontsize=style['subtitle_size'], fontweight='bold')
    
    checklist_categories = [
        ('Technical Review', [
            'Terraform syntax correct',
            'Resource naming conventions',
            'Variables documented',
            'No hardcoded values'
        ]),
        ('Security Review', [
            'Security groups configured',
            'Encryption enabled',
            'IAM policies scoped',
            'Secrets management'
        ]),
        ('Operational Review', [
            'Monitoring configured',
            'Backup procedures',
            'Cost optimization',
            'Documentation updated'
        ])
    ]
    
    y_pos = 0.9
    for category, items in checklist_categories:
        ax3.text(0.05, y_pos, category, fontsize=style['label_size'], fontweight='bold',
                transform=ax3.transAxes, color=IBM_BLUE)
        y_pos -= 0.08
        for item in items:
            ax3.text(0.1, y_pos, f"☐ {item}", fontsize=style['annotation_size'],
                    transform=ax3.transAxes, color=IBM_GRAY)
            y_pos -= 0.06
        y_pos -= 0.04
    
    ax3.axis('off')
    
    # Collaboration Metrics
    ax4.set_title('Collaboration Metrics & KPIs', fontsize=style['subtitle_size'], fontweight='bold')
    
    metrics = [
        ('Code Review Coverage', '100%', IBM_GREEN),
        ('Average Review Time', '2.5 hours', IBM_BLUE),
        ('Deployment Success Rate', '98.5%', IBM_GREEN),
        ('Security Scan Pass Rate', '95%', IBM_YELLOW),
        ('Policy Compliance', '100%', IBM_GREEN),
        ('Team Satisfaction', '4.8/5', IBM_BLUE)
    ]
    
    for i, (metric, value, color) in enumerate(metrics):
        y = 0.8 - i * 0.12
        ax4.text(0.05, y, metric, fontsize=style['annotation_size'], fontweight='bold',
                transform=ax4.transAxes, color=IBM_GRAY)
        ax4.text(0.7, y, value, fontsize=style['label_size'], fontweight='bold',
                transform=ax4.transAxes, color=color)
    
    ax4.axis('off')
    
    plt.tight_layout()
    add_watermark(ax4, style)
    plt.savefig(f'{output_dir}/14_team_collaboration_workflow.png', dpi=style['dpi'], bbox_inches='tight')
    plt.close()

def diagram_15_security_compliance_integration(style):
    """
    Figure 5.3.5: Security and Compliance Integration Architecture
    Shows policy-as-code implementation, secrets management, audit trails, and compliance automation
    """
    fig, ax = plt.subplots(figsize=style['figure_size'], dpi=style['dpi'])
    fig.suptitle('Security and Compliance Integration Architecture', 
                fontsize=style['title_size'], fontweight='bold', y=0.95)
    
    # Policy as Code section
    policy_rect = FancyBboxPatch((1, 7), 6, 2, boxstyle="round,pad=0.2",
                                facecolor=IBM_RED, alpha=0.2, edgecolor=IBM_RED, linewidth=2)
    ax.add_patch(policy_rect)
    ax.text(4, 8.5, 'Policy as Code (OPA)', fontsize=style['subtitle_size'],
           ha='center', va='center', fontweight='bold', color=IBM_RED)
    
    policies = ['Security Policies', 'Compliance Rules', 'Cost Controls', 'Naming Conventions']
    for i, policy in enumerate(policies):
        x = 1.5 + (i % 2) * 2.5
        y = 8.2 - (i // 2) * 0.6
        policy_box = FancyBboxPatch((x-0.4, y-0.2), 0.8, 0.4,
                                   boxstyle="round,pad=0.05", facecolor='white',
                                   edgecolor=IBM_RED, linewidth=1)
        ax.add_patch(policy_box)
        ax.text(x, y, policy, fontsize=8, ha='center', va='center')
    
    # Secrets Management section
    secrets_rect = FancyBboxPatch((8, 7), 6, 2, boxstyle="round,pad=0.2",
                                 facecolor=IBM_BLUE, alpha=0.2, edgecolor=IBM_BLUE, linewidth=2)
    ax.add_patch(secrets_rect)
    ax.text(11, 8.5, 'Secrets Management', fontsize=style['subtitle_size'],
           ha='center', va='center', fontweight='bold', color=IBM_BLUE)
    
    secrets_components = ['HashiCorp Vault', 'Environment Variables', 'Sensitive Attributes', 'Pre-commit Hooks']
    for i, component in enumerate(secrets_components):
        x = 8.5 + (i % 2) * 2.5
        y = 8.2 - (i // 2) * 0.6
        secret_box = FancyBboxPatch((x-0.4, y-0.2), 0.8, 0.4,
                                   boxstyle="round,pad=0.05", facecolor='white',
                                   edgecolor=IBM_BLUE, linewidth=1)
        ax.add_patch(secret_box)
        ax.text(x, y, component, fontsize=8, ha='center', va='center')
    
    # CI/CD Integration Pipeline
    pipeline_y = 5.5
    pipeline_stages = [
        ('Code\nCommit', 1.5, IBM_LIGHT_BLUE),
        ('Secret\nScan', 3, IBM_RED),
        ('Policy\nValidation', 4.5, IBM_PURPLE),
        ('Security\nScan', 6, IBM_RED),
        ('Compliance\nCheck', 7.5, IBM_GREEN),
        ('Audit\nLog', 9, IBM_GRAY),
        ('Deploy', 10.5, IBM_GREEN),
        ('Monitor', 12, IBM_BLUE)
    ]
    
    for stage, x, color in pipeline_stages:
        circle = Circle((x, pipeline_y), 0.3, facecolor=color, alpha=0.7, edgecolor=color)
        ax.add_patch(circle)
        ax.text(x, pipeline_y - 0.6, stage, fontsize=8, ha='center', va='center', fontweight='bold')
        
        # Connection lines
        if x < 12:
            ax.plot([x + 0.3, x + 1.2], [pipeline_y, pipeline_y], color=IBM_GRAY, linewidth=2)
    
    # Compliance Frameworks
    compliance_y = 3.5
    frameworks = [
        ('SOC 2', 2, IBM_BLUE),
        ('ISO 27001', 4, IBM_GREEN),
        ('PCI DSS', 6, IBM_RED),
        ('GDPR', 8, IBM_PURPLE),
        ('HIPAA', 10, IBM_YELLOW)
    ]
    
    compliance_rect = FancyBboxPatch((1, compliance_y - 0.5), 10, 1,
                                    boxstyle="round,pad=0.1", facecolor=IBM_LIGHT_GRAY, alpha=0.3,
                                    edgecolor=IBM_GRAY, linewidth=1)
    ax.add_patch(compliance_rect)
    ax.text(6, compliance_y + 0.3, 'Compliance Frameworks', fontsize=style['label_size'],
           ha='center', va='center', fontweight='bold')
    
    for framework, x, color in frameworks:
        framework_box = FancyBboxPatch((x-0.4, compliance_y-0.2), 0.8, 0.4,
                                      boxstyle="round,pad=0.05", facecolor=color, alpha=0.7,
                                      edgecolor=color, linewidth=1)
        ax.add_patch(framework_box)
        ax.text(x, compliance_y, framework, fontsize=8, ha='center', va='center',
               fontweight='bold', color='white')
    
    # Audit Trail
    audit_y = 1.5
    audit_components = [
        'Change Tracking',
        'Approval Records',
        'Deployment Logs',
        'Access Logs',
        'Compliance Reports'
    ]
    
    ax.text(7, audit_y + 0.8, 'Audit Trail & Compliance Tracking', fontsize=style['subtitle_size'],
           ha='center', va='center', fontweight='bold', color=IBM_GRAY)
    
    for i, component in enumerate(audit_components):
        x = 2 + i * 2.4
        audit_box = FancyBboxPatch((x-0.6, audit_y-0.2), 1.2, 0.4,
                                  boxstyle="round,pad=0.05", facecolor=IBM_GRAY, alpha=0.3,
                                  edgecolor=IBM_GRAY, linewidth=1)
        ax.add_patch(audit_box)
        ax.text(x, audit_y, component, fontsize=8, ha='center', va='center')
    
    # Security metrics
    metrics_text = [
        "Security Metrics:",
        "• 100% Secret scan coverage",
        "• 0 security incidents",
        "• 95% policy compliance",
        "• 24/7 audit monitoring",
        "• Automated remediation"
    ]
    
    for i, text in enumerate(metrics_text):
        style_props = {'fontweight': 'bold', 'color': IBM_RED} if i == 0 else {'color': IBM_GRAY}
        ax.text(12.5, 6 - i * 0.3, text, fontsize=style['annotation_size'],
               ha='left', va='center', **style_props)
    
    ax.set_xlim(0, 16)
    ax.set_ylim(0.5, 9.5)
    ax.axis('off')
    
    add_watermark(ax, style)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/15_security_compliance_integration.png', dpi=style['dpi'], bbox_inches='tight')
    plt.close()

def main():
    """Generate all diagrams for Topic 5.3"""
    print("🎨 Generating Git Collaboration Diagrams for Topic 5.3...")
    
    style = create_professional_style()
    
    # Generate all diagrams
    diagrams = [
        ("Git Workflow Patterns", diagram_11_git_workflow_patterns),
        ("Multi-Team Branching Strategy", diagram_12_multi_team_branching),
        ("CI/CD Pipeline Architecture", diagram_13_cicd_pipeline_architecture),
        ("Team Collaboration Workflow", diagram_14_team_collaboration_workflow),
        ("Security and Compliance Integration", diagram_15_security_compliance_integration)
    ]
    
    for name, diagram_func in diagrams:
        print(f"  📊 Creating {name}...")
        diagram_func(style)
        print(f"  ✅ {name} completed")
    
    # Calculate total file size
    total_size = 0
    for file in os.listdir(output_dir):
        if file.endswith('.png'):
            file_path = os.path.join(output_dir, file)
            total_size += os.path.getsize(file_path)
    
    print(f"\n🎉 All diagrams generated successfully!")
    print(f"📁 Output directory: {output_dir}/")
    print(f"📊 Total files: {len([f for f in os.listdir(output_dir) if f.endswith('.png')])}")
    print(f"💾 Total size: {total_size / (1024*1024):.2f} MB")
    print(f"🎯 Resolution: {style['dpi']} DPI (Professional Quality)")
    
    # List generated files
    print(f"\n📋 Generated files:")
    for file in sorted(os.listdir(output_dir)):
        if file.endswith('.png'):
            file_path = os.path.join(output_dir, file)
            size_mb = os.path.getsize(file_path) / (1024*1024)
            print(f"  • {file} ({size_mb:.2f} MB)")

if __name__ == "__main__":
    main()
