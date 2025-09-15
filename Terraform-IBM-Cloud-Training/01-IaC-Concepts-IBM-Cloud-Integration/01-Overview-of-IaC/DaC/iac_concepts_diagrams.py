#!/usr/bin/env python3
"""
Infrastructure as Code (IaC) Concepts - Diagram as Code Implementation
This script generates visual diagrams to illustrate key IaC concepts using Python libraries.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np
import os

# Set up the output directory
output_dir = "generated_diagrams"
os.makedirs(output_dir, exist_ok=True)

def create_traditional_vs_iac_comparison():
    """Create a comparison diagram between traditional and IaC approaches"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 10))
    fig.suptitle('Traditional Infrastructure Management vs Infrastructure as Code', 
                 fontsize=16, fontweight='bold')
    
    # Traditional Approach (Left side)
    ax1.set_title('Traditional Approach', fontsize=14, fontweight='bold', color='red')
    ax1.set_xlim(0, 10)
    ax1.set_ylim(0, 10)
    ax1.axis('off')
    
    # Traditional workflow boxes
    traditional_boxes = [
        {'xy': (1, 8), 'width': 8, 'height': 1, 'text': 'Manual Console Configuration', 'color': '#ffcccc'},
        {'xy': (1, 6.5), 'width': 8, 'height': 1, 'text': 'Documentation in Word/Wiki', 'color': '#ffcccc'},
        {'xy': (1, 5), 'width': 8, 'height': 1, 'text': 'Manual Testing & Validation', 'color': '#ffcccc'},
        {'xy': (1, 3.5), 'width': 8, 'height': 1, 'text': 'Environment Inconsistencies', 'color': '#ff9999'},
        {'xy': (1, 2), 'width': 8, 'height': 1, 'text': 'Slow Recovery & Scaling', 'color': '#ff6666'},
    ]
    
    for box in traditional_boxes:
        rect = FancyBboxPatch(box['xy'], box['width'], box['height'], 
                             boxstyle="round,pad=0.1", facecolor=box['color'], 
                             edgecolor='black', linewidth=1)
        ax1.add_patch(rect)
        ax1.text(box['xy'][0] + box['width']/2, box['xy'][1] + box['height']/2, 
                box['text'], ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Add arrows showing manual process flow
    for i in range(len(traditional_boxes) - 1):
        start_y = traditional_boxes[i]['xy'][1]
        end_y = traditional_boxes[i+1]['xy'][1] + traditional_boxes[i+1]['height']
        ax1.arrow(5, start_y - 0.1, 0, end_y - start_y + 0.2, 
                 head_width=0.2, head_length=0.1, fc='red', ec='red')
    
    # IaC Approach (Right side)
    ax2.set_title('Infrastructure as Code Approach', fontsize=14, fontweight='bold', color='green')
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.axis('off')
    
    # IaC workflow boxes
    iac_boxes = [
        {'xy': (1, 8), 'width': 8, 'height': 1, 'text': 'Code-Defined Infrastructure', 'color': '#ccffcc'},
        {'xy': (1, 6.5), 'width': 8, 'height': 1, 'text': 'Version Control Integration', 'color': '#ccffcc'},
        {'xy': (1, 5), 'width': 8, 'height': 1, 'text': 'Automated Testing & Validation', 'color': '#ccffcc'},
        {'xy': (1, 3.5), 'width': 8, 'height': 1, 'text': 'Consistent Environments', 'color': '#99ff99'},
        {'xy': (1, 2), 'width': 8, 'height': 1, 'text': 'Rapid Recovery & Scaling', 'color': '#66ff66'},
    ]
    
    for box in iac_boxes:
        rect = FancyBboxPatch(box['xy'], box['width'], box['height'], 
                             boxstyle="round,pad=0.1", facecolor=box['color'], 
                             edgecolor='black', linewidth=1)
        ax2.add_patch(rect)
        ax2.text(box['xy'][0] + box['width']/2, box['xy'][1] + box['height']/2, 
                box['text'], ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Add arrows showing automated process flow
    for i in range(len(iac_boxes) - 1):
        start_y = iac_boxes[i]['xy'][1]
        end_y = iac_boxes[i+1]['xy'][1] + iac_boxes[i+1]['height']
        ax2.arrow(5, start_y - 0.1, 0, end_y - start_y + 0.2, 
                 head_width=0.2, head_length=0.1, fc='green', ec='green')
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/traditional_vs_iac_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_iac_principles_diagram():
    """Create a diagram showing the core principles of IaC"""
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_title('Infrastructure as Code - Core Principles', fontsize=16, fontweight='bold')
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Central IaC circle
    center_circle = plt.Circle((7, 5), 1.5, color='lightblue', alpha=0.8)
    ax.add_patch(center_circle)
    ax.text(7, 5, 'Infrastructure\nas Code', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    
    # Principle boxes around the center
    principles = [
        {'pos': (7, 8.5), 'text': 'Declarative\nConfiguration', 'color': '#ffeb3b'},
        {'pos': (10.5, 7), 'text': 'Version Control\nIntegration', 'color': '#4caf50'},
        {'pos': (10.5, 3), 'text': 'Idempotency', 'color': '#2196f3'},
        {'pos': (7, 1.5), 'text': 'Immutable\nInfrastructure', 'color': '#ff9800'},
        {'pos': (3.5, 3), 'text': 'Automation\n& Repeatability', 'color': '#9c27b0'},
        {'pos': (3.5, 7), 'text': 'Testing &\nValidation', 'color': '#f44336'},
    ]
    
    for principle in principles:
        # Create principle box
        rect = FancyBboxPatch((principle['pos'][0] - 1, principle['pos'][1] - 0.5), 
                             2, 1, boxstyle="round,pad=0.1", 
                             facecolor=principle['color'], alpha=0.7,
                             edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(principle['pos'][0], principle['pos'][1], principle['text'], 
                ha='center', va='center', fontsize=10, fontweight='bold')
        
        # Draw connection to center
        ax.plot([principle['pos'][0], 7], [principle['pos'][1], 5], 
                'k--', linewidth=2, alpha=0.6)
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/iac_principles.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_iac_workflow_diagram():
    """Create a diagram showing the typical IaC workflow"""
    fig, ax = plt.subplots(figsize=(16, 8))
    ax.set_title('Infrastructure as Code - Typical Workflow', fontsize=16, fontweight='bold')
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Workflow steps
    workflow_steps = [
        {'pos': (2, 6), 'text': 'Write\nInfrastructure\nCode', 'color': '#e3f2fd'},
        {'pos': (5, 6), 'text': 'Version\nControl\n(Git)', 'color': '#f3e5f5'},
        {'pos': (8, 6), 'text': 'Code\nReview &\nApproval', 'color': '#e8f5e8'},
        {'pos': (11, 6), 'text': 'Automated\nTesting', 'color': '#fff3e0'},
        {'pos': (14, 6), 'text': 'Deploy to\nEnvironment', 'color': '#ffebee'},
        {'pos': (8, 3), 'text': 'Monitor &\nMaintain', 'color': '#f1f8e9'},
        {'pos': (5, 3), 'text': 'Update &\nIterate', 'color': '#fce4ec'},
    ]
    
    # Draw workflow boxes
    for i, step in enumerate(workflow_steps):
        rect = FancyBboxPatch((step['pos'][0] - 1, step['pos'][1] - 0.8), 
                             2, 1.6, boxstyle="round,pad=0.1", 
                             facecolor=step['color'], edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(step['pos'][0], step['pos'][1], step['text'], 
                ha='center', va='center', fontsize=10, fontweight='bold')
        
        # Add step numbers
        circle = plt.Circle((step['pos'][0] - 0.8, step['pos'][1] + 0.6), 0.2, 
                           color='navy', alpha=0.8)
        ax.add_patch(circle)
        ax.text(step['pos'][0] - 0.8, step['pos'][1] + 0.6, str(i + 1), 
                ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    # Draw arrows between steps
    arrow_connections = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 1)  # Last arrow creates the cycle
    ]
    
    for start_idx, end_idx in arrow_connections:
        start_pos = workflow_steps[start_idx]['pos']
        end_pos = workflow_steps[end_idx]['pos']
        
        if start_idx == 6 and end_idx == 1:  # Special case for the cycle back
            # Create curved arrow for the feedback loop
            ax.annotate('', xy=(end_pos[0] - 1, end_pos[1]), 
                       xytext=(start_pos[0] - 1, start_pos[1]),
                       arrowprops=dict(arrowstyle='->', lw=2, color='blue',
                                     connectionstyle="arc3,rad=-0.3"))
        else:
            ax.annotate('', xy=(end_pos[0] - 1, end_pos[1]), 
                       xytext=(start_pos[0] + 1, start_pos[1]),
                       arrowprops=dict(arrowstyle='->', lw=2, color='blue'))
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/iac_workflow.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_iac_tools_landscape():
    """Create a diagram showing the IaC tools landscape"""
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_title('Infrastructure as Code - Tools Landscape', fontsize=16, fontweight='bold')
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Tool categories
    categories = [
        {
            'title': 'Cloud-Agnostic Provisioning',
            'pos': (3.5, 8),
            'tools': ['Terraform', 'Pulumi', 'Crossplane'],
            'color': '#e1f5fe'
        },
        {
            'title': 'Cloud-Specific Tools',
            'pos': (10.5, 8),
            'tools': ['CloudFormation', 'ARM Templates', 'IBM Schematics'],
            'color': '#f3e5f5'
        },
        {
            'title': 'Configuration Management',
            'pos': (3.5, 5),
            'tools': ['Ansible', 'Puppet', 'Chef', 'SaltStack'],
            'color': '#e8f5e8'
        },
        {
            'title': 'Container Orchestration',
            'pos': (10.5, 5),
            'tools': ['Kubernetes', 'Docker Compose', 'Helm'],
            'color': '#fff3e0'
        },
        {
            'title': 'Policy & Compliance',
            'pos': (3.5, 2),
            'tools': ['Open Policy Agent', 'Sentinel', 'Falco'],
            'color': '#ffebee'
        },
        {
            'title': 'Testing & Validation',
            'pos': (10.5, 2),
            'tools': ['Terratest', 'Kitchen-Terraform', 'InSpec'],
            'color': '#f1f8e9'
        }
    ]
    
    for category in categories:
        # Draw category box
        rect = FancyBboxPatch((category['pos'][0] - 2, category['pos'][1] - 1.5), 
                             4, 3, boxstyle="round,pad=0.2", 
                             facecolor=category['color'], edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        
        # Category title
        ax.text(category['pos'][0], category['pos'][1] + 1, category['title'], 
                ha='center', va='center', fontsize=12, fontweight='bold')
        
        # Tools list
        tools_text = '\n'.join(category['tools'])
        ax.text(category['pos'][0], category['pos'][1] - 0.3, tools_text, 
                ha='center', va='center', fontsize=10)
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/iac_tools_landscape.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_iac_benefits_diagram():
    """Create a diagram showing the benefits of IaC implementation"""
    fig, ax = plt.subplots(figsize=(12, 10))
    ax.set_title('Infrastructure as Code - Key Benefits', fontsize=16, fontweight='bold')
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Central benefits hub
    center_rect = FancyBboxPatch((4.5, 4), 3, 2, boxstyle="round,pad=0.2", 
                                facecolor='lightblue', edgecolor='navy', linewidth=3)
    ax.add_patch(center_rect)
    ax.text(6, 5, 'IaC\nBenefits', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    
    # Benefit categories
    benefits = [
        {'pos': (2, 8), 'text': 'Consistency &\nReproducibility', 'icon': '🔄'},
        {'pos': (6, 8.5), 'text': 'Version Control &\nAuditability', 'icon': '📝'},
        {'pos': (10, 8), 'text': 'Faster\nDeployment', 'icon': '⚡'},
        {'pos': (11, 5), 'text': 'Scalability', 'icon': '📈'},
        {'pos': (10, 2), 'text': 'Cost\nOptimization', 'icon': '💰'},
        {'pos': (6, 1.5), 'text': 'Disaster\nRecovery', 'icon': '🛡️'},
        {'pos': (2, 2), 'text': 'Collaboration', 'icon': '👥'},
        {'pos': (1, 5), 'text': 'Reduced\nErrors', 'icon': '✅'},
    ]
    
    for benefit in benefits:
        # Benefit box
        rect = FancyBboxPatch((benefit['pos'][0] - 0.8, benefit['pos'][1] - 0.6), 
                             1.6, 1.2, boxstyle="round,pad=0.1", 
                             facecolor='lightyellow', edgecolor='orange', linewidth=2)
        ax.add_patch(rect)
        
        # Icon and text
        ax.text(benefit['pos'][0], benefit['pos'][1] + 0.2, benefit['icon'], 
                ha='center', va='center', fontsize=16)
        ax.text(benefit['pos'][0], benefit['pos'][1] - 0.3, benefit['text'], 
                ha='center', va='center', fontsize=9, fontweight='bold')
        
        # Connection to center
        ax.plot([benefit['pos'][0], 6], [benefit['pos'][1], 5], 
                'gray', linewidth=1, alpha=0.6, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/iac_benefits.png', dpi=300, bbox_inches='tight')
    plt.close()

def generate_all_diagrams():
    """Generate all IaC concept diagrams"""
    print("Generating Infrastructure as Code concept diagrams...")
    
    create_traditional_vs_iac_comparison()
    print("✓ Traditional vs IaC comparison diagram created")
    
    create_iac_principles_diagram()
    print("✓ IaC principles diagram created")
    
    create_iac_workflow_diagram()
    print("✓ IaC workflow diagram created")
    
    create_iac_tools_landscape()
    print("✓ IaC tools landscape diagram created")
    
    create_iac_benefits_diagram()
    print("✓ IaC benefits diagram created")
    
    print(f"\nAll diagrams have been generated and saved to '{output_dir}/' directory")
    print("\nGenerated files:")
    for file in os.listdir(output_dir):
        if file.endswith('.png'):
            print(f"  - {file}")

if __name__ == "__main__":
    generate_all_diagrams()
